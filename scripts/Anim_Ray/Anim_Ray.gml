function Anim_Ray_Tick() {
    // self = objAnimController instance
    var _HOLD       = _step[$ "hold"] ?? 40
    var _LINGER     = _step[$ "linger"] ?? 30
    var _TOTAL      = _HOLD + _LINGER
    var _bolt_count = _step[$ "bolts"] ?? 5
    var _spread     = _step[$ "spread"] ?? 20
    var _cloud_h    = _step[$ "cloud_height"] ?? 20
    var _cloud_scl  = _step[$ "cloud_scl"] ?? 4
    var _cloud_var  = _step[$ "cloud_scl_var"] ?? 2
    var _flicker    = _step[$ "flicker"] ?? 3
    var _bolt_delay = _step[$ "bolt_delay"] ?? 0

    _check_hit()

    // Build bolt positions once at start
    if _timer <= ANIM_TICK and instance_exists(_target) {
        _ray_bolts = []
        for (var _b = 0; _b < _bolt_count; _b++) {
            array_push(_ray_bolts, {
                tx: _target.x + irandom_range(-_spread, _spread),
                foot_y: _target.y,
            })
        }
    }

    // Spawn cloud particles at top during hold
    if _timer <= _HOLD and instance_exists(_target) {
        var _hw = _spread + 5
        repeat (2 * ANIM_TICK) {
            instance_create_depth(
                _target.x + irandom_range(-_hw, _hw),
                _cloud_h + irandom_range(-6, 6),
                100, objParticle, {
                    vx:   choose(-1, 1) * (0.02 + random(0.06)),
                    vy:   0,
                    grav: 0,
                    life: 9999,
                    col:  _col,
                    scl:  _cloud_scl + irandom(_cloud_var),
                    spr:  sprCirclePart,
                    soft: true,
                })
        }
        if _parent._cloud_alpha < 0.5 { _parent._cloud_alpha = min(_parent._cloud_alpha + 0.08, 0.5) }
    }

    // Light drizzle behind bolts
    var _drizzle_rate = _step[$ "drizzle"] ?? 0
    if _drizzle_rate > 0 and _timer <= _HOLD and instance_exists(_target) {
        var _dhw = _spread + 10
        repeat (_drizzle_rate) {
            instance_create_depth(
                _target.x + irandom_range(-_dhw, _dhw),
                _cloud_h,
                100, objParticle, {
                    vx:   0,
                    vy:   2.5 + random(2.0),
                    grav: 0.06,
                    life: 60 + irandom(30),
                    col:  _col,
                    scl:  1,
                    trail: 4,
                    die_y: _target.y,
                    spr:  sprCirclePart,
                })
        }
    }

    // Reshuffle bolt positions for jitter
    if variable_instance_exists(id, "_ray_bolts") and instance_exists(_target) {
        if _timer >= _bolt_delay and _timer mod (_flicker * ANIM_TICK) == 0 and _timer <= _HOLD {
            for (var _b = 0; _b < array_length(_ray_bolts); _b++) {
                _ray_bolts[_b].tx = _target.x + irandom_range(-_spread, _spread)
            }
        }
    }

    // Start cloud fade after hold
    if _timer >= _HOLD and !_parent._cloud_fading and _parent._cloud_hold == 0 {
        _parent._cloud_hold = 1
    }
    if _timer >= _HOLD + 10 and !_parent._cloud_fading {
        _parent._cloud_fading = true
    }

    if _timer >= _TOTAL {
        _finish()
    }
}

function Anim_Ray_Draw() {
    // self = objAnimController instance
    var _HOLD       = _step[$ "hold"] ?? 40
    var _bolt_w     = _step[$ "bolt_w"] ?? 1
    var _cloud_h    = _step[$ "cloud_height"] ?? 20
    var _bolt_delay = _step[$ "bolt_delay"] ?? 0

    if !variable_instance_exists(id, "_ray_bolts") { return }
    if _timer > _HOLD or _timer < _bolt_delay { return }

    gpu_set_blendmode(bm_add)
    for (var _i = 0; _i < array_length(_ray_bolts); _i++) {
        var _b = _ray_bolts[_i]
        if irandom(2) == 0 { continue }
        var _bx = _b.tx
        var _hw = max(0, floor(_bolt_w / 2))

        draw_set_alpha(0.4)
        draw_set_color(_col)
        draw_rectangle(_bx - _hw, _cloud_h, _bx + _hw, _b.foot_y, false)

        draw_set_alpha(0.9)
        draw_set_color(c_white)
        draw_rectangle(_bx, _cloud_h, _bx, _b.foot_y, false)
    }
    draw_set_alpha(1)
    gpu_set_blendmode(bm_normal)
}
