if array_length(monsters) == 0 { exit }
var _offset = 12

// Build target list from selected outward, up to num targets
var _targets = GetTargetIndices(selected, num, array_length(monsters))

for (var _i = 0; _i < array_length(_targets); _i++) {
	var mon = monsters[_targets[_i]]
	var _top = mon.y - sprite_get_height(mon.sprite_index)
	if _targets[_i] == selected {
		draw_sprite(Down_Arrow, 0, mon.x, _top - _offset)
	} else {
		draw_set_alpha(0.6)
		draw_sprite(Green_Arrow, 0, mon.x, _top - _offset)
		draw_set_alpha(1)
	}
}
