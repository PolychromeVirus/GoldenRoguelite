var _sw = sprite_get_width(sprite_index)
var _sh = sprite_get_height(sprite_index)
var _cx = x + _sw * 0.5
var _cy = y + _sh * 0.5
draw_sprite_stretched_ext(sprite_index, image_index,
    _cx - _sw * btn_scale * 0.5,
    _cy - _sh * btn_scale * 0.5,
    _sw * btn_scale,
    _sh * btn_scale,
    image_blend, image_alpha)
