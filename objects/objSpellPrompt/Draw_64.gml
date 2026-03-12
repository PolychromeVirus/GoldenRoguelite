draw_set_font(GoldenSun)
var _cx = display_get_gui_width() div 2
var _cy = display_get_gui_height() div 2 - 20
var _w = max(string_width(caster_name + ": Cast " + spell_name + "?"),string_width("(Cost: " + string(pp_cost) + " PP)"))+8
var _h = 72



draw_set_alpha(0.85)
draw_rectangle_color(_cx - _w, _cy - _h, _cx + _w, _cy + _h, c_black, c_black, c_black, c_black, false)
draw_set_alpha(1)
draw_rectangle_color(_cx - _w, _cy - _h, _cx + _w, _cy + _h, c_white, c_white, c_white, c_white, true)

draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_set_color(c_white)
draw_text(_cx, _cy - 21, caster_name + ": Cast " + spell_name + "?")
draw_set_color(c_yellow)
draw_text(_cx, _cy + 21, "(Cost: " + string(pp_cost) + " PP)")
draw_set_halign(fa_left)
draw_set_valign(fa_top)
draw_set_color(c_white)