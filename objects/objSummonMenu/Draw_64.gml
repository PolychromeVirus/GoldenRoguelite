var drawx = 50
var drawy = 300
var offset = 4
var vertpad = 54
var vertcent = drawy
draw_set_font(GoldenSun)

for (var i = 0; i < array_length(global.knownSummons); i++){
	var draw = true
	var castcolor = c_white
	var _summonID = global.knownSummons[i]
	var currentsummon = global.summonlist[_summonID]

	if isSummonable(currentsummon) == false{
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

	if asset_get_index(currentsummon.alias) != -1 and draw
	{
		draw_sprite_stretched(asset_get_index(currentsummon.alias),0,drawx,drawy,48,48)
	}

	if draw{
		draw_sprite_stretched(asset_get_index("range_"+string(currentsummon.range)),0,drawx+52,drawy+2,96,32)
		// Build cost string showing djinn requirements
		var coststr = ""
		if currentsummon.venus > 0 { coststr += string(currentsummon.venus) + "V " }
		if currentsummon.mars > 0 { coststr += string(currentsummon.mars) + "Ma " }
		if currentsummon.jupiter > 0 { coststr += string(currentsummon.jupiter) + "J " }
		if currentsummon.mercury > 0 { coststr += string(currentsummon.mercury) + "Me " }
		coststr = string_trim(coststr)

		draw_set_color(c_black)
		draw_text(drawx +100+54+offset,drawy+offset+8,currentsummon.name)
		draw_set_color(castcolor)
		draw_text(drawx +100+54,drawy+8,currentsummon.name)
		//draw_sprite_stretched(asset_get_index(currentsummon.element + "_Star"),0,drawx+625,drawy+4,32,32)
		
		var cost = []
		
		if currentsummon.venus > 0{
			for (var _s = 0; _s < currentsummon.venus; ++_s) {
			    array_push(cost,Venus_Star_Clean)
			}
		}
		if currentsummon.mars > 0{
			for (var _s = 0; _s < currentsummon.mars; ++_s) {
			    array_push(cost,Mars_Star_Clean)
			}
		}
		if currentsummon.jupiter > 0{
			for (var _s = 0; _s < currentsummon.jupiter; ++_s) {
			    array_push(cost,Jupiter_Star_Clean)
			}
		}
		if currentsummon.mercury > 0{
			for (var _s = 0; _s < currentsummon.mercury; ++_s) {
			    array_push(cost,Mercury_Star_Clean)
			}
		}
		
		if currentsummon.name == "Charon"{cost = [None_Star_Clean,None_Star_Clean]}
		
		var size = 48
		var starx = drawx+625
		var stary = drawy+24 -(size / 2)
		for (var _s = 0; _s < array_length(cost); ++_s) {
		    draw_sprite_stretched(cost[_s],0,starx,stary,48,48)
			starx -= 32
		}
		
	}
}


// Description for selected summon
if array_length(global.knownSummons) > 0 {
	var descx = 820
	var descy = 411

	var _selID = global.knownSummons[selected]
	var desctext = global.summonlist[_selID].text

	if string_length(desctext) > 170{desctext = string_delete(desctext,170,string_length(desctext)-169) + "..."}

	draw_set_color(c_black)
	draw_text_ext(descx+offset,descy+offset,desctext,40,660)
	draw_set_color(c_white)
	draw_text_ext(descx,descy,desctext,40,660)
}
