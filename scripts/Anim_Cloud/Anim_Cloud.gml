function Anim_Cloud() {
    // self = objAnimController instance
    var _count    = _step[$ "count"] ?? 80
    var _SPAWN    = _step[$ "spawn"] ?? 8
    var _max_alpha = _step[$ "alpha"] ?? 0.75
    var _cloud_hold_dur = _step[$ "cloud_hold"] ?? 60
    var _scl      = _step[$ "scl"] ?? 3
    var _scl_var  = _step[$ "scl_var"] ?? 2
    var _height   = _step[$ "height"] ?? 0.7
    var _persist  = _step[$ "persist"] ?? false
    var _cloud_y  = _step[$ "cloud_y"] ?? undefined
    var _vert_spread_override = _step[$ "vert_spread"]

    _check_hit()
    _fire_subs()

    // Fade cloud in over spawn period (delegates to parent)
    if _timer <= _SPAWN {
        _parent._cloud_alpha = min(_parent._cloud_alpha + (_max_alpha / _SPAWN) * ANIM_TICK, _max_alpha)
    }

    // Spawn particles on target
    if _timer <= _SPAWN and instance_exists(_target) {
        var _tx     = _target.x
        var _ty     = is_undefined(_cloud_y) ? _target.y - _target.sprite_height * _height : _cloud_y
        var _half_w = _target.sprite_width / 2
        var _vert_spread = !is_undefined(_vert_spread_override) ? _vert_spread_override : (_target.sprite_height / 8)
        var _per_frame = ceil(_count / _SPAWN) * ANIM_TICK
        repeat (_per_frame) {
            var _ox = irandom_range(-_half_w, _half_w)
            var _oy = irandom_range(-_vert_spread, _vert_spread)
            instance_create_depth(
                _tx + _ox,
                _ty + _oy,
                100, objParticle, {
                    vx:   choose(-1, 1) * (0.02 + random(0.06)),
                    vy:   0,
                    grav: 0,
                    life: 9999,
                    col:  _col,
                    scl:  _scl + irandom(_scl_var),
                    spr:  sprCirclePart,
                    soft: true,
                })
        }
    }

    // Hold on cloud, then fade
    if _timer >= _SPAWN {
        if _parent._cloud_hold == 0 and !_parent._cloud_fading {
            _parent._cloud_hold = _cloud_hold_dur
        }
        if _persist {
            _finish()
        } else {
            if _parent._cloud_alpha <= 0 and !_parent._cloud_fading {
                _finish()
            }
        }
    }
}
