var drawx = 114
var drawy = 308
var offset = 4
var vertpad = 54
var vertcent = drawy
draw_set_font(GoldenSun)

for (var i = 0; i < array_length(global.players[global.turn].djinn); i++){
	var draw = true
	var castcolor = c_white
	var currentspell = global.djinnlist[global.players[global.turn].djinn[i]]
	
	if currentspell.ready == true{castcolor = c_white}
	if currentspell.ready == false{
		if currentspell.spent == true{castcolor = c_red}else{castcolor = c_grey}	
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
	
	if asset_get_index(currentspell.element) != -1 and draw
	{
		draw_sprite_stretched(asset_get_index(currentspell.element + "_Star"),0,drawx,drawy+8,32,32)
	}
	
	if draw{
		draw_set_color(c_black)
		draw_text(drawx+46 + offset,drawy+8+offset,currentspell.name)
		draw_set_color(castcolor)
		draw_text(drawx+46,drawy+8,currentspell.name)
		// Inline djinni preview (placeholder — most djinni not yet implemented)
		if global.inCombat and array_length(global.players[global.turn].dicepool) > 0 {
			var _prev = CalcPreview("djinni", global.players[global.turn].djinn[i], global.players[global.turn])
			if _prev.description != "" and _prev.description != "?" {
				draw_set_halign(fa_right)
				draw_set_color(c_black)
				draw_text(drawx + 600 + offset, drawy + 8 + offset, _prev.description)
				draw_set_color(c_white)
				draw_text(drawx + 600, drawy + 8, _prev.description)
				draw_set_halign(fa_left)
			}
		}
	}
	//drawy+= 54
	//if drawy > 600{drawy = 50
	//	drawx += 700}
	
	var descx = 820
	var descy = 411
	
	var desctext = global.djinnlist[global.players[global.turn].djinn[selected]].text
	
	if string_length(desctext) > 170{desctext = string_delete(desctext,170,string_length(desctext)-169) + "..."}
	
	draw_set_color(c_black)
	draw_text_ext(descx+offset,descy+offset,desctext,40,660)
	draw_set_color(c_white)
	draw_text_ext(descx,descy,desctext,40,660)
}