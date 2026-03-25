function Anim_Burst() {
    // self = objAnimController instance
    var _center    = !(_step[$ "at_foot"] ?? false)
    var _ox        = _step[$ "offset_x"] ?? 0
    var _oy        = _step[$ "offset_y"] ?? 0
    var _WINDUP    = (_step[$ "windup"] ?? true) ? (_step[$ "windup_duration"] ?? 12) : 0
    var _TOTAL     = max(_step[$ "duration"] ?? 30, _WINDUP + 18)
    var _count     = _step[$ "count"] ?? 44
    var _max_speed = _step[$ "max_speed"] ?? 5
    var _max_scale = _step[$ "max_scale"] ?? 2

    // Background fire: tiny particles rising from target's feet
    var _bg_fire = _step[$ "bg_fire"] ?? false
    if _bg_fire and instance_exists(_target) {
        var _bg_rate  = _step[$ "bg_fire_rate"] ?? 2
        var _bg_life  = _step[$ "bg_fire_life"] ?? 8
        var _bg_width = _step[$ "bg_fire_width"] ?? 0.6
        var _hw = round(_target.sprite_width / 2 * _bg_width)
        var _base_count = (_bg_rate >= 1) ? round(_bg_rate) : (random(1) < _bg_rate ? 1 : 0)
        repeat (_base_count * ANIM_TICK) {
            instance_create_depth(
                _target.x + irandom_range(-_hw, _hw), _target.y,
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

    // Wind-up: drifting sparks near target
    if _timer < _WINDUP and instance_exists(_target) {
        var _spark_count = (_step[$ "spark_count"] ?? 2) * ANIM_TICK
        var _tx = _target.x + _ox
        var _ty = _target.y - (_center ? _target.sprite_height / 2 : 0) + _oy
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

    // Impact
    if _timer >= _WINDUP and !_hit_fired {
        _check_hit()
        var _shake = _step[$ "shake"]
        if !is_undefined(_shake) { ScreenShake(_shake, _step[$ "shake_duration"] ?? 15) }
        if instance_exists(_target) {
            var _tx = _target.x + _ox
            var _ty = _target.y - (_center ? _target.sprite_height / 2 : 0) + _oy
            SpawnBurstParticles(_tx, _ty, _col, _count, _max_speed, _max_scale)
        }
    }

    // Complete
    if _timer >= _TOTAL {
        _finish()
    }
}
