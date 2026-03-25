function Anim_Pillar_Tick() {
    // self = objAnimController instance
    var _HOLD       = _step[$ "hold"] ?? 40
    var _FADE       = _step[$ "fade"] ?? 50
    var _LINGER     = _step[$ "linger"] ?? 40
    var _TOTAL      = _HOLD + _FADE + _LINGER
    var _embers     = _step[$ "embers"] ?? false
    var _outer_w    = _step[$ "outer_w"] ?? 32
    var _ember_count = _step[$ "ember_count"] ?? 5
    var _ember_trail = _step[$ "ember_trail"] ?? 8
    var _ember_scl   = _step[$ "ember_scl"] ?? 1
    var _ember_w     = _step[$ "ember_w"] ?? _outer_w
    var _ember_life   = _step[$ "ember_life"] ?? 40
    var _ember_linger = _step[$ "ember_linger"] ?? 0
    var _fire_overlay = _step[$ "fire_overlay"] ?? false
    var _fire_rate    = _step[$ "fire_rate"] ?? 2
    var _fire_w       = _step[$ "fire_w"] ?? (_outer_w / 2)

    _check_hit()

    // Spawn embers while pillar is visible
    if _embers and _timer <= _HOLD + _FADE + _ember_linger and instance_exists(_target) {
        var _hw = _ember_w / 2
        repeat (_ember_count) {
            var _ox = irandom_range(-_hw, _hw)
            instance_create_depth(
                _target.x + _ox, _target.y,
                100, objParticle, {
                    vx:   -0.1 + random(0.2),
                    vy:   -(0.15 + random(0.3)),
                    grav: 0,
                    life: _ember_life + irandom(20),
                    col:  _col,
                    scl:  1 + irandom(_ember_scl),
                    trail: _ember_trail,
                    spr:  sprCirclePart,
                })
        }
    }

    // Fire overlay
    if _fire_overlay and _timer <= _HOLD + _FADE and instance_exists(_target) {
        var _fhw = _fire_w / 2
        repeat (_fire_rate) {
            var _ox = irandom_range(-_fhw, _fhw)
            instance_create_depth(
                _target.x + _ox, _target.y,
                100, objParticle, {
                    vx:   -0.05 + random(0.1),
                    vy:   -(1.0 + random(1.5)),
                    grav: -0.01,
                    life: 300,
                    col:  _col,
                    scl:  1 + irandom(1),
                    trail: 0,
                    die_y: 0,
                    spr:  sprCirclePart,
                })
        }
    }

    // Drizzle overlay
    var _drizzle_overlay = _step[$ "drizzle_overlay"] ?? false
    var _drizzle_rate    = _step[$ "drizzle_rate"] ?? 3
    var _drizzle_w       = _step[$ "drizzle_w"] ?? _outer_w
    if _drizzle_overlay and _timer <= _HOLD + _FADE and instance_exists(_target) {
        var _dhw = _drizzle_w / 2
        repeat (_drizzle_rate) {
            instance_create_depth(
                _target.x + irandom_range(-_dhw, _dhw), 0,
                100, objParticle, {
                    vx:   0,
                    vy:   0.2 + random(0.2),
                    grav: 0.02,
                    life: 300,
                    col:  _col,
                    scl:  1,
                    trail: 0,
                    spr:  sprCirclePart,
                })
        }
    }

    if _timer >= _TOTAL {
        _finish()
    }
}

function Anim_Pillar_Draw() {
    // self = objAnimController instance
    if !instance_exists(_target) { return }
    var _HOLD    = _step[$ "hold"] ?? 40
    var _FADE    = _step[$ "fade"] ?? 50
    var _FADE_IN = _step[$ "fade_in"] ?? 6
    var _core_w  = _step[$ "core_w"] ?? 20
    var _outer_w = _step[$ "outer_w"] ?? 32

    var _alpha = 1
    if _timer < _FADE_IN {
        _alpha = _timer / _FADE_IN
    } else if _timer > _HOLD {
        _alpha = 1 - ((_timer - _HOLD) / _FADE)
    }
    _alpha = clamp(_alpha, 0, 1)

    var _half_outer = _outer_w / 2
    var _half_core  = _core_w / 2
    var _tx     = _target.x
    var _foot_y = _target.y

    gpu_set_blendmode(bm_add)

    // Outer glow
    draw_set_alpha(_alpha * 0.6)
    draw_set_color(_col)
    draw_rectangle(_tx - _half_outer, 0, _tx + _half_outer - 1, _foot_y, false)

    // Core — near white
    draw_set_alpha(_alpha)
    draw_set_color(merge_color(_col, c_white, 0.7))
    draw_rectangle(_tx - _half_core, 0, _tx + _half_core - 1, _foot_y, false)

    draw_set_alpha(1)
    gpu_set_blendmode(bm_normal)
}
