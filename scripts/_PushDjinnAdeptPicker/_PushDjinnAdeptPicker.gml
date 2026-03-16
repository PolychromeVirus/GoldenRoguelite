/// Pushes the adept selection draft on top of the djinn picker.
/// Called from DjinnDraft on_confirm after choosing which djinn.
function _PushDjinnAdeptPicker(chosen_djinn_id) {
	var _dj = global.djinnlist[chosen_djinn_id]

	// Balance rule: can't give to anyone with more than minDjinn+1 djinn
	var _min = 999
	for (var p = 0; p < array_length(global.players); p++) {
		_min = min(_min, array_length(global.players[p].djinn))
	}

	var _items = []
	for (var i = 0; i < array_length(global.players); i++) {
		var _pl = global.players[i]
		array_push(_items, {
			name:   _pl.name,
			sprite: _pl.portrait,
			desc:   "",
			data:   { player_index: i },
		})
	}

	var _draw_adept = method({ _djinn_id: chosen_djinn_id, _min: _min }, function(i, item, cx, cy, bw, bh) {
		var _pl        = global.players[i]
		var _dj        = global.djinnlist[_djinn_id]
		var _eligible  = array_length(_pl.djinn) < _min + 1
		var _offset    = 4
		var _portsize  = 192

		// Portrait
		draw_sprite_stretched(_pl.portrait, 0, cx + bw / 2 - _portsize / 2, cy + 12, _portsize, _portsize)

		// Name
		var _namecol = _eligible ? c_white : c_gray
		var _nx = cx + bw / 2 - string_width(_pl.name) / 2
		draw_set_color(c_black)
		draw_text(_nx + _offset, cy + _portsize + 24 + _offset, _pl.name)
		draw_set_color(_namecol)
		draw_text(_nx, cy + _portsize + 24, _pl.name)

		// Djinn count
		var _countText = string(array_length(_pl.djinn)) + " djinn"
		var _countx    = cx + bw / 2 - string_width(_countText) / 2
		draw_set_color(c_black)
		draw_text(_countx + _offset, cy + _portsize + 56 + _offset, _countText)
		draw_set_color(_eligible ? c_ltgray : c_gray)
		draw_text(_countx, cy + _portsize + 56, _countText)

		// Djinn list
		var _dy = cy + _portsize + 100
		for (var d = 0; d < array_length(_pl.djinn); d++) {
			var _own_dj  = global.djinnlist[_pl.djinn[d]]
			var _djcol   = c_white
			switch _own_dj.element {
				case "Venus":   _djcol = global.c_venus;   break
				case "Mars":    _djcol = global.c_mars;    break
				case "Jupiter": _djcol = global.c_jupiter; break
				case "Mercury": _djcol = global.c_mercury; break
			}
			var _starspr = asset_get_index(_own_dj.element + "_Star")
			if _starspr != -1 { draw_sprite_stretched(_starspr, 0, cx + 16, _dy, 20, 20) }
			draw_set_color(c_black)
			draw_text(cx + 42 + _offset, _dy + _offset, _own_dj.name)
			draw_set_color(_djcol)
			draw_text(cx + 42, _dy, _own_dj.name)
			_dy += 48
		}

		if !_eligible {
			draw_set_color(make_color_rgb(200, 80, 80))
			var _lockText = "Too many djinn"
			draw_text(cx + bw / 2 - string_width(_lockText) / 2, _dy, _lockText)
		} else {
			// Show incoming djinn for selected adept
			if i == 0 {  // can't check 'selected' here — use item comparison via loop caller
				// incoming shown in all eligible slots for clarity
			}
			// Show +djinn name
			var _elemcol = c_white
			switch _dj.element {
				case "Venus":   _elemcol = global.c_venus;   break
				case "Mars":    _elemcol = global.c_mars;    break
				case "Jupiter": _elemcol = global.c_jupiter; break
				case "Mercury": _elemcol = global.c_mercury; break
			}
			draw_set_color(c_black)
			draw_text(cx + 16 + _offset, _dy + 4 + _offset, "+ " + _dj.name)
			draw_set_color(_elemcol)
			draw_text(cx + 16, _dy + 4, "+ " + _dj.name)
		}

		// Chosen djinn info footer
		var _infoy = 600
		var _djport = asset_get_index(_dj.element + "_Djinni")
		if _djport != -1 { draw_sprite_stretched(_djport, 0, 50, _infoy - 16, 64, 64) }
		var _fc = c_white
		switch _dj.element {
			case "Venus":   _fc = global.c_venus;   break
			case "Mars":    _fc = global.c_mars;    break
			case "Jupiter": _fc = global.c_jupiter; break
			case "Mercury": _fc = global.c_mercury; break
		}
		draw_set_color(c_black)
		draw_text(126 + _offset, _infoy + 20 + _offset, _dj.name + " (" + _dj.element + ")")
		draw_set_color(_fc)
		draw_text(126, _infoy + 20, _dj.name + " (" + _dj.element + ")")
	})

	PushMenu(objMenuDraft, {
		items:      _items,
		title:      "Assign " + _dj.name + " to which adept?",
		draw_item:  _draw_adept,
		no_cancel:  true,
		filter:     method({ _min: _min }, function(i) {
			return array_length(global.players[i].djinn) >= _min + 1
		}),
		on_confirm: method({ _djinn_id: chosen_djinn_id }, function(i, item) {
			array_push(global.players[i].djinn, _djinn_id)
			InjectLog(global.players[i].name + " received " + global.djinnlist[_djinn_id].name + "!")
			DeleteButtons()
			PopMenu()  // pop adept picker
			PopMenu()  // pop djinn picker
			if global.inTown { ProcessTownFinds() } else { ProcessPostBattleQueue() }
			CreateDicePool()
			Autosave()
		}),
	})
}
