function Anim_Cloud() {
    // self = objSpellAnimation instance
    var _step     = _queue[_qi]
    var _count    = _step[$ "count"] ?? 80
    var _SPAWN    = _step[$ "spawn"] ?? 8
    var _max_alpha = _step[$ "alpha"] ?? 0.75
    var _cloud_hold_dur = _step[$ "cloud_hold"] ?? 60
    var _scl      = _step[$ "scl"] ?? 3
    var _scl_var  = _step[$ "scl_var"] ?? 2
    var _height   = _step[$ "height"] ?? 0.7
    var _persist  = _step[$ "persist"] ?? false
    var _cloud_y  = _step[$ "cloud_y"] ?? undefined  // fixed y position (overrides per-target height)

    // Gather all consecutive cloud targets
    if !variable_instance_exists(id, "_cloud_targets") or !is_array(_cloud_targets) {
        _cloud_targets = []
        for (var _q = _qi; _q < array_length(_queue); _q++) {
            if _queue[_q].type != "cloud" { break }
            array_push(_cloud_targets, _queue[_q].target)
        }
    }

    _check_hit()
    _fire_subs()

    // Fade cloud in over spawn period
    if _timer <= _SPAWN {
        _cloud_alpha = min(_cloud_alpha + (_max_alpha / _SPAWN) * ANIM_TICK, _max_alpha)
    }

    // Spawn particles on ALL targets simultaneously
    if _timer <= _SPAWN {
        for (var _ti = 0; _ti < array_length(_cloud_targets); _ti++) {
            var _target = _cloud_targets[_ti]
            if !instance_exists(_target) { continue }
            var _tx     = _target.x
            var _ty     = is_undefined(_cloud_y) ? _target.y - _target.sprite_height * _height : _cloud_y
            var _half_w = _target.sprite_width / 2
            var _per_frame = ceil(_count / _SPAWN) * ANIM_TICK
            repeat (_per_frame) {
                var _ox     = irandom_range(-_half_w, _half_w)
                var _eighth_h = _target.sprite_height / 8
                var _oy     = irandom_range(-_eighth_h, _eighth_h)
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
    }

    // Hold on cloud, then fade — skip all consecutive cloud steps at once
    if _timer >= _SPAWN {
        if _persist {
            // Persist mode: set hold and advance immediately
            // Step_0's cloud manager will handle the hold→fade naturally
            if _cloud_hold == 0 and !_cloud_fading {
                _cloud_hold = _cloud_hold_dur
            }
            _cloud_targets = undefined
            while _qi < array_length(_queue) - 1 and _queue[_qi + 1].type == "cloud" {
                _qi++
            }
            _next_step()
        } else {
            if _cloud_hold == 0 and !_cloud_fading {
                _cloud_hold = _cloud_hold_dur
            }
            if _cloud_alpha <= 0 and !_cloud_fading {
                _cloud_targets = undefined
                while _qi < array_length(_queue) - 1 and _queue[_qi + 1].type == "cloud" {
                    _qi++
                }
                _next_step()
            }
        }
    }
}
