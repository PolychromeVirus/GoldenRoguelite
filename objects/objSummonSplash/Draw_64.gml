var _cx = display_get_gui_width() / 2
var _cy = display_get_gui_height() / 2
draw_sprite_ext(spr, 0, _cx, _cy, 4, 4, 0, c_white, alpha)
life--
if (life <= 15) { alpha = life / 15 }
if (life <= 0) { instance_destroy() }
