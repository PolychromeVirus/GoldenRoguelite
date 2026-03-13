var _cx = display_get_gui_width() div 2
var _cy = display_get_gui_height() div 2 - 20

draw_set_font(GoldenSun)

var _line1 = puzzle.name
var _line2 = puzzle.trap ? puzzle.disarm_text : puzzle.reward_text
var _line3 = ""
if (no_caster) {
	if (is_overload) {
		_line3 = "No " + overload_element + " adept with 8 PP!"
	} else {
		_line3 = "No one can cast " + spell_name + "!"
	}
} else {
	if (is_overload) {
		_line3 = global.players[caster].name + ": Spend 8 PP to disarm?"
	} else {
		var _psyID = FindPsyID(spell_name, 0)
		var _cost = global.psynergylist[_psyID].cost
		_line3 = global.players[caster].name + ": Cast " + spell_name + "? (" + string(_cost) + " PP)"
	}
}

var _w1 = string_width(_line1)
var _w2 = string_width(_line2)
var _w3 = string_width(_line3)
var _maxw = max(_w1, _w2, _w3)
var _hw = min((_maxw + 16) / 2, 600)
var _h = 124

draw_set_alpha(0.85)
draw_rectangle_color(_cx - _hw, _cy - _h, _cx + _hw, _cy + _h, c_black, c_black, c_black, c_black, false)
draw_set_alpha(1)
draw_rectangle_color(_cx - _hw, _cy - _h, _cx + _hw, _cy + _h, c_white, c_white, c_white, c_white, true)

draw_set_halign(fa_center)
draw_set_valign(fa_middle)

// Title
draw_set_color(puzzle.trap ? c_red : c_lime)
draw_text(_cx, _cy - 72, _line1)

// Description
draw_set_color(c_white)
draw_text_ext(_cx, _cy, _line2,36,600)

// Caster info
draw_set_color(no_caster ? c_red : c_yellow)
draw_text(_cx, _cy + 72, _line3)

draw_set_halign(fa_left)
draw_set_valign(fa_top)
draw_set_color(c_white)