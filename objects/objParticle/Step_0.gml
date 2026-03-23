// Only tick on animation frames
if global._anim_clock != 0 { return }

// Record position before moving
array_insert(history, 0, { x: x, y: y })
if array_length(history) > trail { array_delete(history, trail, 1) }

// Move scaled by tick rate so speed stays consistent
var _t = ANIM_TICK
x  += vx * _t
y  += vy * _t
if soft {
    // Cloud particles: wiggle left/right
    if irandom(15) == 0 { vx = -vx }
} else {
    // Burst particles: decelerate
    var _drag = power(0.99, _t)
    vx *= _drag
    vy *= _drag
}
vy += grav * _t
// Wiggle — gentle horizontal sine sway
if wiggle != 0 {
    wiggle_t += wiggle_spd * _t
    x += sin(wiggle_t) * wiggle * _t
}
// Oscillation — position-based swirl around spawn point
if osc_amp != 0 {
    osc_phase += osc_speed * _t
    x = osc_cx + osc_amp * sin(osc_phase)
    y = osc_cy + osc_y * -cos(osc_phase)
}
life -= _t
if shrink {
    scl = max(0, scl * (life / max_life))
}
if life <= 0 { instance_destroy() }
if !is_undefined(die_y) {
    if (vy >= 0 and y >= die_y) or (vy < 0 and y <= die_y) { instance_destroy() }
}
