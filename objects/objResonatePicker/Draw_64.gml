draw_set_font(GoldenSun)

var cx = display_get_gui_width() div 2
var cy = display_get_gui_height() div 2 - 20
var _w = (string_width("Resonate: Boost Range or Damage?") + 16)/2
var _h = 50
var offset = 4

draw_set_alpha(0.85)
draw_rectangle_color(cx - _w, cy - _h, cx + _w, cy + _h, c_black, c_black, c_black, c_black, false)
draw_set_alpha(1)
draw_rectangle_color(cx - _w, cy - _h, cx + _w, cy + _h, c_white, c_white, c_white, c_white, true)

draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_set_color(c_white)
draw_text(cx, cy - 21, "Resonate: Boost Range or Damage?")
draw_set_color(c_yellow)
draw_text(cx, cy + 21, "(Value: +" + string(res_value) + ")")
draw_set_halign(fa_left)
draw_set_valign(fa_top)
draw_set_color(c_white)
