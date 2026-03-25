function Anim_Stream() {
    // self = objAnimController instance
    // Works for both "fire" (particles rise) and "drizzle" (particles fall)
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
    var _width    = _step[$ "width"] ?? 1.0

    var _fissure      = _step[$ "fissure"] ?? false
    var _fissure_open = _step[$ "fissure_open"] ?? 30
    var _fissure_w    = _step[$ "fissure_width"] ?? 1.2

    _check_hit()

    // Clouds at top of screen
    var _clouds = _step[$ "clouds"] ?? false
    if _clouds and _timer <= _HOLD and instance_exists(_target) {
        var _cl_h   = _step[$ "cloud_height"] ?? 12
        var _cl_scl = _step[$ "cloud_scl"] ?? 3
        var _cl_var = _step[$ "cloud_scl_var"] ?? 2
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
        var _cl_max = _step[$ "cloud_alpha"] ?? 0.5
        if _parent._cloud_alpha < _cl_max { _parent._cloud_alpha = min(_parent._cloud_alpha + 0.08, _cl_max) }
    }
    if _clouds and _timer >= _HOLD and !_parent._cloud_fading and _parent._cloud_hold == 0 {
        _parent._cloud_hold = 1
    }
    if _clouds and _timer >= _HOLD + 10 and !_parent._cloud_fading {
        _parent._cloud_fading = true
    }

    // Spawn particles
    var _fissure_pause = _step[$ "fissure_pause"] ?? 30
    var _spawn_start = _fissure ? _fissure_open + _fissure_pause : 0
    if _timer >= _spawn_start and _timer <= _HOLD and instance_exists(_target) {
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

    // Secondary drizzle overlay
    var _overlay_el = _step[$ "overlay_element"] ?? undefined
    if !is_undefined(_overlay_el) and _timer <= _HOLD and instance_exists(_target) {
        var _ov_col  = AnimColor(_overlay_el)
        var _ov_rate = _step[$ "overlay_rate"] ?? 0.5
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

    // Splash — tiny embers at feet
    var _splash = _step[$ "splash"] ?? false
    var _sp_delay = _step[$ "splash_delay"] ?? 20
    if _splash and _timer >= _sp_delay and _timer <= _HOLD and instance_exists(_target) {
        var _sp_rate = _step[$ "splash_rate"] ?? 2
        var _sp_life = _step[$ "splash_life"] ?? 12
        var _sp_scl  = _step[$ "splash_scl"] ?? 1
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

    // Store fissure state for draw
    if _fissure {
        _stream_fissure_open = _fissure_open
        _stream_fissure_w = _fissure_w
        _stream_fissure_hold = _HOLD
        _stream_fissure_linger = _linger
    }

    if _timer >= _TOTAL {
        _finish()
    }
}

function Anim_Stream_Draw() {
    // self = objAnimController instance
    if !instance_exists(_target) { return }
    if !variable_instance_exists(id, "_stream_fissure_open") { return }

    var _open_dur  = _stream_fissure_open
    var _hold_end  = _stream_fissure_hold
    var _close_dur = _stream_fissure_linger * 0.5
    var _close_end = _hold_end + _close_dur

    var _t = _target
    var _hw = round(_t.sprite_width / 2 * _stream_fissure_w)
    var _fy = _t.y

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
    if _open_amt <= 0 { return }

    var _max_hh = 5
    var _hh = round(_max_hh * _open_amt)

    gpu_set_blendmode(bm_add)
    draw_set_alpha(0.4)
    draw_set_color(_col)
    draw_rectangle(_t.x - _hw - 1, _fy - _hh - 1, _t.x + _hw, _fy + _hh, false)

    draw_set_alpha(0.8)
    draw_set_color(c_white)
    draw_rectangle(_t.x - _hw, _fy - max(0, _hh - 1), _t.x + _hw - 1, _fy + max(0, _hh - 1), false)

    draw_set_alpha(1)
    gpu_set_blendmode(bm_normal)
}
