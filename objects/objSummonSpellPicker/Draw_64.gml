var drawx = 50
var drawy = 300
var offset = 4
var vertpad = 54
var vertcent = drawy
draw_set_font(GoldenSun)

var caster = global.players[playerID]

for (var i = 0; i < array_length(maxSpellIDs); i++) {
	var draw = true
	var maxspell = global.psynergylist[maxSpellIDs[i]]

	drawy = 300
	if i == selected { drawy = 300 }
	else if i < selected {
		drawy = vertcent - (vertpad * (selected - i))
	} else if i > selected {
		drawy = vertcent + (vertpad * (i - selected))
	}

	if i - selected > 6 { draw = false }
	if selected - i > 5 { draw = false }

	if asset_get_index(maxspell.alias) != -1 and draw {
		draw_sprite_stretched(asset_get_index(maxspell.alias), 0, drawx, drawy, 48, 48)
	}

	if draw {
		draw_sprite_stretched(asset_get_index("range_" + string(maxspell.range)), 0, drawx + 52, drawy + 10, 96, 32)
		draw_set_color(c_black)
		draw_text(drawx + 100 + 54 + offset, drawy + offset + 12, maxspell.name)
		draw_set_color(c_white)
		draw_text(drawx + 100 + 54, drawy + 12, maxspell.name)
		draw_sprite_stretched(asset_get_index(maxspell.element + "_Star"), 0, drawx + 625, drawy + 8, 32, 32)

		// Damage preview with fake all-6s pool
		var _saved = caster.dicepool
		caster.dicepool = fakeDicePool
		var _prev = CalcPreview("spell", maxSpellIDs[i], caster)
		caster.dicepool = _saved

		if _prev.description != "" and _prev.description != "?" {
			var _pcol = c_white
			if _prev.heal > 0 { _pcol = make_color_rgb(80, 220, 80) }
			else {
				switch _prev.element {
					case "Venus": _pcol = global.c_venus; break
					case "Mars": _pcol = global.c_mars; break
					case "Jupiter": _pcol = global.c_jupiter; break
					case "Mercury": _pcol = global.c_mercury; break
				}
			}
			draw_set_color(c_black)
			draw_text(drawx + 560 + offset, drawy + 12 + offset, _prev.description)
			draw_set_color(_pcol)
			draw_text(drawx + 560, drawy + 12, _prev.description)
		}
	}
}

// Description + detail preview for selected spell
if array_length(maxSpellIDs) > 0 {
	var selspell = global.psynergylist[maxSpellIDs[selected]]

	var descx = 820
	var descy = 411

	var desctext = selspell.text
	if string_length(desctext) > 140 { desctext = string_delete(desctext, 140, string_length(desctext) - 139) + "..." }

	draw_set_color(c_black)
	draw_text_ext(descx + offset, descy + offset, desctext, 40, 660)
	draw_set_color(c_white)
	draw_text_ext(descx, descy, desctext, 40, 660)

	// Detail preview
	var _saved = caster.dicepool
	caster.dicepool = fakeDicePool
	var _dp = CalcPreview("spell", maxSpellIDs[selected], caster)
	caster.dicepool = _saved

	if _dp.description != "" and _dp.description != "?" {
		var _detail = ""
		var _dcol = c_white
		if _dp.heal > 0 { _detail = "~Recover " + string(_dp.heal) + " HP"; _dcol = global.c_important }
		else {
			_detail = "~" + string(_dp.dam) + " " + _dp.element + " Damage"
			switch _dp.element {
				case "Venus": _dcol = global.c_venus; break
				case "Mars": _dcol = global.c_mars; break
				case "Jupiter": _dcol = global.c_jupiter; break
				case "Mercury": _dcol = global.c_mercury; break
			}
		}
		var _dy = descy + string_height_ext(desctext, 40, 660) + 16
		draw_set_color(c_black)
		draw_text(descx + offset, _dy + offset, _detail)
		draw_set_color(_dcol)
		draw_text(descx, _dy, _detail)
	}

	// Note about summon power
	draw_set_color(c_black)
	draw_text(48+offset, 48+offset, "Cast a " + string_ucfirst(element) + " spell")
	draw_set_color(c_yellow)
	draw_text(48, 48, "Cast a " + string_ucfirst(element) + " spell")
	draw_set_color(c_white)
}
