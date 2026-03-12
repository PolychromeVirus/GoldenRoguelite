var drawx = 0
var drawy = 110

draw_set_font(GoldenSunItalic)

var target = instance_position(mouse_x,mouse_y,all)
if global.textdisplay == ""{
	if variable_instance_exists(target, "hovertext"){
		if target and target.hovertext != ""{
			draw_rectangle_color(drawx,drawy,room_width,drawy+string_height(target.hovertext)-2,c_black,c_black,c_black,c_black,false)
			//draw_set_color(c_black)
			//draw_text(drawx+1,drawy+1,target.hovertext)
			draw_set_color(c_white)
			draw_text(drawx,drawy,target.hovertext)
		
		}
	}
}else{
		draw_rectangle_color(drawx,drawy,room_width,drawy+string_height(global.textdisplay)-2,c_black,c_black,c_black,c_black,false)
		//draw_set_color(c_black)
		//draw_text(drawx+1,drawy+1,global.textdisplay)
		draw_set_color(c_white)
		draw_text(drawx,drawy,global.textdisplay)
}
