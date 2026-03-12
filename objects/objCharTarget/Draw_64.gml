var drawx = 50
var drawy = 300
var drawymaster = drawy
var offset = 4
var vertpad = 200
var vertcent = drawy
var picsize = 128
draw_set_font(GoldenSun)

for (var i = 0; i < array_length(global.players); i++){
	var draw = true
	var currentchar = global.players[i]
	
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
		
		var chartext = currentchar.name + "\nHP " + string(currentchar.hp) +"/" + string(currentchar.hpmax) + "\nPP " + string(currentchar.pp) + "/" + string(currentchar.ppmax)

		var selectcolor = c_white
		
		if removepoison and !currentchar.poison{selectcolor = c_grey}
		if healing > 0 and currentchar.hp >= currentchar.hpmax and !variable_instance_exists(id,regen){selectcolor = c_grey}
		if healing > 0 and !revive and dmgtype != "mercury"{
			if currentchar.hp == 0{
				selectcolor = c_grey
			}
			
		}
		if revive and currentchar.hp != 0{selectcolor = c_grey}
		if ppheal > 0 and currentchar.pp >= currentchar.ppmax{selectcolor = c_grey}
		if trade and array_length(currentchar.inventory) > 4{selectcolor = c_grey}
		
		draw_set_color(c_black)
		draw_text(drawx+picsize+8+offset,drawy+offset,chartext)
		draw_set_color(selectcolor)
		draw_text(drawx+picsize+8,drawy,chartext)
		
		var statarray = GetStatus(currentchar)

		var statx = drawx+picsize+8
		var staty = drawy + string_height("Name\nHP:\nPP:")

		for (var j = 0;j<array_length(statarray);j++){
			draw_sprite_stretched(statarray[j],0,statx,staty,39,39)
			statx += 39+4
		}
	}

	//var descx = 820
	//var descy = 50
	
	//var desctext = global.players[selected].text
	
	//if string_length(desctext) > 340{desctext = string_delete(desctext,170,string_length(desctext)-339) + "..."}
	
	//draw_set_color(c_black)
	//draw_text_ext(descx+offset,descy+offset,desctext,40,660)
	//draw_set_color(c_white)
	//draw_text_ext(descx,descy,desctext,40,660)
}