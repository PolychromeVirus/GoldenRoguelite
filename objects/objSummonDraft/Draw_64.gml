if instance_exists(objStatDisplay) { exit }
var offset = 4
draw_set_font(GoldenSun)

// Title
draw_set_color(c_black)
draw_text(50 + offset, 40 + offset, "Summon Tablet - Choose a Summon")
draw_set_color(c_yellow)
draw_text(50, 40, "Summon Tablet - Choose a Summon")

// 2 large boxes across 1536px
var _boxW = 600
var _boxH = 550
var _totalW = array_length(summonPool) * _boxW
var _gap = (1536 - _totalW) / (array_length(summonPool) + 1)
var _startY = 80

for (var i = 0; i < array_length(summonPool); i++) {
	var _summon = global.summonlist[summonPool[i]]
	var _cx = _gap + i * (_boxW + _gap)
	var _cy = _startY

	// Card background
	var _bgCol = #006080
	if i == selected { _bgCol = #005870 }
	draw_rectangle_color(_cx, _cy, _cx + _boxW, _cy + _boxH, _bgCol, _bgCol, _bgCol, _bgCol, false)

	// Selection border
	if i == selected {
		draw_rectangle_color(_cx - 3, _cy - 3, _cx + _boxW + 3, _cy + _boxH + 3, c_white, c_white, c_white, c_white, true)
		draw_rectangle_color(_cx - 2, _cy - 2, _cx + _boxW + 2, _cy + _boxH + 2, c_white, c_white, c_white, c_white, true)
	}

	// Summon portrait
	var _portraitSprite = asset_get_index(_summon.alias)
	if _portraitSprite != -1 {
		draw_sprite_stretched(_portraitSprite, 0, _cx, _cy+16, 128, 128)
	}

	var portsize = 64

	// Element star
	var _starSprite = asset_get_index(_summon.element + "_Star_Clean")
	if _starSprite != -1 {
		draw_sprite_stretched(_starSprite, 0, _cx + 132, _cy + 4, portsize, portsize)
	}

	var namey = _cy + 4 + (portsize / 2) - (string_height(_summon.name) / 2)

	// Summon name
	var _nameX = _cx + 136 + portsize
	draw_set_color(c_black)
	draw_text(_nameX + offset, namey + offset, _summon.name)
	draw_set_color(c_white)
	draw_text(_nameX, namey, _summon.name)

	// Element label (colored)
	var _elemCol = c_white
	switch _summon.element {
		case "Venus": _elemCol = global.c_venus; break
		case "Mars": _elemCol = global.c_mars; break
		case "Jupiter": _elemCol = global.c_jupiter; break
		case "Mercury": _elemCol = global.c_mercury; break
	}
	var _elemX = _nameX - 48
	draw_set_color(c_black)
	draw_text(_elemX + offset, namey + string_height("Venus") + 16 + offset, _summon.element)
	draw_set_color(_elemCol)
	draw_text(_elemX, namey + string_height("Venus") + 16, _summon.element)

	// Cost string
	var _costStr = ""
	if _summon.venus > 0 { _costStr += string(_summon.venus) + "V " }
	if _summon.mars > 0 { _costStr += string(_summon.mars) + "Ma " }
	if _summon.jupiter > 0 { _costStr += string(_summon.jupiter) + "J " }
	if _summon.mercury > 0 { _costStr += string(_summon.mercury) + "Me " }
	_costStr = string_trim(_costStr)
	draw_set_color(c_black)
	draw_text(_elemX + offset, namey + string_height("Venus") * 2 + 32 + offset, "Cost: " + _costStr)
	draw_set_color(c_ltgray)
	draw_text(_elemX, namey + string_height("Venus") * 2 + 32, "Cost: " + _costStr)

	// Description text (wrapped)
	draw_set_color(c_black)
	draw_text_ext(_cx + 20 + offset, _cy + 180 + offset, _summon.text, 36, _boxW - 40)
	draw_set_color(c_ltgray)
	draw_text_ext(_cx + 20, _cy + 180, _summon.text, 36, _boxW - 40)
}
