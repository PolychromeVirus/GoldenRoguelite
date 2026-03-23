var _gui_x, _gui_y

if gui_mode {
	_gui_x = world_x
	_gui_y = world_y + rise
} else {
	var _cam = view_camera[0]
	var _vw = camera_get_view_width(_cam)
	var _vh = camera_get_view_height(_cam)
	var _gw = display_get_gui_width()
	var _gh = display_get_gui_height()
	var _sx = _gw / _vw
	var _sy = _gh / _vh

	_gui_x = world_x * _sx
	_gui_y = (world_y + rise) * _sy
}
life--
if life <= 10 { alpha = life / 10 }
if life <= 0 { instance_destroy(); exit }

if !no_rise {
	if gui_mode { rise += 0.5 } else { rise -= 0.3 }
}

draw_set_alpha(alpha)

if icon != -1 {
	// Sprite mode: draw an icon instead of text
	draw_sprite_stretched_ext(icon, 0, _gui_x - 16, _gui_y - 16, 32, 32, col, alpha)
} else {
	// Text mode: draw damage number or text string
	draw_set_font(GoldenSun)
	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)

	var _str = (text != "") ? text : string(amount)

	// Shadow
	draw_set_color(c_black)
	draw_text(_gui_x + 3, _gui_y + 3, _str)
	// Text
	draw_set_color(col)
	draw_text(_gui_x, _gui_y, _str)

	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
}

draw_set_alpha(1)
