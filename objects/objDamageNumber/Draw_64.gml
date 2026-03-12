var _gui_x, _gui_y

if gui_mode {
	// Already in GUI coordinates — rise in GUI pixels
	_gui_x = world_x
	_gui_y = world_y + rise
	rise += 0.5
} else {
	// Convert world position to GUI position
	// View is 256x152, port is 1536x912 → scale factor 6
	var _cam = view_camera[0]
	var _vw = camera_get_view_width(_cam)
	var _vh = camera_get_view_height(_cam)
	var _gw = display_get_gui_width()
	var _gh = display_get_gui_height()
	var _sx = _gw / _vw
	var _sy = _gh / _vh

	_gui_x = world_x * _sx
	_gui_y = (world_y + rise) * _sy
	rise -= 0.3
}
life--
if life <= 10 { alpha = life / 10 }
if life <= 0 { instance_destroy(); exit }

draw_set_alpha(alpha)

if icon != -1 {
	// Sprite mode: draw an icon instead of text
	draw_sprite_stretched_ext(icon, 0, _gui_x - 16, _gui_y - 16, 32, 32, col, alpha)
} else {
	// Text mode: draw damage number
	draw_set_font(GoldenSun)
	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)

	// Shadow
	draw_set_color(c_black)
	draw_text(_gui_x + 3, _gui_y + 3, string(amount))
	// Number
	draw_set_color(col)
	draw_text(_gui_x, _gui_y, string(amount))

	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
}

draw_set_alpha(1)
