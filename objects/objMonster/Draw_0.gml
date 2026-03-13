// Death animation tuning constants
#macro DEATH_PRE_DELAY   30   // frames to wait before animation starts (flash plays here)
#macro DEATH_FADE_FRAMES 30  // frames for desaturation/alpha fade (phase 1)
#macro DEATH_SHRINK_FRAMES 1 // frames for shrink to nothing (phase 2)
#macro DEATH_POST_DELAY  30   // frames to wait after animation before DEAD sprite appears

var _total_death = DEATH_PRE_DELAY + DEATH_FADE_FRAMES + DEATH_SHRINK_FRAMES + DEATH_POST_DELAY

if dying and death_timer > 0 {
	// Which phase are we in? (death_timer counts down from _total_death)
	var _elapsed = _total_death - death_timer
	var _phase1_start = DEATH_PRE_DELAY
	var _phase2_start = DEATH_PRE_DELAY + DEATH_FADE_FRAMES
	var _phase3_start = DEATH_PRE_DELAY + DEATH_FADE_FRAMES + DEATH_SHRINK_FRAMES

	if _elapsed < _phase1_start {
		// Pre-delay: draw frozen frame, let flash play
		draw_sprite_ext(sprite_index, death_frame, x, y,
			image_xscale, image_yscale, image_angle, c_white, 1.0)
	} else if _elapsed < _phase2_start {
		// Phase 1: desaturate + fade alpha
		var _p = (_elapsed - _phase1_start) / DEATH_FADE_FRAMES // 0→1
		var _grey = merge_colour(c_white, c_dkgray, _p)
		var _alpha = lerp(1.0, 0.3, _p)
		draw_sprite_ext(sprite_index, death_frame, x, y,
			image_xscale, image_yscale, image_angle, _grey, _alpha)
	} else if _elapsed < _phase3_start {
		// Phase 2: shrink + fade out
		var _p = (_elapsed - _phase2_start) / DEATH_SHRINK_FRAMES // 0→1
		var _sc = lerp(1.0, 0.0, _p)
		var _alpha = lerp(0.3, 0.0, _p)
		draw_sprite_ext(sprite_index, death_frame, x, y,
			image_xscale * _sc, image_yscale * _sc, image_angle, c_dkgray, _alpha)
	}
	// Post-delay: draw nothing, waiting for DEAD sprite

	// Element flash overlays during all visible phases
	if (flash_timer > 0) {
		gpu_set_blendmode(bm_add)
		draw_sprite_ext(sprite_index, image_index, x, y,
			image_xscale, image_yscale, image_angle, flash_color, flash_timer / 12)
		gpu_set_blendmode(bm_normal)
		flash_timer--
	}

	death_timer--
	if death_timer <= 0 {
		sprite_index = DEAD
		image_blend = c_white
		image_alpha = 1.0
		image_xscale = 1
		image_yscale = 1
	}
} else {
	draw_self()

	if (flash_timer > 0) {
		gpu_set_blendmode(bm_add)
		draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, flash_color, flash_timer / 12)
		gpu_set_blendmode(bm_normal)
		flash_timer--
	}

	var diff = (hpx2)-(hpx)
	var diff = diff * (monsterHealth/maxhp)

	if mark{
		draw_sprite_stretched(Mercury_Star_Clean,0,x-8,y-sprite_height-18,16,16)
	}

	
	if monsterHealth > 0 {draw_rectangle_colour(hpx, y+2,hpx2,y+4,c_red,c_red,c_red,c_red, false);
		draw_rectangle_colour(hpx, y+2,(hpx)+diff,y+4,c_blue,c_blue,c_blue,c_blue, false)}

	// Draw status icons below HP bar
	if monsterHealth > 0 {
		var _statuses = GetStatus(id)
		for (var _s = 0; _s < array_length(_statuses); _s++) {
			draw_sprite_ext(_statuses[_s], 0, hpx + _s * 10, y + 6, 0.5, 0.5, 0, c_white, 1)
		}
	}
}
