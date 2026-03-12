draw_self()

if (flash_timer > 0) {
	gpu_set_blendmode(bm_add)
	draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, c_white, flash_timer / 8)
	gpu_set_blendmode(bm_normal)
	flash_timer--
}



var diff = (hpx2)-(hpx)

var diff = diff * (monsterHealth/maxhp)

if mark{

draw_sprite_stretched(Mercury_Star_Clean,0,x-8,y-sprite_height-18,16,16)

}


draw_rectangle_colour(hpx, y+2,hpx2,y+4,c_red,c_red,c_red,c_red, false)
if monsterHealth > 0 {draw_rectangle_colour(hpx, y+2,(hpx)+diff,y+4,c_blue,c_blue,c_blue,c_blue, false)}

// Draw status icons below HP bar
if monsterHealth > 0 {
	var _statuses = GetStatus(id)
	for (var _s = 0; _s < array_length(_statuses); _s++) {
		draw_sprite_ext(_statuses[_s], 0, hpx + _s * 10, y + 6, 0.5, 0.5, 0, c_white, 1)
	}
}
