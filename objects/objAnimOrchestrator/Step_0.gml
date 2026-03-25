// Only tick on animation frames
if global._anim_clock != 0 { return }

// Prepare cloud surface for soft particles this frame
var _w = room_width
var _h = room_height
if !variable_global_exists("_cloud_surf") or !surface_exists(global._cloud_surf) {
    global._cloud_surf = surface_create(_w, _h)
}

// Manage cloud alpha — hold, then fade, then kill particles
if _cloud_alpha > 0 and !_cloud_fading {
    surface_set_target(global._cloud_surf)
    draw_clear_alpha(c_black, 0)
    surface_reset_target()
    if _cloud_hold > 0 {
        _cloud_hold -= ANIM_TICK
        if _cloud_hold <= 0 { _cloud_fading = true }
    }
} else if _cloud_fading {
    _cloud_alpha -= 0.005 * ANIM_TICK
    if _cloud_alpha <= 0 {
        _cloud_alpha  = 0
        _cloud_fading = false
        with (objParticle) {
            if soft { instance_destroy() }
        }
    }
}

// Check if all controllers done and cloud has faded
if _done_count >= _total_count and _cloud_alpha <= 0 {
    _complete()
}
