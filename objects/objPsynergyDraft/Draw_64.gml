if instance_exists(objStatDisplay) { exit }
var drawx = 50
var drawy = 300
var offset = 4
var vertpad = 54
var vertcent = drawy
var player = global.players[draftPlayer]
draw_set_font(GoldenSun)

// Left half: spell list
for (var i = 0; i < array_length(draftPool); i++) {
	var draw = true
	var currentspell = global.psynergylist[draftPool[i]]

	drawy = 300
	if i == selected { drawy = 300 }
	else if i < selected {
		drawy = vertcent - (vertpad * (selected - i))
	} else if i > selected {
		drawy = vertcent + (vertpad * (i - selected))
	}

	if i - selected > 6 { draw = false }
	if selected - i > 5 { draw = false }

	if asset_get_index(currentspell.alias) != -1 and draw {
		draw_sprite_stretched(asset_get_index(currentspell.alias), 0, drawx, drawy, 48, 48)
	}

	if draw {
		draw_sprite_stretched(asset_get_index("range_" + string(currentspell.range)), 0, drawx + 52, drawy + 10, 96, 32)
		draw_set_color(c_black)
		draw_text(drawx + 100 + 54 + offset, drawy + offset + 12, currentspell.name + " - " + string(currentspell.cost) + " PP")
		draw_set_color(c_white)
		draw_text(drawx + 100 + 54, drawy + 12, currentspell.name + " - " + string(currentspell.cost) + " PP")
		draw_sprite_stretched(asset_get_index(currentspell.element + "_Star"), 0, drawx + 625, drawy + 8, 32, 32)
	}
}

// Portrait of the character levelling up
var _portrait = player.portrait
var _portraitX = 820
var _portraitY = 50
draw_sprite_stretched(_portrait, 0, _portraitX, _portraitY, 128, 128)
draw_set_color(c_black)
draw_text(_portraitX + 128 +8 + offset, _portraitY +offset, player.name + " - Learn Psynergy")
draw_set_color(c_white)
draw_text(_portraitX + 128 + 8, _portraitY, player.name + " - Learn Psynergy")

// Dice pool display: colored squares showing die counts per element
var _diceX = _portraitX + 128 + 8
var _diceY = _portraitY + 40
var _diceSize = 28
var _dicePad = 4
var _groupGap = 8
var _poolCounts = [player.melee, player.venus, player.mars, player.jupiter, player.mercury]
var _poolColors = [0x303030, #ffe45f, #ff8585, #e7abff, #a6c9ff]
var _dx = _diceX

for (var _p = 0; _p < 5; _p++) {
	if _poolCounts[_p] == 0 { continue }
	for (var _d = 0; _d < _poolCounts[_p]; _d++) {
		draw_rectangle_color(_dx, _diceY, _dx + _diceSize, _diceY + _diceSize,
			_poolColors[_p], _poolColors[_p], _poolColors[_p], _poolColors[_p], false)
		draw_rectangle_color(_dx, _diceY, _dx + _diceSize, _diceY + _diceSize,
			make_color_rgb(60, 60, 60), make_color_rgb(60, 60, 60),
			make_color_rgb(60, 60, 60), make_color_rgb(60, 60, 60), true)
		_dx += _diceSize + _dicePad
	}
	_dx += _groupGap
}

// Right half: selected spell detail
var descx = 820
var descy = _portraitY+135
var selspell = global.psynergylist[draftPool[selected]]

// Spell name + element star
draw_set_color(c_black)
draw_text(descx + offset, descy + offset, selspell.name + " - " + string(selspell.cost) + " PP")
draw_set_color(c_white)
draw_text(descx, descy, selspell.name + " - " + string(selspell.cost) + " PP")
draw_sprite_stretched(asset_get_index(selspell.element + "_Star"), 0, descx + 400, descy, 32, 32)

// Range sprite
if asset_get_index("range_" + string(selspell.range)) != -1 {
	draw_sprite_stretched(asset_get_index("range_" + string(selspell.range)), 0, descx, descy + 40, 96, 32)
}

// Stage text
var _stageText = "Stage " + string(selspell.stage)
if selspell.stage > 1 {
	// Find previous stage name
	var _prevID = FindPsyID(selspell.base, selspell.stage - 1)
	if _prevID != 0 {
		_stageText += " (Evolves from " + global.psynergylist[_prevID].name + ")"
	}
}
draw_set_color(c_black)
draw_text(descx + offset, descy + 80 + offset, _stageText)
draw_set_color(c_yellow)
draw_text(descx, descy + 80, _stageText)

// Full description
var desctext = selspell.text
draw_set_color(c_black)
draw_text_ext(descx + offset, descy + 120 + offset, desctext, 40, 660)
draw_set_color(c_white)
draw_text_ext(descx, descy + 120, desctext, 40, 660)

// Damage/heal preview
if global.inCombat and array_length(player.dicepool) > 0 {
	var _dp = CalcPreview("spell", draftPool[selected], player)
	if _dp.description != "" and _dp.description != "?" {
		var _detail = ""
		var _dcol = c_white
		if _dp.heal > 0 { _detail = "~" + string(_dp.heal) + " HP heal"; _dcol = make_color_rgb(80, 220, 80) }
		else {
			_detail = "~" + string(_dp.dam) + " " + _dp.element + " damage"
			switch _dp.element {
				case "Venus": _dcol = global.c_venus; break
				case "Mars": _dcol = global.c_mars; break
				case "Jupiter": _dcol = global.c_jupiter; break
				case "Mercury": _dcol = global.c_mercury; break
			}
		}
		var _dy = descy + 120 + string_height_ext(desctext, 40, 660) + 8
		draw_set_color(c_black)
		draw_text(descx + offset, _dy + offset, _detail)
		draw_set_color(_dcol)
		draw_text(descx, _dy, _detail)
	}
}
