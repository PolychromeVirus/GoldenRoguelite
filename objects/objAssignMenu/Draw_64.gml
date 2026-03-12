var drawx = 50
var drawy = 300
var offset = 4
var vertpad = 54
var vertcent = drawy
draw_set_font(GoldenSun)

for (var i = 0; i < array_length(dice); i++){
	var draw = true
	var castcolor = c_white	
	
	drawy = 300
	if i == selected{drawy = 300}
	else if i < selected{
		drawy = vertcent - (vertpad*(selected-i))
	}else if i > selected{
		drawy = vertcent + (vertpad*(i-selected))
	}
	
	if i - selected > 6{draw = false}
	if selected - i > 5{draw = false}
	
	if draw{
		draw_set_color(c_black)
		draw_text(drawx +100+54+offset,drawy+offset+12,string(dice[i]))
		draw_set_color(castcolor)
		draw_text(drawx +100+54,drawy+12,string(dice[i]))

	}
	//drawy+= 54
	//if drawy > 600{drawy = 50
	//	drawx += 700}
	
	
}