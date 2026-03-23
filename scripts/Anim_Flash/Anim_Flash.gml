function Anim_Flash_Tick() {
    var _step  = _queue[_qi]
    var _TOTAL = _step[$ "hold"] ?? 20

    _check_hit()

    // Glint: random white flash on frozen targets (reuses monster flash_timer)
    var _glint = _step[$ "glint"] ?? false
    if _glint {
        var _interval = _step[$ "glint_interval"] ?? 10
        if _timer mod _interval == 0 {
            // Gather all consecutive same-type targets
            for (var _gq = _qi; _gq < array_length(_queue); _gq++) {
                if _gq != _qi and _queue[_gq].type != _step.type { break }
                var _gt = _queue[_gq].target
                if instance_exists(_gt) and irandom(2) == 0 {
                    _gt.flash_timer = 1
                }
            }
        }
    }

    var _stagger = _step[$ "stagger"] ?? undefined
    if is_undefined(_stagger) {
        if _timer >= _TOTAL {
            // Skip past all consecutive flash steps
            while _qi < array_length(_queue) - 1 and _queue[_qi + 1].type == "flash" {
                _qi++
            }
            _next_step()
        }
    } else {
        var _is_last = (_qi >= array_length(_queue) - 1) or (_queue[_qi + 1].type != "flash")
        var _end = _is_last ? _TOTAL : _stagger
        if _timer >= _end {
            if !_hit_fired and (_step[$ "fires_hit"] ?? false) {
                _hit_fired = true
                _on_hit()
            }
            _next_step()
        }
    }
}

function Anim_Flash_Draw() {
    var _step  = _queue[_qi]
    var _TOTAL = _step[$ "hold"] ?? 20
    var _PEAK  = _step[$ "peak"] ?? 3
    var _max_alpha = _step[$ "alpha"] ?? 0.5

    // Sharp flash in, smooth fade out (sustain holds at max until end)
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
