var drawx = 50
var drawy = 300
var drawymaster = drawy
var offset = 4
var vertpad = 200
var vertcent = drawy
var picsize = 128
draw_set_font(GoldenSun)

for (var i = 0; i < array_length(global.characterlist); i++){
	var draw = true
	var currentchar = global.characterlist[i]
	
	drawy = drawymaster
	
	if i == selected{drawy = drawymaster}
	else if i < selected{
		drawy = vertcent - (vertpad*(selected-i))
	}else if i > selected{
		drawy = vertcent + (vertpad*(i-selected))
	}
	
	if i - selected > 1{draw = false}
	if selected - i > 1{draw = false}
	
	if currentchar.portrait != -1 and draw
	{
		draw_sprite_stretched(currentchar.portrait,0,drawx,drawy,128,128)
	}
	
	if draw{
		
		var chartext = currentchar.name + " - " + currentchar.element+"\nWeapon: " + global.itemcardlist[currentchar.weapon].name
		var psytext = "\n"
		var djinntext = "\n"
		
		if array_length(currentchar.spells) > 0{psytext += global.psynergylist[currentchar.spells[0]].name}
		for (var j= 1; j<array_length(currentchar.spells); j++){
				psytext += ", " + global.psynergylist[currentchar.spells[j]].name
		}
		
		if array_length(currentchar.djinn) > 0{djinntext += global.djinnlist[currentchar.djinn[0]].name}
		for (var j= 1; j<array_length(currentchar.djinn); j++){
				djinntext += ", " + global.djinnlist[currentchar.djinn[j]].name
		}
		
		chartext += psytext + djinntext
		
		draw_set_color(c_black)
		draw_text(drawx+picsize+8+offset,drawy+offset,chartext)
		draw_set_color(c_white)
		draw_text(drawx+picsize+8,drawy,chartext)
		draw_sprite_stretched(asset_get_index(currentchar.element + "_Star"),0,drawx+625,drawy+8,32,32)
	}
	//drawy+= 54
	//if drawy > 600{drawy = 50
	//	drawx += 700}
	
	var descx = 820
	var descy = 150
	
	var desctext = global.characterlist[selected].text

	if string_length(desctext) > 240{desctext = string_delete(desctext,170,string_length(desctext)-239) + "..."}

	draw_set_color(c_black)
	draw_text_ext(descx+offset,descy+offset,desctext,40,660)
	draw_set_color(c_white)
	draw_text_ext(descx,descy,desctext,40,660)

	// Draw starter spell picker
	var _starters = global.characterlist[selected].starters
	if array_length(_starters) > 0 {
		var _sy = 48
		var _sx = descx
		draw_set_color(c_black)
		draw_text(_sx+offset, _sy+offset, "Starting Psynergy:")
		draw_set_color(c_white)
		draw_text(_sx, _sy, "Starting Psynergy:")

		for (var s = 0; s < array_length(_starters); s++) {
			var _spell = global.psynergylist[_starters[s]]
			var _spx = _sx + s * 300
			var _spy = _sy + 50

			if s == starter_selected {
				draw_set_color(c_black)
				draw_text(_spx+offset, _spy+offset, "> " + _spell.name + " <")
				draw_set_color(c_yellow)
				draw_text(_spx, _spy, "> " + _spell.name + " <")
				//// Draw spell description
				//draw_set_color(c_black)
				//draw_text_ext(_sx+offset, _spy+50+offset, _spell.text, 30, 660)
				//draw_set_color(c_white)
				//draw_text_ext(_sx, _spy+50, _spell.text, 30, 660)
			} else {
				draw_set_color(c_black)
				draw_text(_spx+offset, _spy+offset, _spell.name)
				draw_set_color(c_gray)
				draw_text(_spx, _spy, _spell.name)
			}
			draw_set_color(c_white)
		}
	}
}