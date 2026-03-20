/// Builds the objMenuCarousel config struct for a psynergy draft.
/// Reads global.draftPool and global.draftPlayerIndex — call after setting those.
function _BuildPsynergyDraftConfig() {
	var _pool      = global.draftPool
	var _playerIdx = global.draftPlayerIndex

	// Build item list
	var _items = []
	for (var i = 0; i < array_length(_pool); i++) {
		var _spell     = global.psynergylist[_pool[i]]
		var _spr       = asset_get_index(_spell.alias)
		var _range_spr = asset_get_index("range_" + string(_spell.range))
		array_push(_items, {
			name:         _spell.name + " - " + string(_spell.cost) + " PP",
			sprite:       (_spr != -1) ? _spr : -1,
			element:      _spell.element,
			right_sprite: (_range_spr != -1) ? _range_spr : -1,
			data:         { pool_index: i },
		})
	}

	// Right-panel draw callback
	var _draw_pane = method({ _pool: _pool, _playerIdx: _playerIdx }, function(sel, item) {
		var _player  = global.players[_playerIdx]
		var _offset  = 4
		var _portraitX = 820
		var _portraitY = 50
		draw_set_font(GoldenSun)

		// Portrait + player name
		draw_sprite_stretched(_player.portrait, 0, _portraitX, _portraitY, 128, 128)
		draw_set_color(c_black)
		draw_text(_portraitX + 136 + _offset, _portraitY + _offset, _player.name + " - Learn Psynergy")
		draw_set_color(c_white)
		draw_text(_portraitX + 136, _portraitY, _player.name + " - Learn Psynergy")

		// Dice pool display
		var _dx         = _portraitX + 136
		var _dy         = _portraitY + 40
		var _diceSize   = 28
		var _dicePad    = 4
		var _groupGap   = 8
		var _poolCounts = [_player.melee, _player.venus, _player.mars, _player.jupiter, _player.mercury]
		var _poolColors = [0x303030, #ffe45f, #ff8585, #e7abff, #a6c9ff]
		for (var _p = 0; _p < 5; _p++) {
			if _poolCounts[_p] == 0 { continue }
			for (var _d = 0; _d < _poolCounts[_p]; _d++) {
				draw_rectangle_color(_dx, _dy, _dx + _diceSize, _dy + _diceSize,
					_poolColors[_p], _poolColors[_p], _poolColors[_p], _poolColors[_p], false)
				draw_rectangle_color(_dx, _dy, _dx + _diceSize, _dy + _diceSize,
					make_color_rgb(60,60,60), make_color_rgb(60,60,60),
					make_color_rgb(60,60,60), make_color_rgb(60,60,60), true)
				_dx += _diceSize + _dicePad
			}
			_dx += _groupGap
		}

		// Selected spell detail
		var _selspell = global.psynergylist[_pool[sel]]
		var _descx = 820
		var _descy = _portraitY + 135

		draw_set_color(c_black)
		draw_text(_descx + _offset, _descy + _offset, _selspell.name + " - " + string(_selspell.cost) + " PP")
		draw_set_color(c_white)
		draw_text(_descx, _descy, _selspell.name + " - " + string(_selspell.cost) + " PP")
		draw_sprite_stretched(asset_get_index(_selspell.element + "_Star"), 0, _descx + 400, _descy, 32, 32)

		if asset_get_index("range_" + string(_selspell.range)) != -1 {
			draw_sprite_stretched(asset_get_index("range_" + string(_selspell.range)), 0, _descx, _descy + 40, 96, 32)
		}

		var _stageText = "Stage " + string(_selspell.stage)
		if _selspell.stage > 1 {
			var _prevID = FindPsyID(_selspell.base, _selspell.stage - 1)
			if _prevID != 0 { _stageText += " (Evolves from " + global.psynergylist[_prevID].name + ")" }
		}
		draw_set_color(c_black)
		draw_text(_descx + _offset, _descy + 80 + _offset, _stageText)
		draw_set_color(c_yellow)
		draw_text(_descx, _descy + 80, _stageText)

		var _desctext = _selspell.text
		draw_set_color(c_black)
		draw_text_ext(_descx + _offset, _descy + 120 + _offset, _desctext, 40, 660)
		draw_set_color(c_white)
		draw_text_ext(_descx, _descy + 120, _desctext, 40, 660)

		if global.inCombat and array_length(_player.dicepool) > 0 {
		}
	})

	return {
		items:         _items,
		title:         "Select 1 Psynergy to learn:",
		description:   "half",
		confirm_label: "Select",
		no_cancel:     true,
		draw_pane:     _draw_pane,
		on_confirm:    method({ _pool: _pool, _playerIdx: _playerIdx }, function(i, item) {
			var _selspell = global.psynergylist[_pool[i]]
			LearnPsy(_selspell.base, _playerIdx)
			PopMenu()
			_DraftNext()
		}),
	}
}
