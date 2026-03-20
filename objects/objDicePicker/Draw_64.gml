if !array_contains(global.menu_stack, id) { exit }
if !visible {exit}
draw_sprite_ext(ThreeQuarterMenu, 0, spr_x, spr_y, 6, 6, 0, c_white, 1)

draw_set_font(GoldenSun)

var _dicesize = 52
var _dicepad  = 10
var _startx   = spr_x + 50
var _starty   = spr_y + 80
var _mx       = device_mouse_x_to_gui(0)
var _my       = device_mouse_y_to_gui(0)

// Title
if title != "" {
    draw_set_color(c_black)
    draw_text(_startx + 4, _starty - 36 + 4, title)
    draw_set_color(c_white)
    draw_text(_startx, _starty - 36, title)
}

var _cx = _startx
for (var _i = 0; _i < array_length(dice); _i++) {
    var _d = dice[_i]

    // Determine highlight state
    var _active = (max_select == 1)
                  ? (_i == kbd_selected)
                  : _d.selected
    var _hovered = (_mx >= _cx and _mx < _cx + _dicesize and _my >= _starty and _my < _starty + _dicesize)

    // Fill colour — bright if active/hovered, dim otherwise
    var _col = _d.col
    if !_active and !_hovered {
        var _r = (_col & 0xFF)
        var _g = ((_col >> 8) & 0xFF)
        var _b = ((_col >> 16) & 0xFF)
        _col = make_color_rgb(floor(_r * 0.35), floor(_g * 0.35), floor(_b * 0.35))
    }

    draw_rectangle_color(_cx, _starty, _cx + _dicesize, _starty + _dicesize, _col, _col, _col, _col, false)

    // Border
    if _active {
        draw_rectangle_color(_cx - 2, _starty - 2, _cx + _dicesize + 2, _starty + _dicesize + 2,
            c_yellow, c_yellow, c_yellow, c_yellow, true)
    } else {
        draw_rectangle_color(_cx, _starty, _cx + _dicesize, _starty + _dicesize,
            make_color_rgb(60, 60, 60), make_color_rgb(60, 60, 60), make_color_rgb(60, 60, 60), make_color_rgb(60, 60, 60), true)
    }

    // Pip number
    var _str = string(_d.pip)
    var _tx  = _cx + floor((_dicesize - string_width(_str)) / 2)
    var _ty  = _starty + floor((_dicesize - string_height(_str)) / 2)
    draw_set_color(c_black)
    draw_text(_tx + 3, _ty + 3, _str)
    draw_set_color(_active ? c_white : make_color_rgb(140, 140, 140))
    draw_text(_tx, _ty, _str)

    _cx += _dicesize + _dicepad
}

// Selection count (multi-select only)
if max_select != 1 {
    var _label = string(selected_count) + (max_select < 999 ? "/" + string(max_select) : "") + " selected"
    draw_set_color(c_white)
    draw_text(_startx, _starty + _dicesize + 10, _label)
}
