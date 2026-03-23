// Only tick on animation frames (synced to global._anim_clock in objTextManager)
if global._anim_clock != 0 { return }

// Prepare cloud surface for soft particles this frame
var _w = room_width
var _h = room_height
if !variable_global_exists("_cloud_surf") or !surface_exists(global._cloud_surf) {
    global._cloud_surf = surface_create(_w, _h)
}

// Manage cloud alpha — hold, then fade, then kill particles
if _cloud_alpha > 0 and !_cloud_fading {
    // Holding — clear and redraw each frame
    surface_set_target(global._cloud_surf)
    draw_clear_alpha(c_black, 0)
    surface_reset_target()
    if _cloud_hold > 0 {
        _cloud_hold -= ANIM_TICK
        if _cloud_hold <= 0 { _cloud_fading = true }
    }
} else if _cloud_fading {
    // Fading — don't clear surface, just reduce alpha
    _cloud_alpha -= 0.005 * ANIM_TICK
    if _cloud_alpha <= 0 {
        _cloud_alpha  = 0
        _cloud_fading = false
        // Kill all remaining soft particles
        with (objParticle) {
            if soft { instance_destroy() }
        }
    }
}

var _qi_before = _qi
_timer += ANIM_TICK
_tick()
if _qi == _qi_before and _qi < array_length(_queue) { _fire_subs() }

// Fade lingering sprite
if !is_undefined(_fade_spr) {
    _fade_alpha -= 0.03 * ANIM_TICK
    if _fade_alpha <= 0 { _fade_alpha = 0 }
}
