// Screen tint overlay
if _screen_tint_active {
    var _sf_peak = _screen_tint_peak
    var _sf_max  = _screen_tint_max
    var _sf_fade = _screen_tint_fade
    // Only advance tint on animation frames (synced to controllers)
    if global._anim_clock == 0 {
        if _screen_tint_timer < _sf_peak {
            // Fade in
            _screen_tint_alpha = min(_screen_tint_alpha + _sf_max / _sf_peak * ANIM_TICK, _sf_max)
        } else if _screen_tint_timer < _sf_peak + _screen_tint_hold {
            // Hold at max
            _screen_tint_alpha = _sf_max
        } else {
            // Fade out
            _screen_tint_alpha = max(0, _screen_tint_alpha - (_sf_max / _sf_fade) * ANIM_TICK)
        }
        _screen_tint_timer += ANIM_TICK
    }
    if _screen_tint_alpha > 0 {
        draw_set_alpha(_screen_tint_alpha)
        draw_set_color(_screen_tint_color)
        draw_rectangle(0, 0, room_width, room_height, false)
        draw_set_alpha(1)
    } else if _screen_tint_timer >= _sf_peak + _screen_tint_hold {
        _screen_tint_active = false
    }
}

// Cloud surface composite
if _cloud_alpha > 0 and variable_global_exists("_cloud_surf") and surface_exists(global._cloud_surf) {
    gpu_set_blendmode(bm_normal)
    draw_surface_ext(global._cloud_surf, 0, 0, 1, 1, 0, c_white, _cloud_alpha)
    gpu_set_blendmode(bm_normal)
}
