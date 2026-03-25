/// @func SpawnBurstParticles(x, y, col, count, max_speed, max_scale, [trail])
/// @desc Spawn a radial burst of particles
function SpawnBurstParticles(_x, _y, _col, _count, _max_speed, _max_scale, _trail = undefined) {
    repeat (_count) {
        var _angle = irandom(359)
        var _spd   = 1 + random(_max_speed)
        var _p = { vx: lengthdir_x(_spd, _angle), vy: lengthdir_y(_spd, _angle),
            grav: 0.04, life: 120 + irandom(60),
            col: _col, scl: 1 + irandom(_max_scale), spr: sprCirclePart }
        if !is_undefined(_trail) { _p.trail = _trail }
        instance_create_depth(_x, _y, 100, objParticle, _p)
    }
}

/// @func SpawnFireParticles(x, y, col, count, half_w)
/// @desc Spawn rising fire particles at a target's feet
function SpawnFireParticles(_x, _y, _col, _count, _half_w) {
    repeat (_count) {
        var _ox = irandom_range(-_half_w, _half_w)
        instance_create_depth(_x + _ox, _y, 100, objParticle, {
            vx: -0.2 + random(0.4),
            vy: -(0.5 + random(1.0)),
            grav: -0.02, life: 80 + irandom(40),
            col: _col, scl: 1 + irandom(3),
            trail: 40, spr: sprCirclePart,
        })
    }
}

/// @func PlayAnimation(on_hit, on_complete)
/// @desc Legacy wrapper — converts QueueAnim entries into AnimPlay layers.
///       on_hit is ignored in the new system (damage fires via packet).
function PlayAnimation(on_hit, on_complete) {
    var _q = global.animQueue
    global.animQueue = []
    // Convert queue entries to layers — each entry becomes a single-target layer
    var _layers = []
    for (var _i = 0; _i < array_length(_q); _i++) {
        var _entry = _q[_i]
        _entry.mode = "single"
        array_push(_layers, _entry)
    }
    if array_length(_layers) == 0 {
        on_complete()
        return
    }
    AnimPlay(_layers, undefined, on_complete)
}
