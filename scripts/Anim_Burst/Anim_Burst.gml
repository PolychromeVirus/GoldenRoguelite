function Anim_Burst() {
    // self = objSpellAnimation instance
    var _step      = _queue[_qi]
    var _simul     = _step[$ "simultaneous"] ?? false
    var _center    = !(_step[$ "at_foot"] ?? false)
    var _ox        = _step[$ "offset_x"] ?? 0
    var _oy        = _step[$ "offset_y"] ?? 0
    var _WINDUP    = (_step[$ "windup"] ?? true) ? (_step[$ "windup_duration"] ?? 12) : 0
    var _TOTAL     = _step[$ "duration"] ?? 30
    var _count     = _step[$ "count"] ?? 44
    var _max_speed = _step[$ "max_speed"] ?? 5
    var _max_scale = _step[$ "max_scale"] ?? 2

    // Gather targets — single or all consecutive bursts
    var _targets = []
    if _simul {
        for (var _q = _qi; _q < array_length(_queue); _q++) {
            if _queue[_q].type != "burst" { break }
            array_push(_targets, _queue[_q].target)
        }
    } else {
        array_push(_targets, _step.target)
    }

    // Background fire: tiny particles rising from ALL enemy feet continuously
    var _bg_fire = _step[$ "bg_fire"] ?? false
    if _bg_fire {
        var _bg_rate  = _step[$ "bg_fire_rate"] ?? 2
        var _bg_life  = _step[$ "bg_fire_life"] ?? 8
        var _bg_width = _step[$ "bg_fire_width"] ?? 0.6
        var _mcount   = instance_number(objMonster)
        for (var _mi = 0; _mi < _mcount; _mi++) {
            var _m = instance_find(objMonster, _mi)
            if _m.monsterHealth <= 0 { continue }
            var _hw = round(_m.sprite_width / 2 * _bg_width)
            var _base_count = (_bg_rate >= 1) ? round(_bg_rate) : (random(1) < _bg_rate ? 1 : 0)
            repeat (_base_count * ANIM_TICK) {
                instance_create_depth(
                    _m.x + irandom_range(-_hw, _hw), _m.y,
                    100, objParticle, {
                        vx: -0.1 + random(0.2),
                        vy: -(0.1 + random(0.2)),
                        grav: -0.01,
                        life: _bg_life + irandom(4),
                        col: _col,
                        scl: 1, trail: 0,
                        spr: sprCirclePart,
                    })
            }
        }
    }

    // Wind-up: drifting sparks near all targets
    if _timer < _WINDUP {
        var _spark_count = (_step[$ "spark_count"] ?? 2) * ANIM_TICK
        for (var _ti = 0; _ti < array_length(_targets); _ti++) {
            var _t  = _targets[_ti]
            var _tx = _t.x + _ox
            var _ty = _t.y - (_center ? _t.sprite_height / 2 : 0) + _oy
            repeat (_spark_count) {
                var _angle = irandom(359)
                var _dist  = 3 + irandom(5)
                instance_create_depth(
                    _tx + lengthdir_x(_dist, _angle),
                    _ty + lengthdir_y(_dist, _angle),
                    0, objParticle, {
                        vx:   lengthdir_x(0.2 + random(0.3), _angle + 180),
                        vy:   lengthdir_y(0.2 + random(0.3), _angle + 180),
                        grav: 0,
                        life: 30 + irandom(20),
                        col:  merge_color(c_black, _col, 0.6 + random(0.4)),
                        scl:  1 + random(1),
                        spr:  sprCirclePart,
                    })
            }
        }
    }

    // Impact — all targets at once
    if _timer >= _WINDUP and !_hit_fired {
        _hit_fired = true
        _hit_timer = _timer
        if _step[$ "fires_hit"] ?? false { _on_hit() }
        var _shake = _step[$ "shake"]
        if !is_undefined(_shake) { ScreenShake(_shake, _step[$ "shake_duration"] ?? 15) }
        for (var _ti = 0; _ti < array_length(_targets); _ti++) {
            var _t  = _targets[_ti]
            var _tx = _t.x + _ox
            var _ty = _t.y - (_center ? _t.sprite_height / 2 : 0) + _oy
            SpawnBurstParticles(_tx, _ty, _col, _count, _max_speed, _max_scale)
        }
    }

    // Complete
    if _simul {
        // Skip past all burst steps at once
        if _timer >= _TOTAL {
            var _last = _qi
            while _last < array_length(_queue) - 1 and _queue[_last + 1].type == "burst" {
                _last++
            }
            _qi = _last
            _next_step()
        }
    } else {
        // Stagger across targets
        var _is_last = (_qi >= array_length(_queue) - 1)
        var _stagger = _step[$ "stagger"] ?? 8
        var _end = _is_last ? _TOTAL : max(_WINDUP + _stagger, _stagger)
        if _timer >= _end {
            _next_step()
        }
    }
}
