var _age        = 1 - (life / max_life)
var _base_alpha = (life / max_life) * 0.9
var _soft       = soft

if !_soft {
    gpu_set_blendmode(bm_add)

    // Trail (burst only)
    var _trail_len = array_length(history)
    for (var _i = 0; _i < _trail_len; _i++) {
        var _h      = history[_i]
        var _t_frac = (_i + 1) / (_trail_len + 1)
        var _talpha = _base_alpha * (1 - _t_frac) * 1.2
        var _ts     = scl * (1 - _t_frac * 0.4)
        var _ts1    = _ts - 1
        // Cross glow
        draw_set_alpha(_talpha * 0.9)
        draw_set_color(col)
        draw_rectangle(_h.x - 1, _h.y,      _h.x + _ts,     _h.y + _ts1,    false)
        draw_rectangle(_h.x,      _h.y - 1, _h.x + _ts1,    _h.y + _ts,     false)
        // Hard pixel
        draw_set_alpha(_talpha)
        draw_set_color(col)
        draw_rectangle(_h.x, _h.y, _h.x + _ts1, _h.y + _ts1, false)
    }

    // Head glow — cross shaped
    var _glow_alpha = (life / max_life) * 0.15 + 0.8
    var _scl1       = scl - 1
    draw_set_alpha(_glow_alpha)
    draw_set_color(col)
    draw_rectangle(x - 1, y,     x + scl,  y + _scl1, false)
    draw_rectangle(x,     y - 1, x + _scl1, y + scl,  false)

    // Head — fullbright white
    draw_set_alpha(1)
    draw_set_color(c_white)
    draw_rectangle(x, y, x + _scl1, y + _scl1, false)
} else {
    // Soft cloud particle — draw to cloud surface
    if variable_global_exists("_cloud_surf") and surface_exists(global._cloud_surf) {
        surface_set_target(global._cloud_surf)
        gpu_set_blendmode(bm_normal)
        var _scl1 = scl - 1
        // Cross glow
        draw_set_alpha(1)
        draw_set_color(col)
        draw_rectangle(x - 1, y,     x + scl,  y + _scl1, false)
        draw_rectangle(x,     y - 1, x + _scl1, y + scl,  false)
        // Core
        draw_set_alpha(1)
        draw_set_color(col)
        draw_rectangle(x, y, x + _scl1, y + _scl1, false)
        surface_reset_target()
    }
}

draw_set_alpha(1)
gpu_set_blendmode(bm_normal)
