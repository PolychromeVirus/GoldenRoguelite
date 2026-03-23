// _queue, _on_hit, _on_complete passed via creation struct

_qi        = 0
_timer     = 0
_hit_fired = false
_hit_timer = 0
_col       = c_white
_cloud_alpha = 0
_cloud_hold  = 0     // frames to hold cloud at full alpha before fading
_cloud_fading = false
_draw      = method(id, function() {})   // no-op default; sprite anims override this
_sub_flash_alpha = 0
_fade_spr  = undefined                   // set by Anim_Sprite_Tick on step advance

_next_step = method(id, function() {
    _qi++
    if _qi >= array_length(_queue) {
        // If cloud is still visible, defer completion until fade finishes
        if _cloud_alpha > 0 {
            _tick = method(id, function() {
                if _cloud_alpha <= 0 {
                    _on_complete()
                    instance_destroy()
                }
            })
            // Start fading now if not already
            if !_cloud_fading and _cloud_hold == 0 {
                _cloud_fading = true
            }
        } else {
            _on_complete()
            instance_destroy()
        }
    } else {
        _load_step()
    }
})

// Common hit-check used by cloud, flash, pillar, stream
// Fires _on_hit once at hit_delay (default frame 1) if fires_hit is set
_check_hit = method(id, function() {
    var _step   = _queue[_qi]
    var _hit_at = _step[$ "hit_delay"] ?? 1
    if _timer >= _hit_at and !_hit_fired {
        _hit_fired = true
        _hit_timer = _timer
        if _step[$ "fires_hit"] ?? false { _on_hit() }
        // Tint targets at hit time + show damage shake sprite
        var _hit_tint = _step[$ "hit_tint"]
        if !is_undefined(_hit_tint) {
            var _hit_tint_dur = _step[$ "hit_tint_duration"] ?? 20
            for (var _hq = _qi; _hq < array_length(_queue); _hq++) {
                if _hq != _qi and _queue[_hq].type != _step.type { break }
                if instance_exists(_queue[_hq].target) {
                    _queue[_hq].target.tint_color = _hit_tint
                    _queue[_hq].target.tint_timer = _hit_tint_dur
                    _queue[_hq].target.damage_timer = _hit_tint_dur
                }
            }
        }
    }
})

// Fire sub-effects attached to the current step via the "sub" field
// sub can be a single struct or array of structs: { type, at, ... }
// Each sub fires once at _timer == at, targeting all same-type steps in queue
_sub_fired = []
_fire_subs = method(id, function() {
    var _step = _queue[_qi]
    var _subs = _step[$ "sub"]
    if is_undefined(_subs) { return }
    if !is_array(_subs) { _subs = [_subs] }

    for (var _si = 0; _si < array_length(_subs); _si++) {
        // Skip if already fired
        if _si < array_length(_sub_fired) and _sub_fired[_si] { continue }
        var _s = _subs[_si]
        var _at = _s[$ "at"] ?? 1
        var _delay = _s[$ "delay"] ?? 0
        if is_string(_at) and _at == "hit" {
            if !_hit_fired { continue }
            if _timer < _hit_timer + _delay { continue }
        } else {
            if _timer < _at + _delay { continue }
        }

        // Mark fired
        while array_length(_sub_fired) <= _si { array_push(_sub_fired, false) }
        _sub_fired[_si] = true

        // Sub shake
        var _sub_shake = _s[$ "shake"]
        if !is_undefined(_sub_shake) {
            ScreenShake(_sub_shake, _s[$ "shake_duration"] ?? 15)
        }

        // Resolve color
        var _sub_col = AnimColor(_s[$ "element"] ?? _step.element)

        // Gather targets — all same-type steps from _qi onward
        var _targets = []
        for (var _q = _qi; _q < array_length(_queue); _q++) {
            if _queue[_q].type != _step.type { break }
            array_push(_targets, _queue[_q].target)
        }

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
                    SpawnBurstParticles(_t.x + _ox, _t.y - (_center ? _t.sprite_height / 2 : 0) + _oy, _sub_col, _count, _max_spd, _max_scl, _sub_trail)
                }
                break
            case "fire":
                var _count = _s[$ "count"] ?? 30
                for (var _ti = 0; _ti < array_length(_targets); _ti++) {
                    var _t = _targets[_ti]
                    SpawnFireParticles(_t.x, _t.y, _sub_col, _count, _t.sprite_width / 2)
                }
                break
            case "flash":
                // Flash is handled by draw — store it for _draw to pick up
                _sub_flash_col   = _sub_col
                _sub_flash_timer = 0
                _sub_flash_hold  = _s[$ "hold"] ?? 20
                break
        }
    }
})

_load_step = method(id, function() {
    _timer     = 0
    _hit_fired = false
    _hit_timer = 0
    _sub_fired = []
    _draw      = method(id, function() {})
    var _step  = _queue[_qi]
    // Shake at step start (meteor/burst handle their own at impact)
    if _step.type != "meteor" and _step.type != "burst" {
        var _shake = _step[$ "shake"]
        if !is_undefined(_shake) {
            ScreenShake(_shake, _step[$ "shake_duration"] ?? 15)
        }
    }
    // Freeze/unfreeze target sprite (cyan shader overlay + pause animation)
    // Applies to all consecutive same-type targets in the queue
    if _step[$ "freeze_target"] ?? false {
        for (var _fq = _qi; _fq < array_length(_queue); _fq++) {
            if _fq != _qi and _queue[_fq].type != _step.type { break }
            if instance_exists(_queue[_fq].target) {
                _queue[_fq].target.frozen = 1
                _queue[_fq].target.image_speed = 0
            }
        }
    }
    // Tint targets a specific color for N frames
    var _tint = _step[$ "tint_target"]
    if !is_undefined(_tint) {
        var _tint_dur = _step[$ "tint_duration"] ?? 30
        for (var _tq = _qi; _tq < array_length(_queue); _tq++) {
            if _tq != _qi and _queue[_tq].type != _step.type { break }
            if instance_exists(_queue[_tq].target) {
                _queue[_tq].target.tint_color = _tint
                _queue[_tq].target.tint_timer = _tint_dur
            }
        }
    }
    if _step[$ "unfreeze_target"] ?? false {
        if instance_exists(_step.target) {
            _step.target.frozen = 0
            _step.target.image_speed = 1
        }
    }
    // Screen tint — persistent overlay that lasts across subsequent steps
    var _screen_tint = _step[$ "screen_tint"]
    if !is_undefined(_screen_tint) {
        _sub_flash_col   = _screen_tint
        _sub_flash_alpha = _step[$ "screen_tint_alpha"] ?? 0.4
        _sub_flash_timer = 7  // past peak so it starts at full alpha
        _sub_flash_hold  = _step[$ "screen_tint_hold"] ?? 9999
    }
    _col = _step[$ "color"] ?? AnimColor(_step.element)
    switch (_step.type) {
        case "burst":    _tick = method(id, Anim_Burst);       break
        case "cloud":    _tick = method(id, Anim_Cloud);      break
        case "fire":
        case "drizzle":  _tick = method(id, Anim_Stream)
                         if _step[$ "fissure"] ?? false { _draw = method(id, Anim_Stream_Draw) }
                         break
        case "wind":     _tick = method(id, Anim_Wind);       break
        case "pillar":   _tick = method(id, Anim_Pillar_Tick)
                         _draw = method(id, Anim_Pillar_Draw) break
        case "ray":      _tick = method(id, Anim_Ray_Tick)
                         _draw = method(id, Anim_Ray_Draw)    break
        case "flash":    _tick = method(id, Anim_Flash_Tick)
                         _draw = method(id, Anim_Flash_Draw)  break
        case "meteor":   _tick = method(id, Anim_Meteor_Tick)
                         _draw = method(id, Anim_Meteor_Draw) break
        case "sprite":   _tick = method(id, Anim_Sprite_Tick)
                         _draw = method(id, Anim_Sprite_Draw) break
        default:
            show_debug_message("objSpellAnimation: unknown type '" + _step.type + "'")
            _next_step()
    }
})

_load_step()
