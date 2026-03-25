function Anim_Sprite_Tick() {
    // self = objAnimController instance
    var _spr       = _step.spr
    var _speed     = _step[$ "speed"] ?? 1
    var _hold      = _step[$ "hold"] ?? 20
    var _total     = sprite_get_number(_spr)
    var _hit_frame = _step[$ "hit_frame"] ?? _total - 1
    var _cur_frame = floor(_timer / _speed)

    // Fire on_hit at hit_frame
    if _cur_frame >= _hit_frame and !_hit_fired {
        _check_hit()
    }

    // Advance after hold completes — leave a fading ghost behind
    if _hit_fired and _timer >= _hit_frame * _speed + _hold {
        _fade_spr    = _spr
        _fade_frame  = _hit_frame
        _fade_blend  = _step[$ "blend"] ?? "normal"
        _fade_tx     = _target.x
        _fade_ty     = _target.y
        _fade_alpha  = 1
        _finish()
    }
}

function Anim_Sprite_Draw() {
    // self = objAnimController instance
    if !instance_exists(_target) { return }
    var _spr       = _step.spr
    var _speed     = _step[$ "speed"] ?? 1
    var _hit_frame = _step[$ "hit_frame"] ?? sprite_get_number(_spr) - 1
    var _cur_frame = min(floor(_timer / _speed), _hit_frame)
    var _blend     = _step[$ "blend"] ?? "normal"

    if _blend == "multiply" {
        gpu_set_blendmode_ext(bm_dest_colour, bm_zero)
    } else if _blend == "add" {
        gpu_set_blendmode(bm_add)
    } else {
        gpu_set_blendmode(bm_normal)
    }
    draw_sprite(_spr, _cur_frame, _target.x, _target.y)
    gpu_set_blendmode(bm_normal)
}
