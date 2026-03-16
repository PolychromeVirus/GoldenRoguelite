if !array_contains(global.menu_stack, id) { exit }
draw_sprite_ext(TestMenu, 0, 0, 0, 6, 6, 0, c_white, 1)

draw_set_font(GoldenSun)

var _cx = 400
var _cy = 300
var _offset = 4

var _lbl = label(value)
draw_set_color(c_black)
draw_text(_cx + _offset, _cy + _offset, _lbl)
draw_set_color(c_white)
draw_text(_cx, _cy, _lbl)

if !is_undefined(preview) {
    var _prev = preview(value)
    draw_set_color(c_black)
    draw_text(_cx + _offset, _cy + 40 + _offset, _prev)
    draw_set_color(c_yellow)
    draw_text(_cx, _cy + 40, _prev)
}
