if !array_contains(global.menu_stack, id) { exit }
draw_sprite_ext(TestMenu, 0, 0, 0, 6, 6, 0, c_white, 1)

draw_set_font(GoldenSun)

var _cx = display_get_gui_width() div 2
var _cy = display_get_gui_height() div 2 - 20
var _offset = 4
var _w = max(string_width(text), (subtext != "") ? string_width(subtext) : 0, 200) / 2 + 16
var _h = (subtext != "") ? 50 : 30

draw_set_alpha(0.85)
draw_rectangle_color(_cx - _w, _cy - _h, _cx + _w, _cy + _h, c_black, c_black, c_black, c_black, false)
draw_set_alpha(1)
draw_rectangle_color(_cx - _w, _cy - _h, _cx + _w, _cy + _h, c_white, c_white, c_white, c_white, true)

draw_set_halign(fa_center)
draw_set_valign(fa_middle)

if subtext != "" {
    draw_set_color(c_white)
    draw_text(_cx, _cy - 21, text)
    draw_set_color(c_yellow)
    draw_text(_cx, _cy + 21, subtext)
} else {
    draw_set_color(c_white)
    draw_text(_cx, _cy, text)
}

draw_set_halign(fa_left)
draw_set_valign(fa_top)
draw_set_color(c_white)
