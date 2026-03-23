function Anim_Stream() {
    // self = objSpellAnimation instance
    // Works for both "fire" (particles rise) and "drizzle" (particles fall)
    var _step     = _queue[_qi]
    var _rising   = (_step.type == "fire")
    var _rate     = _step[$ "rate"] ?? 3
    var _HOLD     = _step[$ "hold"] ?? 60
    var _linger   = _step[$ "linger"] ?? 40
    var _TOTAL    = _HOLD + _linger
    var _trail    = _step[$ "trail"] ?? (_rising ? 60 : 10)
    var _life     = _step[$ "life"] ?? 80
    var _life_var = _step[$ "life_var"] ?? 40
    var _scl      = _step[$ "scl"] ?? 1
    var _scl_var  = _step[$ "scl_var"] ?? 3
    var _grav     = _step[$ "grav"] ?? (_rising ? -0.02 : 0.06)
    var _width    = _step[$ "width"] ?? 1.0   // multiplier on target half-width
    var _stagger  = _step[$ "stagger"] ?? undefined

    var _fissure      = _step[$ "fissure"] ?? false
    var _fissure_open = _step[$ "fissure_open"] ?? 30
    var _fissure_w    = _step[$ "fissure_width"] ?? 1.2  // multiplier on target half-width

    _check_hit()

    // Gather targets — single (staggered) or all consecutive (simultaneous)
    var _targets = []
    if is_undefined(_stagger) {
        // Simultaneous: all same-type targets
        for (var _q = _qi; _q < array_length(_queue); _q++) {
            var _s = _queue[_q]
            if _s.type != "fire" and _s.type != "drizzle" { break }
            array_push(_targets, _s.target)
        }
    } else {
        // Staggered: current target only
        array_push(_targets, _step.target)
    }

    // Clouds at top of screen
    var _clouds = _step[$ "clouds"] ?? false
    if _clouds and _timer <= _HOLD {
        var _cl_h   = _step[$ "cloud_height"] ?? 12
        var _cl_scl = _step[$ "cloud_scl"] ?? 3
        var _cl_var = _step[$ "cloud_scl_var"] ?? 2
        for (var _ti = 0; _ti < array_length(_targets); _ti++) {
            var _target = _targets[_ti]
            var _hw = round(_target.sprite_width / 2 * _width) + 5
            repeat (2 * ANIM_TICK) {
                instance_create_depth(
                    _target.x + irandom_range(-_hw, _hw),
                    _cl_h + irandom_range(-6, 6),
                    100, objParticle, {
                        vx:   choose(-1, 1) * (0.02 + random(0.06)),
                        vy:   0,
                        grav: 0,
                        life: 9999,
                        col:  _col,
                        scl:  _cl_scl + irandom(_cl_var),
                        spr:  sprCirclePart,
                        soft: true,
                    })
            }
        }
        var _cl_max = _step[$ "cloud_alpha"] ?? 0.5
        if _cloud_alpha < _cl_max { _cloud_alpha = min(_cloud_alpha + 0.08, _cl_max) }
    }
    // Start cloud fade after hold
    if _clouds and _timer >= _HOLD and !_cloud_fading and _cloud_hold == 0 {
        _cloud_hold = 1
    }
    if _clouds and _timer >= _HOLD + 10 and !_cloud_fading {
        _cloud_fading = true
    }

    // Spawn particles (delayed until fissure fully opens + pause)
    var _fissure_pause = _step[$ "fissure_pause"] ?? 30
    var _spawn_start = _fissure ? _fissure_open + _fissure_pause : 0
    if _timer >= _spawn_start and _timer <= _HOLD {
        for (var _ti = 0; _ti < array_length(_targets); _ti++) {
            var _target = _targets[_ti]
            var _tx     = _target.x
            var _ty     = _rising ? _target.y : 0
            var _half_w = round(_target.sprite_width / 2 * _width)
            var _base_count = (_rate >= 1) ? round(_rate) : (random(1) < _rate ? 1 : 0)
            var _spawn_count = _rising ? _base_count * ANIM_TICK : _base_count
            repeat (_spawn_count) {
                var _ox = irandom_range(-_half_w, _half_w)
                var _drop_spd = _step[$ "drop_speed"] ?? 1.5
                var _vy = _rising ? -(0.5 + random(1.0)) : (_drop_spd + random(_drop_spd * 1.3))
                var _wiggle_amt = _step[$ "wiggle"] ?? 0
                var _wiggle_spd = _step[$ "wiggle_spd"] ?? 0.1
                instance_create_depth(
                    _tx + _ox,
                    _ty,
                    100, objParticle, {
                        vx:   _rising ? (-0.2 + random(0.4)) : 0,
                        vy:   _vy,
                        grav: _grav,
                        life: _life + irandom(_life_var),
                        col:  _col,
                        scl:  _scl + irandom(_scl_var),
                        trail: _trail,
                        die_y: _rising ? undefined : _target.y,
                        spr:  sprCirclePart,
                        wiggle: _wiggle_amt,
                        wiggle_spd: _wiggle_spd,
                    })
            }
        }
    }

    // Secondary drizzle overlay (different element colour, very sparse)
    var _overlay_el = _step[$ "overlay_element"] ?? undefined
    if !is_undefined(_overlay_el) and _timer <= _HOLD {
        var _ov_col  = AnimColor(_overlay_el)
        var _ov_rate = _step[$ "overlay_rate"] ?? 0.5
        for (var _ti = 0; _ti < array_length(_targets); _ti++) {
            var _target = _targets[_ti]
            var _tx     = _target.x
            var _ty     = _rising ? _target.y : 0
            var _half_w = round(_target.sprite_width / 2 * _width)
            var _ov_count = (_ov_rate >= 1) ? round(_ov_rate) : (random(1) < _ov_rate ? 1 : 0)
            repeat (_ov_count) {
                var _ox = irandom_range(-_half_w, _half_w)
                var _drop_spd = _step[$ "drop_speed"] ?? 1.5
                var _vy = _rising ? -(0.5 + random(1.0)) : (_drop_spd + random(_drop_spd * 1.3))
                instance_create_depth(
                    _tx + _ox, _ty,
                    100, objParticle, {
                        vx:   _rising ? (-0.2 + random(0.4)) : 0,
                        vy:   _vy,
                        grav: _grav,
                        life: _life + irandom(_life_var),
                        col:  _ov_col,
                        scl:  _step[$ "overlay_scl"] ?? 1,
                        trail: _trail,
                        die_y: _rising ? undefined : _target.y,
                        spr:  sprCirclePart,
                    })
            }
        }
    }

    // Splash — tiny short-lived embers at feet (for drizzle impact)
    var _splash = _step[$ "splash"] ?? false
    var _sp_delay = _step[$ "splash_delay"] ?? 20
    if _splash and _timer >= _sp_delay and _timer <= _HOLD {
        var _sp_rate = _step[$ "splash_rate"] ?? 2
        var _sp_life = _step[$ "splash_life"] ?? 12
        var _sp_scl  = _step[$ "splash_scl"] ?? 1
        for (var _ti = 0; _ti < array_length(_targets); _ti++) {
            var _target = _targets[_ti]
            var _half_w = round(_target.sprite_width / 2 * _width)
            repeat (_sp_rate) {
                var _ox = irandom_range(-_half_w, _half_w)
                instance_create_depth(
                    _target.x + _ox, _target.y,
                    100, objParticle, {
                        vx:   -0.1 + random(0.2),
                        vy:   -(0.2 + random(0.3)),
                        grav: 0,
                        life: _sp_life + irandom(8),
                        col:  _col,
                        scl:  _sp_scl,
                        trail: 0,
                        spr:  sprCirclePart,
                    })
            }
        }
    }

    // Store fissure state for draw
    if _fissure {
        _stream_fissure_targets = _targets
        _stream_fissure_open = _fissure_open
        _stream_fissure_w = _fissure_w
        _stream_fissure_hold = _HOLD
        _stream_fissure_linger = _linger
    }

    // Complete — determine when to advance
    var _is_last = (_qi >= array_length(_queue) - 1) or
        (_queue[_qi + 1].type != "fire" and _queue[_qi + 1].type != "drizzle")

    if is_undefined(_stagger) {
        // Simultaneous: wait full duration, skip all stream steps at once
        if _timer >= _TOTAL {
            while _qi < array_length(_queue) - 1 {
                var _next = _queue[_qi + 1]
                if _next.type != "fire" and _next.type != "drizzle" { break }
                _qi++
            }
            _next_step()
        }
    } else {
        // Staggered: advance early for non-last, full duration on last
        var _end = _is_last ? _TOTAL : _stagger
        if _timer >= _end {
            // Fire hit before advancing if it hasn't fired yet
            if !_hit_fired and (_step[$ "fires_hit"] ?? false) {
                _hit_fired = true
                _on_hit()
            }
            _next_step()
        }
    }
}

function Anim_Stream_Draw() {
    if !variable_instance_exists(id, "_stream_fissure_targets") { return }

    var _open_dur  = _stream_fissure_open
    var _hold_end  = _stream_fissure_hold
    var _close_dur = _stream_fissure_linger * 0.5  // close in first half of linger
    var _close_end = _hold_end + _close_dur

    for (var _ti = 0; _ti < array_length(_stream_fissure_targets); _ti++) {
        var _t = _stream_fissure_targets[_ti]
        if !instance_exists(_t) { continue }
        var _hw = round(_t.sprite_width / 2 * _stream_fissure_w)
        var _fy = _t.y

        // Vertical opening: thin line → opens up, holds, then closes shut
        var _open_amt
        if _timer <= _open_dur {
            _open_amt = _timer / _open_dur
        } else if _timer <= _hold_end {
            _open_amt = 1
        } else if _timer <= _close_end {
            _open_amt = 1 - ((_timer - _hold_end) / _close_dur)
        } else {
            _open_amt = 0
        }
        _open_amt = clamp(_open_amt, 0, 1)
        if _open_amt <= 0 { continue }

        var _max_hh = 5  // max half-height when fully open
        var _hh = round(_max_hh * _open_amt)

        // Glow (wider, taller, transparent)
        gpu_set_blendmode(bm_add)
        draw_set_alpha(0.4)
        draw_set_color(_col)
        draw_rectangle(_t.x - _hw - 1, _fy - _hh - 1, _t.x + _hw, _fy + _hh, false)

        // Core bright line (always full width, height scales)
        draw_set_alpha(0.8)
        draw_set_color(c_white)
        draw_rectangle(_t.x - _hw, _fy - max(0, _hh - 1), _t.x + _hw - 1, _fy + max(0, _hh - 1), false)

        draw_set_alpha(1)
        gpu_set_blendmode(bm_normal)
    }
}
