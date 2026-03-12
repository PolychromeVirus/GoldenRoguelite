var drawx = 50
var drawy = 300
var offset = 4
var vertpad = 54
var vertcent = drawy
draw_set_font(GoldenSun)

for (var i = 0; i < array_length(allDjinn); i++) {
	var draw = true
	var castcolor = c_white
	var _entry = allDjinn[i]
	var currentspell = global.djinnlist[_entry.djinnID]
	var _owner = global.players[_entry.ownerIndex]

	if currentspell.ready { castcolor = c_white }
	else if currentspell.spent { castcolor = c_red }
	else { castcolor = c_grey }

	drawy = 300
	if i == selected { drawy = 300 }
	else if i < selected { drawy = vertcent - (vertpad * (selected - i)) }
	else { drawy = vertcent + (vertpad * (i - selected)) }

	if i - selected > 6 { draw = false }
	if selected - i > 5 { draw = false }

	if asset_get_index(currentspell.element) != -1 and draw {
		draw_sprite_stretched(asset_get_index(currentspell.element + "_Star"), 0, drawx + 8, drawy + 4, 32, 32)
	}

	if draw {
		draw_set_color(c_black)
		draw_text(drawx + 64 + offset, drawy + offset + 4, currentspell.name + " (" + _owner.name + ")")
		draw_set_color(castcolor)
		draw_text(drawx + 64, drawy + 4, currentspell.name + " (" + _owner.name + ")")

		if array_length(global.players[global.turn].dicepool) > 0 {
			var _prev = CalcPreview("djinni", _entry.djinnID, global.players[global.turn])
			if _prev.description != "" and _prev.description != "?" {
				draw_set_halign(fa_right)
				draw_set_color(c_black)
				draw_text(drawx + 657 + offset, drawy + 12 + offset, _prev.description)
				draw_set_color(c_white)
				draw_text(drawx + 657, drawy + 4, _prev.description)
				draw_set_halign(fa_left)
			}
		}
	}

	var descx = 820
	var descy = 411

	var desctext = global.djinnlist[allDjinn[selected].djinnID].text
	if string_length(desctext) > 170 { desctext = string_delete(desctext, 170, string_length(desctext) - 169) + "..." }

	draw_set_color(c_black)
	draw_text_ext(descx + offset, descy + offset, desctext, 40, 660)
	draw_set_color(c_white)
	draw_text_ext(descx, descy, desctext, 40, 660)
}
