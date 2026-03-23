_draw()

// Sub-flash overlay (slow-fading screen tint from sub-effects)
if variable_instance_exists(id, "_sub_flash_timer") and is_numeric(_sub_flash_timer) {
    // Ramp up quickly, fade out slowly
    var _sf_peak = 6
    var _sf_max = 0.4
    if _sub_flash_timer < _sf_peak {
        _sub_flash_alpha = min((_sub_flash_alpha ?? 0) + _sf_max / _sf_peak * ANIM_TICK, _sf_max)
    } else {
        _sub_flash_alpha = max(0, (_sub_flash_alpha ?? 0) - (_sf_max / _sub_flash_hold) * ANIM_TICK)
    }
    _sub_flash_timer += ANIM_TICK
    if _sub_flash_alpha > 0 {
        draw_set_alpha(_sub_flash_alpha)
        draw_set_color(_sub_flash_col)
        draw_rectangle(0, 0, room_width, room_height, false)
        draw_set_alpha(1)
    } else {
        variable_instance_set(id, "_sub_flash_timer", undefined)
    }
}

// Fading lingering sprite from a previous step
if !is_undefined(_fade_spr) and _fade_alpha > 0 {
    if _fade_blend == "multiply" {
        gpu_set_blendmode_ext(bm_dest_colour, bm_zero)
    } else if _fade_blend == "add" {
        gpu_set_blendmode(bm_add)
    }
    draw_sprite_ext(_fade_spr, _fade_frame, _fade_tx, _fade_ty, 1, 1, 0, c_white, _fade_alpha)
    gpu_set_blendmode(bm_normal)
}

// Composite cloud surface — draws at depth 50 (behind mask, after all particles at 100)
if _cloud_alpha > 0 and variable_global_exists("_cloud_surf") and surface_exists(global._cloud_surf) {
    gpu_set_blendmode(bm_normal)
    draw_surface_ext(global._cloud_surf, 0, 0, 1, 1, 0, c_white, _cloud_alpha)
    gpu_set_blendmode(bm_normal)
}
