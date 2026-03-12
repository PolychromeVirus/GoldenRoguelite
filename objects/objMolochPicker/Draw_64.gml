draw_set_font(GoldenSun)

var cx = 400
var cy = 300
var offset = 4

draw_set_color(c_black)
draw_text(cx + offset, cy + offset, "Select a number to nullify: " + string(selected))
draw_set_color(c_white)
draw_text(cx, cy, "Select a number to nullify: " + string(selected))

//if source == "summon"{
//	draw_set_color(c_black)
//	draw_text(cx + offset, cy + 40 + offset, "Enemy moves matching this number become 'do nothing'")
//	draw_set_color(c_ltgray)
//	draw_text(cx, cy + 40, "Enemy moves matching this number become 'do nothing'")
//}else{
//	draw_set_color(c_black)
//	draw_text(cx + offset, cy + 40 + offset, "Enemy moves matching this number get rerolled")
//	draw_set_color(c_ltgray)
//	draw_text(cx, cy + 40, "Enemy moves matching this number get rerolled")
//}

draw_set_color(c_white)
