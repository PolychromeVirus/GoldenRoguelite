function Anim_Meteor_Tick() {
    var _step       = _queue[_qi]
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
    var _stagger    = _step[$ "stagger"] ?? 0
    var _impact_foot = _step[$ "impact_foot"] ?? false

    // Initialize meteors array
    var _barrage    = _step[$ "barrage"] ?? 0
    var _spread_x   = _step[$ "spread_x"] ?? 4
    if _timer <= ANIM_TICK {
        _meteors = []
        _meteors_done = 0
        // Gather all consecutive meteor targets
        var _targets = []
        var _last_q = _qi
        for (var _q = _qi; _q < array_length(_queue); _q++) {
            var _s = _queue[_q]
            if _s.type != "meteor" { break }
            array_push(_targets, _s)
            _last_q = _q
        }
        if _barrage > 0 {
            // Barrage mode: N meteors each hitting a random target
            for (var _bi = 0; _bi < _barrage; _bi++) {
                var _pick = _targets[irandom(array_length(_targets) - 1)]
                var _t = _pick.target
                array_push(_meteors, {
                    target: _t,
                    tx: _t.x + irandom_range(-_spread_x, _spread_x),
                    impact_y: _impact_foot ? _t.y : _t.y - _t.sprite_height / 2,
                    my: -10,
                    vy: _speed,
                    hit: false,
                    hit_frame: 0,
                    spawn_at: _bi * _stagger,
                    queue_index: _qi,
                    fires_hit: _step[$ "fires_hit"] ?? true,
                    stagger_target_index: _pick[$ "_stagger_target_index"] ?? 0,
                })
            }
        } else {
            // Normal mode: one meteor per queued target
            for (var _q = _qi; _q < array_length(_queue); _q++) {
                var _s = _queue[_q]
                if _s.type != "meteor" { break }
                var _t = _s.target
                var _idx = _q - _qi
                array_push(_meteors, {
                    target: _t,
                    tx: _t.x + irandom_range(-_spread_x, _spread_x),
                    impact_y: _impact_foot ? _t.y : _t.y - _t.sprite_height / 2,
                    my: -10,
                    vy: _speed,
                    hit: false,
                    hit_frame: 0,
                    spawn_at: _idx * _stagger,
                    queue_index: _q,
                    fires_hit: _s[$ "fires_hit"] ?? false,
                    stagger_target_index: _s[$ "_stagger_target_index"] ?? 0,
                })
            }
        }
    }

    // Update each meteor
    for (var _mi = 0; _mi < array_length(_meteors); _mi++) {
        var _m = _meteors[_mi]
        if _timer < _m.spawn_at { continue }  // not yet spawned
        if _m.my < -900 and _m.hit and !_fire { continue }  // already done (skip if no fire)

        // Move
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
                // Set instance-level hit state for sub-effects
                if !_hit_fired { _hit_fired = true; _hit_timer = _timer }
                // Store current meteor's target for barrage on_hit callbacks
                _barrage_hit_target = _m.target
                if _m.fires_hit { _on_hit() }
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
        if _fire and _m.hit {
            var _since = _timer - _m.hit_frame
            if _since >= 0 and _since <= _fire_hold {
                var _half_w = _m.target.sprite_width / 3
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
                            life: 60 + irandom(30),
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
        // Skip past all consecutive meteor steps
        var _last = _qi
        while _last < array_length(_queue) - 1 and _queue[_last + 1].type == "meteor" {
            _last++
        }
        _qi = _last
        _next_step()
    }
}

function Anim_Meteor_Draw() {
    if !variable_instance_exists(id, "_meteors") { return }

    var _step  = _queue[_qi]
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

        // Outer glow — cross
        draw_set_alpha(0.6)
        draw_set_color(_col)
        draw_rectangle(_mx - _g, _my - _r, _mx + _g - 1, _my + _r - 1, false)
        draw_rectangle(_mx - _r, _my - _g, _mx + _r - 1, _my + _g - 1, false)

        // Core — white
        draw_set_alpha(1)
        draw_set_color(c_white)
        draw_rectangle(_mx - _r, _my - _r, _mx + _r - 1, _my + _r - 1, false)
    }

    draw_set_alpha(1)
    gpu_set_blendmode(bm_normal)
}
