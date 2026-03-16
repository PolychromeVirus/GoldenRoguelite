draw_sprite_ext(QuarterMenu, 0, spr_x, spr_y, 6, 6, 0, c_white, 1)

draw_set_font(GoldenSun)
draw_set_halign(fa_center)
draw_set_valign(fa_middle)

var _cx    = spr_x + _spr_w / 2
var _max_w = _spr_w - 80   // leave 40px padding each side
var _off = 4

// Build display lines, wrapping any that are too wide
var _draw_lines = []
for (var _i = 0; _i < array_length(lines); _i++) {
	var _entry   = lines[_i]
	var _wrapped = WrapText(_entry.text, _max_w)
	for (var _j = 0; _j < array_length(_wrapped); _j++) {
		array_push(_draw_lines, { text: _wrapped[_j], color: _entry.color })
	}
}

// Centre the lines vertically inside the sprite
var _line_h  = 42
var _n       = array_length(_draw_lines)
var _total_h = (_n - 1) * _line_h
var _start_y = spr_y + _spr_h / 2 - _total_h / 2

for (var _i = 0; _i < _n; _i++) {
	draw_set_color(c_black)
	draw_text(_cx+_off, _start_y + _i * _line_h+_off, _draw_lines[_i].text)
	draw_set_color(_draw_lines[_i].color)
	draw_text(_cx, _start_y + _i * _line_h, _draw_lines[_i].text)
}

draw_set_halign(fa_left)
draw_set_valign(fa_top)
draw_set_color(c_white)
