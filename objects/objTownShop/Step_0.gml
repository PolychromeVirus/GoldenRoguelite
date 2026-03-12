if (selected < 0) { selected = 0 }
if (selected >= array_length(shoplist)) { selected = array_length(shoplist) - 1 }
if (selected < 0) { selected = 0 }

if (instance_number(objQuarterMenu) < 1 && array_length(shoplist) > 0) {
	instance_create_depth(sprite_width, sprite_height / 2, 0, objQuarterMenu)
}
