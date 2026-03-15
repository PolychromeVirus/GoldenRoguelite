draw_set_font(GoldenSun)

for (var _i = 0; _i < array_length(global.players); _i++) {
	var _col = _i mod 2
	var _row = _i div 2
	var _cx = gridX + _col * cellW
	var _cy = gridY + _row * cellStrideY
	var _p = global.players[_i]

	// Determine if this target is valid (greyed out if not)
	var _selectcolor = c_white
	if removepoison and !_p.poison { _selectcolor = c_grey }
	if healing > 0 and _p.hp >= _p.hpmax and !variable_instance_exists(id, "regen") { _selectcolor = c_grey }
	if healing > 0 and !revive and dmgtype != "mercury" {
		if _p.hp == 0 { _selectcolor = c_grey }
	}
	if revive and _p.hp != 0 { _selectcolor = c_grey }
	if ppheal > 0 and _p.pp >= _p.ppmax { _selectcolor = c_grey }
	if trade and array_length(_p.inventory) > 4 { _selectcolor = c_grey }

	var _greyed = (_selectcolor == c_grey)

	// Background box — highlight on mouse hover or keyboard selection
	if !_greyed and !(variable_instance_exists(self, "confirmed") and confirmed) {
		var _mx = device_mouse_x_to_gui(0)
		var _my = device_mouse_y_to_gui(0)
		var _hovered = (using_kbd and _i == kbd_selected)
		                or (!using_kbd and _mx >= _cx and _mx < _cx + cellW and _my >= _cy and _my < _cy + cellH)
		if _hovered {
			draw_set_alpha(0.15)
			draw_set_color(c_white)
			draw_rectangle(_cx, _cy, _cx + cellW - 4, _cy + cellH - 4, false)
			draw_set_alpha(1.0)
		}
	}

	// Portrait
	if _p.portrait != -1 {
		if _greyed {
			draw_set_alpha(0.4)
		}
		draw_sprite_stretched(_p.portrait, 0, _cx, _cy, portraitSize, portraitSize)

		// Heal flash overlay
		if variable_struct_exists(_p, "heal_flash") and _p.heal_flash > 0 {
			gpu_set_blendmode(bm_add)
			draw_set_color(c_lime)
			draw_set_alpha(0.4)
			draw_rectangle(_cx, _cy, _cx + portraitSize, _cy + portraitSize, false)
			draw_set_alpha(1.0)
			gpu_set_blendmode(bm_normal)
		}

		// Damage flash overlay
		if variable_struct_exists(_p, "flash_timer") and _p.flash_timer > 0 {
			gpu_set_blendmode(bm_add)
			draw_set_color(c_red)
			draw_set_alpha(0.4)
			draw_rectangle(_cx, _cy, _cx + portraitSize, _cy + portraitSize, false)
			draw_set_alpha(1.0)
			gpu_set_blendmode(bm_normal)
		}

		draw_set_alpha(1.0)
	}

	// Name (top of info block)
	var _bx = _cx + portraitSize + 8
	var _name_y = _cy + 4
	draw_set_color(c_black)
	draw_text(_bx + 4, _name_y + 4, _p.name)
	draw_set_color(_greyed ? c_grey : c_white)
	draw_text(_bx, _name_y, _p.name)

	// HP bar (below name) — HUD style: red bg, blue fill, text overlaid
	var _text_h = string_height("HP")
	var _barH = 16
	var _offset = 4
	var _hp_text = string(_p.hp) + "/" + string(_p.hpmax) + " HP"
	var _hpTextY = _name_y + _text_h + 8
	var _hpBarY = _hpTextY + _text_h - _barH - 4
	var _hp_ratio = (_p.hpmax > 0) ? _p.hp / _p.hpmax : 0
	// Bar bg (red) then fill (blue)
	draw_rectangle_color(_bx, _hpBarY, _bx + barW, _hpBarY + _barH, c_red, c_red, c_red, c_red, false)
	if _greyed {
		draw_rectangle_color(_bx, _hpBarY, _bx + barW * _hp_ratio, _hpBarY + _barH, c_grey, c_grey, c_grey, c_grey, false)
	} else {
		draw_rectangle_color(_bx, _hpBarY, _bx + barW * _hp_ratio, _hpBarY + _barH, c_blue, c_blue, c_blue, c_blue, false)
	}
	// HP text overlaid on bar
	draw_set_color(c_black)
	draw_text(_bx + _offset, _hpTextY + _offset, _hp_text)
	draw_set_color(_greyed ? c_grey : c_white)
	draw_text(_bx, _hpTextY, _hp_text)

	// PP bar (below HP, +8px gap) — same HUD style
	var _pp_text = string(_p.pp) + "/" + string(_p.ppmax) + " PP"
	var _ppTextY = _hpBarY + _barH + 8
	var _ppBarY = _ppTextY + _text_h - _barH - 4
	var _pp_ratio = (_p.ppmax > 0) ? _p.pp / _p.ppmax : 0
	draw_rectangle_color(_bx, _ppBarY, _bx + barW, _ppBarY + _barH, c_red, c_red, c_red, c_red, false)
	if _greyed {
		draw_rectangle_color(_bx, _ppBarY, _bx + barW * _pp_ratio, _ppBarY + _barH, c_grey, c_grey, c_grey, c_grey, false)
	} else {
		draw_rectangle_color(_bx, _ppBarY, _bx + barW * _pp_ratio, _ppBarY + _barH, c_blue, c_blue, c_blue, c_blue, false)
	}
	// PP text overlaid on bar
	draw_set_color(c_black)
	draw_text(_bx + _offset, _ppTextY + _offset, _pp_text)
	draw_set_color(_greyed ? c_grey : c_white)
	draw_text(_bx, _ppTextY, _pp_text)

	// ATK / DEF stats (right of PP bar)
	var _stat_x = _bx + barW + 10
	var _atk_total = _p.atk + (variable_struct_exists(_p, "atkmod") ? _p.atkmod : 0)
	var _def_total = _p.def + (variable_struct_exists(_p, "defmod") ? _p.defmod : 0)
	var _atk_str = "ATK " + string(_atk_total)
	var _def_str = "DEF " + string(_def_total)
	// ATK (aligned with HP bar)
	draw_set_color(c_black)
	draw_text(_stat_x + _offset, _hpTextY + _offset, _atk_str)
	var _atk_col = c_white
	if !_greyed and variable_struct_exists(_p, "atkmod") {
		if _p.atkmod > 0 { _atk_col = c_lime }
		else if _p.atkmod < 0 { _atk_col = c_red }
	}
	if _greyed { _atk_col = c_grey }
	draw_set_color(_atk_col)
	draw_text(_stat_x, _hpTextY, _atk_str)
	// DEF (aligned with PP bar)
	draw_set_color(c_black)
	draw_text(_stat_x + _offset, _ppTextY + _offset, _def_str)
	var _def_col = c_white
	if !_greyed and variable_struct_exists(_p, "defmod") {
		if _p.defmod > 0 { _def_col = c_lime }
		else if _p.defmod < 0 { _def_col = c_red }
	}
	if _greyed { _def_col = c_grey }
	draw_set_color(_def_col)
	draw_text(_stat_x, _ppTextY, _def_str)

	// Equipment row: weapon + armor[0..3] + gap + inventory[0..4]
	var _ex = _cx
	var _ey = _cy + portraitSize + _barH

	// Weapon
	var _wspr = asset_get_index(global.itemcardlist[_p.weapon].alias)
	if _wspr != -1 {
		if _greyed { draw_set_alpha(0.4) }
		draw_sprite_stretched(_wspr, 0, _ex, _ey, itemSize, itemSize)
		draw_set_alpha(1.0)
	}
	_ex += itemSize + 2

	// Armor (4 slots)
	for (var _a = 0; _a < 4; _a++) {
		var _aspr = Blank_Item
		if _a < array_length(_p.armor) and _p.armor[_a] != -1 {
			_aspr = asset_get_index(global.itemcardlist[_p.armor[_a]].alias)
			if _aspr == -1 { _aspr = Blank_Item }
		}
		if _greyed { draw_set_alpha(0.4) }
		draw_sprite_stretched(_aspr, 0, _ex, _ey, itemSize, itemSize)
		draw_set_alpha(1.0)
		_ex += itemSize + 2
	}

	_ex += 8 // gap between armor and inventory

	// Inventory (5 slots)
	for (var _v = 0; _v < 5; _v++) {
		var _ispr = Blank_Item
		if _v < array_length(_p.inventory) and _p.inventory[_v] != -1 {
			_ispr = asset_get_index(global.itemcardlist[_p.inventory[_v]].alias)
			if _ispr == -1 { _ispr = Blank_Item }
		}
		if _greyed { draw_set_alpha(0.4) }
		draw_sprite_stretched(_ispr, 0, _ex, _ey, itemSize, itemSize)
		draw_set_alpha(1.0)
		_ex += itemSize + 2
	}

	// Status row: atk/def tokens + status icons
	var _sx = _cx + portraitSize + 8
	var _sy = _ey + itemSize + 10
	var _iconSize = 28

	// ATK mod
	if variable_struct_exists(_p, "atkmod") and _p.atkmod != 0 {
		if _p.atkmod > 0 {
			draw_sprite_stretched(attack_up, 0, _sx, _sy, _iconSize, _iconSize)
		} else {
			draw_sprite_stretched(attack_down, 0, _sx, _sy, _iconSize, _iconSize)
		}
		_sx += _iconSize + 2
	}

	// DEF mod
	if variable_struct_exists(_p, "defmod") and _p.defmod != 0 {
		if _p.defmod > 0 {
			draw_sprite_stretched(defense_up, 0, _sx, _sy, _iconSize, _iconSize)
		} else {
			draw_sprite_stretched(defense_down, 0, _sx, _sy, _iconSize, _iconSize)
		}
		_sx += _iconSize + 2
	}

	// Status icons from GetStatus
	var _statarray = GetStatus(_p)
	for (var _j = 0; _j < array_length(_statarray); _j++) {
		draw_sprite_stretched(_statarray[_j], 0, _sx, _sy, _iconSize, _iconSize)
		_sx += _iconSize + 2
	}

	// Root tokens
	if variable_struct_exists(_p, "rootTokens") and _p.rootTokens > 0 {
		draw_sprite_stretched(Growth, 0, _sx, _sy, _iconSize, _iconSize)
		_sx += _iconSize + 2
	}

	// Regen
	if variable_struct_exists(_p, "regen") and _p.regen > 0 {
		draw_sprite_stretched(Ply, 0, _sx, _sy, _iconSize, _iconSize)
		_sx += _iconSize + 2
	}

	// Cloak
	if variable_struct_exists(_p, "cloak") and _p.cloak {
		draw_sprite_stretched(Cloak, 0, _sx, _sy, _iconSize, _iconSize)
		_sx += _iconSize + 2
	}
}

draw_set_color(c_white)
