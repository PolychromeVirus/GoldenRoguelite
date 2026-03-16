if !array_contains(global.menu_stack, id) { exit }
draw_sprite_ext(ThreeQuarterMenu, 0, spr_x, spr_y, 6, 6, 0, c_white, 1)

draw_set_font(GoldenSun)

if !is_undefined(draw_header) { draw_header() }

var _num = array_length(global.players)
var _mx  = device_mouse_x_to_gui(0)
var _my  = device_mouse_y_to_gui(0)

for (var _i = 0; _i < _num; _i++) {
    var _col = _i mod 2
    var _row = _i div 2
    var _cx  = gridX + _col * cellW
    var _cy  = gridY + _row * cellStrideY

    var _greyed  = !is_undefined(filter) and filter(_i)
    var _hovered = (using_kbd and _i == kbd_selected)
                    or (!using_kbd and _mx >= _cx and _mx < _cx + cellW and _my >= _cy and _my < _cy + cellH)

    DrawCharCell(_i, _cx, _cy, _greyed, _hovered and !_greyed)
}
