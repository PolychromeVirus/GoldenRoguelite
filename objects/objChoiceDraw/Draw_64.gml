var offset = 4
draw_set_font(GoldenSun)

// Title
draw_set_color(c_black)
draw_text(50 + offset, 30 + offset, draw_player.name + " - Choose a Card")
draw_set_color(c_yellow)
draw_text(50, 30, draw_player.name + " - Choose a Card")

// 3 large boxes across 1536px
var _boxW = 440
var _boxH = 550
var _totalW = array_length(choices) * _boxW
var _gap = (1536 - _totalW) / (array_length(choices) + 1)
var _startY = 80

for (var i = 0; i < array_length(choices); i++) {
	var _item = global.itemcardlist[choices[i]]
	var _cx = _gap + i * (_boxW + _gap)
	var _cy = _startY

	// Card background
	var _bgCol = #006080
	if (i == selected) { _bgCol = #005870 }
	draw_rectangle_color(_cx, _cy, _cx + _boxW, _cy + _boxH, _bgCol, _bgCol, _bgCol, _bgCol, false)

	// Selection border
	if (i == selected) {
		draw_rectangle_color(_cx - 3, _cy - 3, _cx + _boxW + 3, _cy + _boxH + 3, c_white, c_white, c_white, c_white, true)
		draw_rectangle_color(_cx - 2, _cy - 2, _cx + _boxW + 2, _cy + _boxH + 2, c_white, c_white, c_white, c_white, true)
	} else {
		draw_rectangle_color(_cx, _cy, _cx + _boxW, _cy + _boxH, _bgCol, _bgCol, _bgCol, _bgCol, true)
	}

	// Icon (96x96 centered)
	var _iconSprite = asset_get_index(_item.alias)
	if (_iconSprite != -1) {
		draw_sprite_stretched(_iconSprite, 0, _cx + _boxW / 2 - 48, _cy + 16, 96, 96)
	}

	// Category color
	var _catcol = c_white
	if (variable_struct_exists(_item, "melee")) {
		_catcol = global.c_weapons
	} else if (_item.type == "Armor") {
		switch (_item.slot) {
			case "Shield": _catcol = global.c_armor; break
			case "Headwear": _catcol = global.c_armor; break
			case "Body": _catcol = global.c_armor; break
			case "Ring": _catcol = global.c_armor; break
			case "Psynergy": _catcol = global.c_armor; break
			default: _catcol = global.c_armor; break
		}
	}

	// Name
	var _nameX = _cx + _boxW / 2 - string_width(_item.name) / 2
	draw_set_color(c_black)
	draw_text(_nameX + offset, _cy + 124 + offset, _item.name)
	draw_set_color(_catcol)
	draw_text(_nameX, _cy + 124, _item.name)

	// Type tag
	var _typeText = ""
	if (variable_struct_exists(_item, "melee")) {
		_typeText = _item.type
	} else if (_item.type == "Armor") {
		_typeText = _item.slot
	} else {
		_typeText = _item.type
	}
	var _typeX = _cx + _boxW / 2 - string_width("[" + _typeText + "]") / 2
	draw_set_color(c_black)
	draw_text(_typeX + offset, _cy + 164 + offset, "[" + _typeText + "]")
	draw_set_color(c_ltgray)
	draw_text(_typeX, _cy + 164, "[" + _typeText + "]")

	// Description text (wrapped)
	draw_set_color(c_black)
	draw_text_ext(_cx + 20 + offset, _cy + 210 + offset, _item.text, 36, _boxW - 40)
	draw_set_color(c_ltgray)
	draw_text_ext(_cx + 20, _cy + 210, _item.text, 36, _boxW - 40)
}
