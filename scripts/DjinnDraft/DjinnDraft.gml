/// DjinnDraft()
/// Picks 3 random djinn not already owned by any adept, spawns the draft UI.
function DjinnDraft() {
	// Collect all djinn IDs not currently owned by any player
	var _available = []
	for (var i = 0; i < array_length(global.djinnlist); i++) {
		var _owned = false
		for (var p = 0; p < array_length(global.players); p++) {
			for (var d = 0; d < array_length(global.players[p].djinn); d++) {
				if global.players[p].djinn[d] == i { _owned = true; break }
			}
			if _owned { break }
		}
		if !_owned and real(global.djinnlist[i].chapter) <= global.dungeon + 1{ array_push(_available, i) }
	}

	// Shuffle (Fisher-Yates)
	var _len = array_length(_available)
	for (var i = _len - 1; i > 0; i--) {
		var j = irandom(i)
		var _tmp = _available[i]
		_available[i] = _available[j]
		_available[j] = _tmp
	}

	// Take up to 3
	var _count = min(_len, 3)
	global.djinnDraftPool = []
	for (var i = 0; i < _count; i++) {
		array_push(global.djinnDraftPool, _available[i])
	}

	if _count > 0 {
		var _pool  = global.djinnDraftPool
		var _items = []
		for (var i = 0; i < array_length(_pool); i++) {
			var _dj = global.djinnlist[_pool[i]]
			array_push(_items, {
				name:   _dj.name,
				sprite: asset_get_index(_dj.element),
				desc:   _dj.text,
				data:   { djinn_id: _pool[i] },
			})
		}

		var _draw_djinn = method({ _pool: _pool }, function(i, item, cx, cy, bw, bh) {
			var _dj     = global.djinnlist[_pool[i]]
			var _offset = 4
			var _spr    = asset_get_index(_dj.element)
			if _spr != -1 { draw_sprite_stretched(_spr, 0, cx, cy, 128, 128) }
			var _portsize = 64
			var _star = asset_get_index(_dj.element + "_Star_Clean")
			if _star != -1 { draw_sprite_stretched(_star, 0, cx + 132, cy + 4, _portsize, _portsize) }
			var _namey = cy + 4 + (_portsize / 2) - (string_height(_dj.name) / 2)
			var _namex = cx + 136 + _portsize
			draw_set_color(c_black)
			draw_text(_namex + _offset, _namey + _offset, _dj.name)
			draw_set_color(c_white)
			draw_text(_namex, _namey, _dj.name)
			var _elemcol = c_white
			switch _dj.element {
				case "Venus":   _elemcol = global.c_venus;   break
				case "Mars":    _elemcol = global.c_mars;    break
				case "Jupiter": _elemcol = global.c_jupiter; break
				case "Mercury": _elemcol = global.c_mercury; break
			}
			var _elemx = _namex - 48
			var _elemy = _namey + string_height("Venus") + 16
			draw_set_color(c_black)
			draw_text(_elemx + _offset, _elemy + _offset, _dj.element)
			draw_set_color(_elemcol)
			draw_text(_elemx, _elemy, _dj.element)
			draw_set_color(c_black)
			draw_text_ext(cx + 20 + _offset, cy + 140 + _offset, _dj.text, 36, bw - 40)
			draw_set_color(c_ltgray)
			draw_text_ext(cx + 20, cy + 140, _dj.text, 36, bw - 40)
		})

		PushMenu(objMenuDraft, {
			items:      _items,
			title:      "Elemental Star - Choose a Djinni",
			draw_item:  _draw_djinn,
			no_cancel:  true,
			on_confirm: method({ _pool: _pool }, function(i, item) {
				var _chosen_id = _pool[i]
				// Phase 2: push adept picker
				_PushDjinnAdeptPicker(_chosen_id)
			}),
		})
	}
}
