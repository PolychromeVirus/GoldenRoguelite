// Background — drawn in GUI space so it sits in front of the HUD
draw_sprite_ext(HalfMenuMiddleSelector, 0, 0, 0, 6, 6, 0, c_white, 1)
var _hw = sprite_get_width(HalfMenu) * 6
var _hh = sprite_get_height(HalfMenu) * 6
draw_sprite_ext(QuarterMenu, 0, _hw, _hh / 2, 6, 6, 0, c_white, 1)

var drawx = 50
var drawy = 300
var offset = 4
var vertpad = 54
var vertcent = drawy
draw_set_font(GoldenSun)

var castcolor = c_white

// Tab indicator
var _tabx = drawx
var _taby = 40
draw_set_color(c_black)
if mode == 0 {
	draw_text(_tabx + offset, _taby + offset, "[Inventory]  Equipment  >")
	draw_set_color(c_white)
	draw_text(_tabx, _taby, "[Inventory]  Equipment  >")
} else {
	draw_text(_tabx + offset, _taby + offset, "<  Inventory  [Equipment]")
	draw_set_color(c_white)
	draw_text(_tabx, _taby, "<  Inventory  [Equipment]")
}

draw_set_halign(fa_right)
draw_set_colour(c_black)
draw_text(camera_get_view_width(view_current)-8+offset,8+offset, string(global.gold) + "gp")
draw_set_colour(c_white)
draw_text(camera_get_view_width(view_current)-8,8, string(global.gold) + "gp")
draw_set_halign(fa_left)

if mode == 0 {
	// === INVENTORY MODE ===
	for (var i = 0; i < array_length(global.players[global.turn].inventory); i++){
		var draw = true
		var curritem = global.itemcardlist[global.players[global.turn].inventory[i]]

		if !isUsable(global.players[global.turn].inventory[i]){castcolor = c_grey}else{castcolor = c_white}
		if isEquippable(global.players[global.turn].inventory[i]){castcolor = c_yellow}

		drawy = 300
		if i == selected{drawy = 300}
		else if i < selected{
			drawy = vertcent - (vertpad*(selected-i))
		}else if i > selected{
			drawy = vertcent + (vertpad*(i-selected))
		}

		if i - selected > 6{draw = false}
		if selected - i > 5{draw = false}

		if asset_get_index(curritem.alias) != -1 and draw
		{
			draw_sprite_stretched(asset_get_index(curritem.alias),0,drawx,drawy,48,48)
		}

		if draw{
			draw_set_color(c_black)
			draw_text(drawx +72+offset,drawy+offset+8,curritem.name)
			draw_set_color(castcolor)
			draw_text(drawx +72,drawy+8,curritem.name)
			// Inline item preview
			if global.inCombat and array_length(global.players[global.turn].dicepool) > 0 {
				var _prev = CalcPreview("item", global.players[global.turn].inventory[i], global.players[global.turn])
				if _prev.description != "" {
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
					draw_set_halign(fa_right)
					draw_set_color(c_black)
					draw_text(drawx + 618 + offset, drawy + 8 + offset, _prev.description)
					draw_set_color(_pcol)
					draw_text(drawx + 618, drawy + 8, _prev.description)
					draw_set_halign(fa_left)
				}
			}
		}

		var descx = 820
		var descy = 411

		var desctext = global.itemcardlist[global.players[global.turn].inventory[selected]].text

		if string_length(desctext) > 170{desctext = string_delete(desctext,170,string_length(desctext)-169) + "..."}

		draw_set_color(c_black)
		draw_text_ext(descx+offset,descy+offset,desctext,40,660)
		draw_set_color(c_white)
		draw_text_ext(descx,descy,desctext,40,660)

		// Detail preview below description
		if global.inCombat and array_length(global.players[global.turn].dicepool) > 0 {
			var _selitem = global.players[global.turn].inventory[selected]
			var _dp = CalcPreview("item", _selitem, global.players[global.turn])
			if _dp.description != "" {
				var _detail = ""
				var _dcol = c_white
				if _dp.heal > 0 { _detail = "~" + string(_dp.heal) + " HP heal"; _dcol = make_color_rgb(80, 220, 80) }
				else if _dp.dam > 0 {
					_detail = "~" + string(_dp.dam) + " " + _dp.element + " damage"
					switch _dp.element {
						case "Venus": _dcol = global.c_venus; break
						case "Mars": _dcol = global.c_mars; break
						case "Jupiter": _dcol = global.c_jupiter; break
						case "Mercury": _dcol = global.c_mercury; break
					}
				}
				else { _detail = _dp.description }
				var _dy = descy + string_height_ext(desctext, 40, 660) + 8
				draw_set_color(c_black)
				draw_text(descx + offset, _dy + offset, _detail)
				draw_set_color(_dcol)
				draw_text(descx, _dy, _detail)
			}
		}
	}
} else {
	// === EQUIPMENT MODE ===
	// Build equipment list: weapon at index 0, then armor
	var _player = global.players[global.turn]
	var _equiplist = [_player.weapon]
	for (var i = 0; i < array_length(_player.armor); i++) {
		array_push(_equiplist, _player.armor[i])
	}
	var _equiplen = array_length(_equiplist)

	for (var i = 0; i < _equiplen; i++) {
		var draw = true
		var curritem = global.itemcardlist[_equiplist[i]]

		// Color: red if cursed, global important color otherwise
		if (curritem.cursed == "TRUE" or curritem.cursed == true) {
			castcolor = make_color_rgb(255, 80, 80)
		} else if i == 0 {
			castcolor = global.c_important
		} else {
			castcolor = global.c_important
		}

		drawy = 300
		if i == selected { drawy = 300 }
		else if i < selected {
			drawy = vertcent - (vertpad * (selected - i))
		} else if i > selected {
			drawy = vertcent + (vertpad * (i - selected))
		}

		if i - selected > 6 { draw = false }
		if selected - i > 5 { draw = false }

		if asset_get_index(curritem.alias) != -1 and draw {
			draw_sprite_stretched(asset_get_index(curritem.alias), 0, drawx, drawy, 48, 48)
			draw_sprite_stretched(equipped, 0, drawx+36, drawy+36,14, 14)
		}

		if draw {
			// Slot label
			var _slotlabel = (i == 0) ? " - [Weapon]" : " - [" + curritem.slot + "]"
			draw_set_color(c_black)
			draw_text(drawx + 72 + offset + string_width(curritem.name), drawy + offset+12, _slotlabel)
			draw_set_color(c_grey)
			draw_text(drawx + 72 + string_width(curritem.name), drawy+12, _slotlabel)

			// Item name
			draw_set_color(c_black)
			draw_text(drawx + 72 + offset, drawy + offset+8, curritem.name)
			draw_set_color(castcolor)
			draw_text(drawx + 72, drawy+8, curritem.name)
		}

		// Description for selected item
		var descx = 820
		var descy = 411

		var desctext = global.itemcardlist[_equiplist[selected]].text
		if string_length(desctext) > 170 { desctext = string_delete(desctext, 170, string_length(desctext) - 169) + "..." }

		draw_set_color(c_black)
		draw_text_ext(descx + offset, descy + offset, desctext, 40, 660)
		draw_set_color(c_white)
		draw_text_ext(descx, descy, desctext, 40, 660)
	}
}