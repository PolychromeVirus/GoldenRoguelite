var drawx = 16
var drawy = 160
draw_set_halign(fa_center)
draw_set_font(GoldenSun)
for (var i=0; i < array_length(global.passiveEffects);i++){
	draw_sprite_stretched(global.passiveEffects[i].sprite,0,drawx,drawy,64,64)
	
	if global.passiveEffects[i].countdown != -1{
		draw_set_color(c_black)
		draw_text(drawx+16+4,drawy+36+4,string(global.passiveEffects[i].countdown))
		draw_set_color(c_white)
		draw_text(drawx+16,drawy+36,string(global.passiveEffects[i].countdown))
		drawx+=100
	}
}
draw_set_halign(fa_left)