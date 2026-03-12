var yoff = string_height(damvis)
var disx = window_get_width()-(x/room_width)
var disy = window_get_height()-(y/room_height)

if drawdam{
	draw_set_font(GoldenSun)
	draw_set_halign(fa_center)
	draw_set_color(c_black)
	draw_text(disx+4, disy-sprite_height-yoff+4,string(damvis))
	draw_set_color(c_white)
	draw_text(disx, disy-sprite_height-yoff,string(damvis))
	draw_set_halign(fa_left)
}