if !array_contains(global.menu_stack, id) { exit }

draw_sprite_ext(TestMenu, 0, 0, 0, 6, 6, 0, c_white, 1)
draw_rich_text(_pad_x, 36, "Combat Log", 1436)

var _n     = array_length(global.log)
var _start = max(0, _n - _visible_lines - scroll_offset)
var _end   = min(_n, _start + _visible_lines)
var _dy    = _pad_y

for (var _i = _start; _i < _end; _i++) {
    draw_rich_text(_pad_x, _dy, global.log[_i], 1436)
    _dy += _line_h
}

draw_set_color(c_dkgray)
draw_text(_pad_x, 1080 - 60, "↑↓ / scroll to navigate")
