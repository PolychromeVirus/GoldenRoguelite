function Anim_Meteor_Tick() {
    // self = objAnimController instance
    var _speed      = _step[$ "speed"] ?? 2.5
    var _power      = _step[$ "power"] ?? 10
    var _scale      = clamp(_power / 10, 0.5, 4)
    var _no_burst   = _step[$ "no_burst"] ?? false
    var _trail_life = _step[$ "trail_life"] ?? 15
    var _trail_len  = _step[$ "trail"] ?? 6
    var _accel      = _step[$ "accel"] ?? 0.08
    var _fire       = _step[$ "fire"] ?? false
    var _fire_hold  = _step[$ "fire_hold"] ?? 60
    var _fire_rate  = _step[$ "fire_rate"] ?? 3
    var _fire_trail = _step[$ "fire_trail"] ?? 12
    var _linger     = _step[$ "linger"] ?? 30
    var _impact_foot = _step[$ "impact_foot"] ?? false
    var _spread_x   = _step[$ "spread_x"] ?? 4

    var _barrage    = _step[$ "barrage"] ?? 0
    var _stagger_m  = _step[$ "stagger"] ?? 0

    // Initialize meteors on first tick
    if _timer <= ANIM_TICK {
        _meteors = []
        _meteors_done = 0
        if _barrage > 0 {
            // Barrage mode: N meteors each hitting a random target from _all_targets
            for (var _bi = 0; _bi < _barrage; _bi++) {
                var _pick = _all_targets[irandom(array_length(_all_targets) - 1)]
                if !instance_exists(_pick) { continue }
                array_push(_meteors, {
                    target: _pick,
                    tx: _pick.x + irandom_range(-_spread_x, _spread_x),
                    impact_y: _impact_foot ? _pick.y : _pick.y - _pick.sprite_height / 2,
                    my: -10, vy: _speed, hit: false, hit_frame: 0,
                    spawn_at: _bi * _stagger_m,
                    fires_hit: _step[$ "fires_hit"] ?? false,
                })
            }
        } else {
            // Single meteor on _target
            if instance_exists(_target) {
                array_push(_meteors, {
                    target: _target,
                    tx: _target.x + irandom_range(-_spread_x, _spread_x),
                    impact_y: _impact_foot ? _target.y : _target.y - _target.sprite_height / 2,
                    my: -10, vy: _speed, hit: false, hit_frame: 0,
                    spawn_at: 0,
                    fires_hit: _step[$ "fires_hit"] ?? false,
                })
            }
        }
    }

    if !variable_instance_exists(id, "_meteors") { return }

    // Update each meteor
    for (var _mi = 0; _mi < array_length(_meteors); _mi++) {
        var _m = _meteors[_mi]
        if _timer < _m.spawn_at { continue }
        if _m.my < -900 and _m.hit and !_fire { continue }

        if !_m.hit {
            _m.my += _m.vy
            _m.vy += _accel

            // Trail particles
            if _m.my < _m.impact_y {
                var _trail_rate = max(1, round(3 * _scale))
                repeat (_trail_rate) {
                    var _spread = round(2 * _scale)
                    instance_create_depth(
                        _m.tx + irandom_range(-_spread, _spread),
                        _m.my,
                        100, objParticle, {
                            vx:   -0.3 + random(0.6),
                            vy:   -(0.1 + random(0.3)),
                            grav: 0.02,
                            life: _trail_life + irandom(10),
                            col:  _col,
                            scl:  1 + irandom(round(_scale)),
                            trail: _trail_len,
                            spr:  sprCirclePart,
                        })
                }
            }

            // Impact
            if _m.my >= _m.impact_y {
                _m.hit = true
                _m.hit_frame = _timer
                if !_hit_fired {
                    _hit_fired = true; _hit_timer = _timer
                    var _sfx = _step[$ "sfx"]
                    if !is_undefined(_sfx) { audio_stop_sound(_sfx); audio_play_sound(_sfx, 0, 0) }
                }
                // Per-meteor damage for barrage
                if _m.fires_hit and !is_undefined(_packet) {
                    var _pkt_copy = variable_clone(_packet)
                    _pkt_copy.targets = [_m.target]
                    DoDamage(_pkt_copy)
                }
                var _shake = _step[$ "shake"]
                if !is_undefined(_shake) { ScreenShake(_shake, _step[$ "shake_duration"] ?? 15) }
                if !_no_burst {
                    var _count     = _step[$ "count"] ?? round(20 + _power * 3)
                    var _max_speed = _step[$ "max_speed"] ?? 3 + _scale * 2
                    var _max_scale = _step[$ "max_scale"] ?? round(1 + _scale)
                    SpawnBurstParticles(_m.target.x, _m.impact_y, _col, _count, _max_speed, _max_scale)
                }
                _m.my = -999
            }
        }

        // Continuous fire after impact
        if _fire and _m.hit and instance_exists(_m.target) {
            var _since = _timer - _m.hit_frame
            if _since >= 0 and _since <= _fire_hold {
                var _half_w = _m.target.sprite_width / 4
                var _sh = _m.target.sprite_height
                repeat (_fire_rate) {
                    var _ox = irandom_range(-_half_w, _half_w)
                    var _oy = irandom_range(0, floor(_sh * 0.3))
                    var _spd = _sh / 80 + random(_sh / 60)
                    instance_create_depth(
                        _m.target.x + _ox, _m.target.y - _oy,
                        100, objParticle, {
                            vx:   -0.2 + random(0.4),
                            vy:   -_spd,
                            grav: -0.02,
                            life: 70 + irandom(40),
                            col:  _col,
                            scl:  2 + irandom(3),
                            trail: _fire_trail,
                            shrink: true,
                            spr:  sprCirclePart,
                        })
                }
            }
        }
    }

    // Complete — all meteors must have hit and lingered
    var _all_done = true
    for (var _mi = 0; _mi < array_length(_meteors); _mi++) {
        var _m = _meteors[_mi]
        if !_m.hit { _all_done = false; break }
        var _wait = _fire ? _fire_hold + _linger : _linger
        if _timer < _m.hit_frame + _wait { _all_done = false; break }
    }
    if _all_done {
        _finish()
    }
}

function Anim_Meteor_Draw() {
    // self = objAnimController instance
    if !variable_instance_exists(id, "_meteors") { return }

    var _power = _step[$ "power"] ?? 10
    var _s     = clamp(_power / 10, 0.5, 4)
    var _r     = round(2 * _s)
    var _g     = round(3 * _s)

    gpu_set_blendmode(bm_add)
    for (var _mi = 0; _mi < array_length(_meteors); _mi++) {
        var _m = _meteors[_mi]
        if _m.my < -900 { continue }
        if _timer < _m.spawn_at { continue }

        var _mx = _m.tx
        var _my = _m.my

        draw_set_alpha(0.6)
        draw_set_color(_col)
        draw_rectangle(_mx - _g, _my - _r, _mx + _g - 1, _my + _r - 1, false)
        draw_rectangle(_mx - _r, _my - _g, _mx + _r - 1, _my + _g - 1, false)

        draw_set_alpha(1)
        draw_set_color(c_white)
        draw_rectangle(_mx - _r, _my - _r, _mx + _r - 1, _my + _r - 1, false)
    }
    draw_set_alpha(1)
    gpu_set_blendmode(bm_normal)
}
