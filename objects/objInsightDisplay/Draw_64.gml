var offset = 4
var _top = 48
var _bottom = display_get_gui_height() - 200
var _pad = 16
draw_set_font(GoldenSun)

if (global.dungeonFloor >= array_length(global.dungeonFloors)) {
	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)
	draw_set_color(c_black)
	draw_text(display_get_gui_width() * 0.5+offset, (_top + _bottom) * 0.5+offset, "No floor ahead")
	draw_set_color(c_white)
	draw_text(display_get_gui_width() * 0.5, (_top + _bottom) * 0.5, "No floor ahead")
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	return
}

var _floor = global.dungeonFloors[global.dungeonFloor] // next floor
var _challenges = _floor.challenges
var _cols = array_length(_challenges) + 1

var _gui_w = display_get_gui_width() - 64
var _col_w = _gui_w / _cols
var _line_h = 40

for (var _i = 0; _i < _cols; _i++) {
	var _x1 = _i * _col_w
	//var _x2 = _x1 + _col_w
	var _tx = _x1 + _pad
	var _tw = _col_w - (_pad * 2)
	var _ty = _top + _pad

	if (_i == 0) {
		_tx += 32
		var _title = "Next Floor"
		if (_floor.floor_name != "") _title = _floor.floor_name
		draw_set_color(c_black)
		draw_text(_tx+offset, _ty+offset, _title)
		draw_set_color(c_white)
		draw_text(_tx, _ty, _title)
		_ty += _line_h * 2
		draw_set_color(c_black)
		draw_text(_tx+offset, _ty+offset, "Required: " + string(_floor.required))
		draw_set_color(c_white)
		draw_text(_tx, _ty, "Required: " + string(_floor.required))
		_ty += _line_h
		draw_set_color(c_black)
		draw_text(_tx+offset, _ty+offset, "Challenges: " + string(array_length(_challenges)))
		draw_set_color(c_white)
		draw_text(_tx, _ty, "Challenges: " + string(array_length(_challenges)))
		_ty += _line_h * 2

		if (array_length(_floor.effects) > 0) {
			draw_set_color(c_black)
			draw_text(_tx+offset, _ty+offset, "Effects:")
			draw_set_color(c_white)
			draw_text(_tx, _ty, "Effects:")
			_ty += _line_h

			for (var _e = 0; _e < array_length(_floor.effects); _e++) {
				draw_set_color(c_black)
				draw_text_ext(_tx+offset, _ty+offset, "- " + _floor.effects[_e].name, _line_h, _tw)
				draw_set_color(c_white)
				draw_text_ext(_tx, _ty, "- " + _floor.effects[_e].name, _line_h, _tw)
				_ty += _line_h
			}
		} else {
			draw_set_color(c_black)
			draw_text(_tx+offset, _ty+offset, "Effects: None")
			draw_set_color(c_white)
			draw_text(_tx, _ty, "Effects: None")
		}

		continue
	}
	draw_set_halign(fa_right)
	_x1 = _i * _col_w
	_tx = _gui_w - ((_i-1) * _col_w)
	_tw = _col_w - (_pad * 2)
	_ty = _top + _pad
	_ch = _challenges[_i - 1]
	_header = "Challenge " + string(_i)

	if (_ch.type == "combat" || _ch.type == "boss") {
		_header = string_upper(_ch.type)
		draw_set_color(c_black)
		draw_text(_tx+offset, _ty+offset, _header)
		draw_set_color(c_white)
		draw_text(_tx, _ty, _header)
		_ty += _line_h * 2

		for (var _m = 0; _m < array_length(_ch.troop); _m++) {
			draw_set_color(c_black)
			draw_text_ext(_tx+offset, _ty+offset, _ch.troop[_m], _line_h, _tw)
			draw_set_color(c_white)
			draw_text_ext(_tx, _ty, _ch.troop[_m], _line_h, _tw)
			_ty += _line_h
		}
	} else if (_ch.type == "puzzle") {
		var _puz = global.puzzlelist[_ch.puzzle_index]
		var _ptype = _puz.trap ? "[TRAP]" : "[PUZZLE]"
		draw_set_color(c_black)
		draw_text(_tx+offset, _ty+offset, _ptype + "\n" + string_replace_all(_puz.name," ","\n"))
		draw_set_color(c_white)
		draw_text(_tx, _ty, _ptype + "\n" + string_replace_all(_puz.name," ","\n"))
		_ty += string_height(_ptype + "\n" + string_replace_all(_puz.name," ","\n")) * 2
		if _puz.spell_alias != ""{
			draw_set_color(c_black)
			draw_text_ext(_tx+offset, _ty+offset, "Psynergy: " + _puz.spell_alias, _line_h, _tw)
			draw_set_color(c_white)
			draw_text_ext(_tx, _ty, "Psynergy: " + _puz.spell_alias, _line_h, _tw)
			_ty += _line_h * 2
		}
		
		draw_set_color(c_black)
		draw_text_ext(_tx+offset, _ty+offset, _puz.disarm_text, _line_h, _tw)
		draw_set_color(c_white)
		draw_text_ext(_tx, _ty, _puz.disarm_text, _line_h, _tw)
		_ty += _line_h * (1 + ceil(string_height_ext(_puz.disarm_text, _line_h, _tw) / _line_h))

		if (_puz.reward_text != "") {
			draw_set_color(c_black)
			draw_text_ext(_tx+offset, _ty+offset, _puz.reward_text, _line_h, _tw)
			draw_set_color(c_white)
			draw_text_ext(_tx, _ty, _puz.reward_text, _line_h, _tw)
		}
	} else {
		draw_set_color(c_black)
		draw_text(_tx+offset, _ty+offset, string_upper(_ch.type))
		draw_set_color(c_white)
		draw_text(_tx, _ty, string_upper(_ch.type))
	}
}

draw_set_alpha(1)
draw_set_color(c_white)
draw_set_halign(fa_left)
draw_set_valign(fa_top)