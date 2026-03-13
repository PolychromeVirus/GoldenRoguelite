draw_self()

if (flash_timer > 0) {
	gpu_set_blendmode(bm_add)
	draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, c_white, flash_timer / 12)
	gpu_set_blendmode(bm_normal)
	flash_timer--
}