var drawx = 50
var drawy = 300
var offset = 4
var vertpad = 54
var vertcent = drawy
draw_set_font(GoldenSun)

for (var i = 0; i < array_length(global.players[global.turn].spells); i++){
	var draw = true
	var castcolor = c_white
	var currentspell = global.psynergylist[global.players[global.turn].spells[i]]
	
	if isCastable(currentspell,global.players[global.turn]) == false{
			castcolor = c_grey
		}else{
			castcolor = c_white
		}
	drawy = 300
	if i == selected{drawy = 300}
	else if i < selected{
		drawy = vertcent - (vertpad*(selected-i))
	}else if i > selected{
		drawy = vertcent + (vertpad*(i-selected))
	}
	
	if i - selected > 6{draw = false}
	if selected - i > 5{draw = false}
	
	if asset_get_index(currentspell.alias) != -1 and draw
	{
		draw_sprite_stretched(asset_get_index(currentspell.alias),0,drawx,drawy,48,48)
	}
	
	if draw{
		draw_sprite_stretched(asset_get_index("range_"+string(currentspell.range)),0,drawx+52,drawy+6,96,32)
		draw_set_color(c_black)
		draw_text(drawx +100+54+offset,drawy+offset+8,currentspell.name + " - " + string(currentspell.cost) + " PP")
		draw_set_color(castcolor)
		draw_text(drawx +100+54,drawy+8,currentspell.name + " - " + string(currentspell.cost) + " PP")
		draw_sprite_stretched(asset_get_index(currentspell.element + "_Star"),0,drawx+625,drawy+8,32,32)
		// Inline damage preview
		if global.inCombat and array_length(global.players[global.turn].dicepool) > 0 {
			var _prev = CalcPreview("spell", global.players[global.turn].spells[i], global.players[global.turn])
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
				draw_set_halign(fa_right)
				draw_set_color(c_black)
				draw_text(drawx + 618 + offset, drawy + 8 + offset, _prev.description)
				draw_set_color(_pcol)
				draw_text(drawx + 618, drawy + 8, _prev.description)
				draw_set_halign(fa_left)
			}
		}
	}
	//drawy+= 54
	//if drawy > 600{drawy = 50
	//	drawx += 700}
	
	var descx = 820
	var descy = 411
	
	var desctext = global.psynergylist[global.players[global.turn].spells[selected]].text
	
	if string_length(desctext) > 170{desctext = string_delete(desctext,170,string_length(desctext)-169) + "..."}
	
	draw_set_color(c_black)
	draw_text_ext(descx+offset,descy+offset,desctext,40,660)
	draw_set_color(c_white)
	draw_text_ext(descx,descy,desctext,40,660)

	// Detail preview below description
	if global.inCombat and array_length(global.players[global.turn].dicepool) > 0 {
		var _selspell = global.players[global.turn].spells[selected]
		var _dp = CalcPreview("spell", _selspell, global.players[global.turn])
		if _dp.description != "" and _dp.description != "?" {
			var _detail = ""
			var _dcol = c_white
			if _dp.heal > 0 { _detail = "~" + string(_dp.heal) + " HP"; _dcol = make_color_rgb(80, 220, 80) }
			else {
				_detail = "~" + string(_dp.dam) + " " + _dp.element + " Damage"
				switch _dp.element {
					case "Venus": _dcol = global.c_venus; break
					case "Mars": _dcol = global.c_mars; break
					case "Jupiter": _dcol = global.c_jupiter; break
					case "Mercury": _dcol = global.c_mercury; break
				}
			}
			var _dy = descy + string_height_ext(desctext, 40, 660) + 8
			draw_set_color(c_black)
			draw_text(descx + offset, _dy + offset, _detail)
			draw_set_color(_dcol)
			draw_text(descx, _dy, _detail)
		}
	}
}