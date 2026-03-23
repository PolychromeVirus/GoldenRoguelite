// Background panel
draw_sprite_ext(TestMenu, 0, 0, 0, 6, 6, 0, c_white, 1)

var drawx = 50
var drawy = 50
var offset = 4

var sprite = alias

draw_set_font(GoldenSun)

var _spr_scale = 255 / sprite_get_height(sprite)
var _spr_draw_w = sprite_get_width(sprite) * _spr_scale
var _spr_draw_h = sprite_get_height(sprite) * _spr_scale
draw_sprite_ext(sprite, 0, drawx + _spr_draw_w / 2, drawy + _spr_draw_h, _spr_scale, _spr_scale, 0, c_white, 1)

var namey = drawy + 8 + _spr_draw_h

var starsize = 20
var pad = 4
var stary = namey + ((string_height(name + " - " + element)/2) - (starsize/2))

draw_sprite_stretched(asset_get_index(element + "_Star"),0,drawx,stary,starsize,starsize)

draw_set_colour(c_black)
draw_text(drawx+(starsize+8)+pad+offset,namey+offset,name + " - " + element)
draw_set_colour(c_white)
draw_text(drawx+(starsize+8)+pad,namey,name + " - " + element)

// --- Stats panel (right of sprite) ---
var hpx = drawx + _spr_draw_w + 10
var hpy = drawy + 10
var _line_h = string_height("HP:") + 4

// HP bar
var _hp_text = "HP: " + string(monsterHealth) + "/" + string(maxhp)
var barsize = 200
var barstart = hpx + string_width(_hp_text) + 10
var barend = barstart + barsize

draw_set_color(c_black)
draw_text(hpx+offset,hpy+offset,_hp_text)
draw_set_color(c_white)
draw_text(hpx,hpy,_hp_text)

draw_rectangle_color(barstart,hpy,barend,hpy+string_height("HP:"),c_black,c_black,c_black,c_black,false)
var _bar_fill = floor(barsize * (monsterHealth / maxhp))
draw_rectangle_color(barstart,hpy,barstart+_bar_fill,hpy+string_height("HP:"),c_lime,c_lime,c_lime,c_lime,false)

hpy += _line_h + 4

// ATK
var _atk_str = "ATK: " + string(atk)
if atkmod != 0 {
	_atk_str += "  ("
	if atkmod > 0 { _atk_str += "+" }
	_atk_str += string(atkmod) + ")"
}
draw_set_color(c_black)
draw_text(hpx+offset, hpy+offset, _atk_str)
draw_set_color(atkmod > 0 ? c_lime : (atkmod < 0 ? c_red : c_white))
draw_text(hpx, hpy, _atk_str)
hpy += _line_h

// DEF (res)
var _def_str = "DEF: " + string(res)
if defmod != 0 {
	_def_str += "  ("
	if defmod > 0 { _def_str += "+" }
	_def_str += string(defmod) + ")"
}
draw_set_color(c_black)
draw_text(hpx+offset, hpy+offset, _def_str)
draw_set_color(defmod > 0 ? c_lime : (defmod < 0 ? c_red : c_white))
draw_text(hpx, hpy, _def_str)
hpy += _line_h

// Weakness
draw_set_color(c_white)
if weakness != "" {
	var _wk_star = asset_get_index(weakness + "_Star")
	var _wk_y = hpy + (string_height("Weak:")/2) - (starsize/2)
	draw_set_color(c_black)
	draw_text(hpx+offset, hpy+offset, "Weak:")
	draw_set_color(c_yellow)
	draw_text(hpx, hpy, "Weak:")
	if _wk_star != -1 {
		draw_sprite_stretched(_wk_star, 0, hpx + string_width("Weak: ") + 4, _wk_y, starsize, starsize)
	}
	hpy += _line_h
} else {
	draw_set_color(c_black)
	draw_text(hpx+offset, hpy+offset, "Weak: None")
	draw_set_color(c_white)
	draw_text(hpx, hpy, "Weak: None")
	hpy += _line_h
}

// Status resist
if status_resist > 0 {
	draw_set_color(c_black)
	draw_text(hpx+offset, hpy+offset, "Status Resist: " + string(status_resist))
	draw_set_color(c_aqua)
	draw_text(hpx, hpy, "Status Resist: " + string(status_resist))
	hpy += _line_h
}

// Boss tag
if boss {
	draw_set_color(c_black)
	draw_text(hpx+offset, hpy+offset, "BOSS")
	draw_set_color(c_red)
	draw_text(hpx, hpy, "BOSS")
	hpy += _line_h
}

// Active statuses
hpy += 4
var statarray = []
if poison  { array_push(statarray, Poison) }
if stun > 0 { array_push(statarray, Bolt) }
if sleep   { array_push(statarray, Sleep) }
if delude  { array_push(statarray, delude1) }
if psyseal { array_push(statarray, Psy_Seal) }
if venom   { array_push(statarray, Poison_Flow) }
if haunt > 0 { array_push(statarray, haunt1) }

var statx = hpx
for (var i = 0; i < array_length(statarray); i++) {
	draw_sprite_stretched(statarray[i], 0, statx, hpy, 32, 32)
	statx += 36
}
draw_set_color(c_white)

// --- Move table (below name line) ---
var _movey = namey + _line_h + 4

draw_set_color(c_black)
draw_text(drawx+offset, _movey+offset, "Moves:")
draw_set_color(c_white)
draw_text(drawx, _movey, "Moves:")
_movey += _line_h

var _grid = global.moveIDs
var _slot = 1
for (var _r = 1; _r < ds_grid_height(_grid); _r++) {
	if _grid[# 0, _r] != name { continue }
	var _parts = (_grid[# 2, _r] == "") ? 1 : real(_grid[# 2, _r])
	var _movename = _grid[# 1, _r]

	// Build damage/effect description
	var _desc = ""
	var _vdam  = (_grid[# 3, _r] == "") ? 0 : real(_grid[# 3, _r])
	var _madam = (_grid[# 4, _r] == "") ? 0 : real(_grid[# 4, _r])
	var _jdam  = (_grid[# 5, _r] == "") ? 0 : real(_grid[# 5, _r])
	var _medam = (_grid[# 6, _r] == "") ? 0 : real(_grid[# 6, _r])
	var _dam   = (_grid[# 7, _r] == "") ? 0 : real(_grid[# 7, _r])
	var _range = (_grid[# 8, _r] == "") ? 1 : real(_grid[# 8, _r])
	var _token = _grid[# 9, _r]
	var _heal  = _grid[# 11, _r]

	// Total damage
	var _total = _dam + _vdam + _madam + _jdam + _medam
	if _total > 0 {
		_desc += string(_total) + " dmg"
		var _elems = ""
		if _vdam > 0  { _elems += "Ve" }
		if _madam > 0 { _elems += (_elems != "" ? "/" : "") + "Ma" }
		if _jdam > 0  { _elems += (_elems != "" ? "/" : "") + "Ju" }
		if _medam > 0 { _elems += (_elems != "" ? "/" : "") + "Me" }
		if _elems != "" { _desc += " (" + _elems + ")" }
	}
	if _heal != "" { _desc += (_desc != "" ? ", " : "") + "heal " + _heal }
	if _token != "" { _desc += (_desc != "" ? ", " : "") + _token }
	if _range > 1 { _desc += (_desc != "" ? ", " : "") + "range " + string(_range) }

	var _slot_str = ""
	if _parts > 1 {
		_slot_str = string(_slot) + "-" + string(_slot + _parts - 1)
	} else {
		_slot_str = string(_slot)
	}

	var _line = _slot_str + ": " + _movename
	if _desc != "" { _line += "  -  " + _desc }

	draw_set_color(c_black)
	draw_text(drawx+offset, _movey+offset, _line)
	draw_set_color(c_white)
	draw_text(drawx, _movey, _line)
	_movey += _line_h
	_slot += _parts
}
