/// Per-target, per-layer animation controller.
/// Created by objAnimOrchestrator with a creation struct.
///
/// Required creation vars:
///   _parent       — objAnimOrchestrator instance
///   _step         — single animation step struct { type, element, opts... }
///   _target       — the monster instance this animates (or noone for shared positioned elsewhere)
///   _delay        — frames to wait before starting
///   _packet       — cloned aggression schema with targets=[_target], or undefined
///   _all_targets  — array of ALL targets (used by shared mode for multi-target particles)

_timer     = 0
_hit_fired = false
_hit_timer = 0
_started   = false
_done      = false
_col       = _step[$ "color"] ?? AnimColor(_step.element)
_tick      = method(id, function() {})   // no-op until loaded
_draw      = method(id, function() {})   // no-op default

// Sub-effect state
_sub_fired       = []
_sub_flash_alpha = 0

// Fade sprite state (for Anim_Sprite lingering ghost)
_fade_spr   = undefined
_fade_alpha = 0
_fade_frame = 0
_fade_tx    = 0
_fade_ty    = 0
_fade_blend = "normal"

// Cloud state — delegates to parent but controllers track per-target cloud particles
_cloud_targets = undefined

// Common hit-check — fires _on_hit once at hit_delay
_check_hit = method(id, function() {
    var _hit_at = _step[$ "hit_delay"] ?? 1
    if _timer >= _hit_at and !_hit_fired {
        _hit_fired = true
        _hit_timer = _timer
        // Stop start sound if sfx_end_start is set (or by default when hit sfx plays)
        var _sfx_start_snd = _step[$ "sfx_start"]
        if !is_undefined(_sfx_start_snd) and (_step[$ "sfx_stop_start"] ?? false) {
            audio_stop_sound(_sfx_start_snd)
        }
        // Play hit sound effect
        var _sfx = _step[$ "sfx"]
		var _gain = _step[$ "sfx_gain"] ?? 1
        if !is_undefined(_sfx) {
            audio_stop_sound(_sfx)
            audio_play_sound(_sfx, 0, 0, _gain)
        }
        // Fire damage if this step has fires_hit
        // Repeater is stripped — _resolve/_FireRepeats handles repeat hits after animation
        if _step[$ "fires_hit"] ?? false {
            if !is_undefined(_packet) {
                var _pkt = variable_clone(_packet)
                _pkt.repeater = 0
                DoDamage(_pkt)
            }
        }
        // Custom on_hit callback (receives _target)
        var _on_hit = _step[$ "on_hit"]
        if !is_undefined(_on_hit) {
            _on_hit(_target)
        }
        // Tint targets at hit time
        var _hit_tint = _step[$ "hit_tint"]
        if !is_undefined(_hit_tint) {
            var _hit_tint_dur = _step[$ "hit_tint_duration"] ?? 20
            var _tgts = _all_targets
            for (var _i = 0; _i < array_length(_tgts); _i++) {
                if instance_exists(_tgts[_i]) {
                    _tgts[_i].tint_color = _hit_tint
                    _tgts[_i].tint_timer = _hit_tint_dur
                    _tgts[_i].damage_timer = _hit_tint_dur
                }
            }
        }
        // Set hurt sprite independently if hurt_delay matches
        var _hurt = _step[$ "hurt_delay"]
        if !is_undefined(_hurt) and instance_exists(_target) {
            _target.damage_timer = _step[$ "hurt_duration"] ?? 20
        }
    }
    // Hurt delay — separate from hit (can be different timing)
    var _hurt = _step[$ "hurt_delay"]
    if !is_undefined(_hurt) and _hurt != (_step[$ "hit_delay"] ?? 1) {
        if _timer >= _hurt and !variable_instance_exists(id, "_hurt_set") {
            _hurt_set = true
            if instance_exists(_target) {
                _target.damage_timer = _step[$ "hurt_duration"] ?? 20
            }
        }
    }
})

// Fire sub-effects attached to the step via the "sub" field
_fire_subs = method(id, function() {
    var _subs = _step[$ "sub"]
    if is_undefined(_subs) { return }
    if !is_array(_subs) { _subs = [_subs] }

    for (var _si = 0; _si < array_length(_subs); _si++) {
        if _si < array_length(_sub_fired) and _sub_fired[_si] { continue }
        var _s = _subs[_si]
        var _at = _s[$ "at"] ?? 1
        var _sdel = _s[$ "delay"] ?? 0
        if is_string(_at) and _at == "hit" {
            if !_hit_fired { continue }
            if _timer < _hit_timer + _sdel { continue }
        } else {
            if _timer < _at + _sdel { continue }
        }

        while array_length(_sub_fired) <= _si { array_push(_sub_fired, false) }
        _sub_fired[_si] = true

        // Sub shake
        var _sub_shake = _s[$ "shake"]
        if !is_undefined(_sub_shake) {
            ScreenShake(_sub_shake, _s[$ "shake_duration"] ?? 15)
        }

        var _sub_col = AnimColor(_s[$ "element"] ?? _step.element)

        // Gather targets for sub-effect
        var _targets = _all_targets

        // Dispatch sub-effect
        var _sub_type = _s[$ "type"] ?? "burst"
        switch (_sub_type) {
            case "burst":
                var _count = _s[$ "count"] ?? 44
                var _max_spd = _s[$ "max_speed"] ?? 5
                var _max_scl = _s[$ "max_scale"] ?? 2
                var _sub_trail = _s[$ "trail"] ?? undefined
                var _ox = _s[$ "offset_x"] ?? 0
                var _oy = _s[$ "offset_y"] ?? 0
                var _center = !(_s[$ "at_foot"] ?? false)
                for (var _ti = 0; _ti < array_length(_targets); _ti++) {
                    var _t = _targets[_ti]
                    if !instance_exists(_t) { continue }
                    SpawnBurstParticles(_t.x + _ox, _t.y - (_center ? _t.sprite_height / 2 : 0) + _oy, _sub_col, _count, _max_spd, _max_scl, _sub_trail)
                }
                break
            case "fire":
                var _count = _s[$ "count"] ?? 30
                for (var _ti = 0; _ti < array_length(_targets); _ti++) {
                    var _t = _targets[_ti]
                    if !instance_exists(_t) { continue }
                    SpawnFireParticles(_t.x, _t.y, _sub_col, _count, _t.sprite_width / 2)
                }
                break
            case "flash":
                _sub_flash_col   = _sub_col
                _sub_flash_timer = 0
                _sub_flash_hold  = _s[$ "hold"] ?? 20
                break
            case "sfx":
                var _snd = _s[$ "sound"]
                if !is_undefined(_snd) {
                    audio_stop_sound(_snd)
                    audio_play_sound(_snd, 0, 0, _s[$ "gain"] ?? 1)
                }
                break
        }
    }
})

// Load the animation type — called once when delay expires
_load_anim = method(id, function() {
	var _gain = _step[$ "sfx_start_gain"] ?? 1
	
    // Play start sound effect
    var _sfx_start = _step[$ "sfx_start"]
    if !is_undefined(_sfx_start) {
        audio_stop_sound(_sfx_start)
        audio_play_sound(_sfx_start, 0, 0, _gain)
    }
    // Shake at step start
    if _step.type != "meteor" and _step.type != "burst" {
        var _shake = _step[$ "shake"]
        if !is_undefined(_shake) {
            ScreenShake(_shake, _step[$ "shake_duration"] ?? 15)
        }
    }
    // Freeze target
    if _step[$ "freeze_target"] ?? false {
        for (var _i = 0; _i < array_length(_all_targets); _i++) {
            if instance_exists(_all_targets[_i]) {
                _all_targets[_i].frozen = 1
                _all_targets[_i].image_speed = 0
            }
        }
    }
    // Tint targets
    var _tint = _step[$ "tint_target"]
    if !is_undefined(_tint) {
        var _tint_dur = _step[$ "tint_duration"] ?? 30
        for (var _i = 0; _i < array_length(_all_targets); _i++) {
            if instance_exists(_all_targets[_i]) {
                _all_targets[_i].tint_color = _tint
                _all_targets[_i].tint_timer = _tint_dur
            }
        }
    }
    // Unfreeze target
    if _step[$ "unfreeze_target"] ?? false {
        if instance_exists(_target) {
            _target.frozen = 0
            _target.image_speed = 1
        }
    }
    // Screen tint — delegates to parent orchestrator
    var _screen_tint = _step[$ "screen_tint"]
    if !is_undefined(_screen_tint) {
        _parent.SetScreenTint(
            _screen_tint,
            _step[$ "screen_tint_alpha"] ?? 0.4,
            _step[$ "screen_tint_hold"] ?? 9999,
            _step[$ "screen_tint_fade"] ?? 20
        )
    }

    _col = _step[$ "color"] ?? AnimColor(_step.element)
    switch (_step.type) {
        case "burst":    _tick = method(id, Anim_Burst);        break
        case "cloud":    _tick = method(id, Anim_Cloud);        break
        case "fire":
        case "drizzle":  _tick = method(id, Anim_Stream)
                         if _step[$ "fissure"] ?? false { _draw = method(id, Anim_Stream_Draw) }
                         break
        case "wind":     _tick = method(id, Anim_Wind);         break
        case "pillar":   _tick = method(id, Anim_Pillar_Tick)
                         _draw = method(id, Anim_Pillar_Draw)   break
        case "ray":      _tick = method(id, Anim_Ray_Tick)
                         _draw = method(id, Anim_Ray_Draw)      break
        case "flash":    _tick = method(id, Anim_Flash_Tick)
                         _draw = method(id, Anim_Flash_Draw)    break
        case "meteor":   _tick = method(id, Anim_Meteor_Tick)
                         _draw = method(id, Anim_Meteor_Draw)   break
        case "sprite":   _tick = method(id, Anim_Sprite_Tick)
                         _draw = method(id, Anim_Sprite_Draw)   break
        default:
            show_debug_message("objAnimController: unknown type '" + _step.type + "'")
            _finish()
    }
})

// Called when this controller's animation is complete
_finish = method(id, function() {
    if _done { return }
    _done = true
    _parent.ControllerDone(id)
    instance_destroy()
})
