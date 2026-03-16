/// SummonDraft()
/// Picks 2 random summons not already known, spawns the draft UI.
function SummonDraft() {
	// Collect summon indices not yet in knownSummons
	var _available = []
	for (var i = 0; i < array_length(global.summonlist); i++) {
		if !array_contains(global.knownSummons, i) {
			array_push(_available, i)
		}
	}

	// Shuffle
	_available = array_shuffle(_available)

	// Take up to 2
	var _count = min(array_length(_available), 2)
	global.summonDraftPool = []
	for (var i = 0; i < _count; i++) {
		array_push(global.summonDraftPool, _available[i])
	}

	if _count > 0 {
		var _pool = global.summonDraftPool
		var _items = []
		for (var i = 0; i < array_length(_pool); i++) {
			var _s = global.summonlist[_pool[i]]
			array_push(_items, {
				name:   _s.name,
				sprite: asset_get_index(_s.alias),
				desc:   _s.text,
				data:   { summon_id: _pool[i] },
			})
		}

		var _draw = method({ _pool: _pool }, function(i, item, cx, cy, bw, bh) {
			var _s      = global.summonlist[_pool[i]]
			var _offset = 4
			var _spr    = asset_get_index(_s.alias)
			if _spr != -1 { draw_sprite_stretched(_spr, 0, cx, cy + 16, 128, 128) }
			var _portsize = 64
			var _star = asset_get_index(_s.element + "_Star_Clean")
			if _star != -1 { draw_sprite_stretched(_star, 0, cx + 132, cy + 4, _portsize, _portsize) }
			var _namey  = cy + 4 + (_portsize / 2) - (string_height(_s.name) / 2)
			var _namex  = cx + 136 + _portsize
			draw_set_color(c_black)
			draw_text(_namex + _offset, _namey + _offset, _s.name)
			draw_set_color(c_white)
			draw_text(_namex, _namey, _s.name)
			var _elemcol = c_white
			switch _s.element {
				case "Venus":   _elemcol = global.c_venus;   break
				case "Mars":    _elemcol = global.c_mars;    break
				case "Jupiter": _elemcol = global.c_jupiter; break
				case "Mercury": _elemcol = global.c_mercury; break
			}
			var _elemx = _namex - 48
			var _elemy = _namey + string_height("Venus") + 16
			draw_set_color(c_black)
			draw_text(_elemx + _offset, _elemy + _offset, _s.element)
			draw_set_color(_elemcol)
			draw_text(_elemx, _elemy, _s.element)
			var _cost = ""
			if _s.venus   > 0 { _cost += string(_s.venus)   + "V " }
			if _s.mars    > 0 { _cost += string(_s.mars)    + "Ma " }
			if _s.jupiter > 0 { _cost += string(_s.jupiter) + "J " }
			if _s.mercury > 0 { _cost += string(_s.mercury) + "Me " }
			_cost = string_trim(_cost)
			var _costy = _elemy + string_height("Venus") + 16
			draw_set_color(c_black)
			draw_text(_elemx + _offset, _costy + _offset, "Cost: " + _cost)
			draw_set_color(c_ltgray)
			draw_text(_elemx, _costy, "Cost: " + _cost)
			draw_set_color(c_black)
			draw_text_ext(cx + 20 + _offset, cy + 180 + _offset, _s.text, 36, bw - 40)
			draw_set_color(c_ltgray)
			draw_text_ext(cx + 20, cy + 180, _s.text, 36, bw - 40)
		})

		PushMenu(objMenuDraft, {
			items:      _items,
			title:      "Summon Tablet - Choose a Summon",
			draw_item:  _draw,
			no_cancel:  true,
			on_confirm: method({ _pool: _pool }, function(i, item) {
				var _id = _pool[i]
				array_push(global.knownSummons, _id)
				InjectLog("Learned summon: " + global.summonlist[_id].name + "!")
				DeleteButtons()
				PopMenu()
				if global.inTown { ProcessTownFinds() } else { ProcessPostBattleQueue() }
				Autosave()
				// Reveal check
				if !irandom(9) and array_length(global.postBattleQueue) == 0 {
					var _cast = FindSpellCaster("Reveal")
					if _cast != -1 {
						SpellPrompt("Reveal", _cast,
						function() { SummonDraft() },
						function() {}
					)
					}
				}
			}),
		})
	} else {
		// All summons already known, skip
		ProcessPostBattleQueue()
	}
}
