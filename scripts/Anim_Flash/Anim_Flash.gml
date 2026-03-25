function Anim_Flash_Tick() {
    // self = objAnimController instance
    var _TOTAL = _step[$ "hold"] ?? 20

    _check_hit()

    // Glint: random white flash on frozen targets
    var _glint = _step[$ "glint"] ?? false
    if _glint {
        var _interval = _step[$ "glint_interval"] ?? 10
        if _timer mod _interval == 0 {
            for (var _i = 0; _i < array_length(_all_targets); _i++) {
                var _gt = _all_targets[_i]
                if instance_exists(_gt) and irandom(2) == 0 {
                    _gt.flash_timer = 1
                }
            }
        }
    }

    if _timer >= _TOTAL {
        _finish()
    }
}

function Anim_Flash_Draw() {
    // self = objAnimController instance
    var _TOTAL = _step[$ "hold"] ?? 20
    var _PEAK  = _step[$ "peak"] ?? 3
    var _max_alpha = _step[$ "alpha"] ?? 0.5

    var _sustain = _step[$ "sustain"] ?? false
    var _alpha
    if _timer <= _PEAK {
        _alpha = _timer / _PEAK
    } else if _sustain {
        _alpha = 1
    } else {
        _alpha = 1 - ((_timer - _PEAK) / (_TOTAL - _PEAK))
    }
    _alpha = clamp(_alpha, 0, 1)

    var _blend = _step[$ "blend"] ?? "add"
    if _blend == "normal" {
        gpu_set_blendmode(bm_normal)
    } else {
        gpu_set_blendmode(bm_add)
    }
    draw_set_alpha(_alpha * _max_alpha)
    draw_set_color(_col)
    draw_rectangle(0, 0, room_width, room_height, false)
    draw_set_alpha(1)
    gpu_set_blendmode(bm_normal)
}
