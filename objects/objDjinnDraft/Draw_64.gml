if instance_exists(objStatDisplay) { exit }
var offset = 4
draw_set_font(GoldenSun)

if phase == 0 {
	// Phase 0: Pick a djinni from 3 — full-width layout
	// Title
	draw_set_color(c_black)
	draw_text(50 + offset, 30 + offset, "Elemental Star - Choose a Djinni")
	draw_set_color(c_yellow)
	draw_text(50, 30, "Elemental Star - Choose a Djinni")

	// 3 large boxes across 1536px
	var _boxW = 440
	var _boxH = 550
	var _totalW = 3 * _boxW
	var _gap = (1536 - _totalW) / 4  // even margins
	var _startY = 80

	for (var i = 0; i < array_length(djinnPool); i++) {
		var _djinn = global.djinnlist[djinnPool[i]]
		var _cx = _gap + i * (_boxW + _gap)
		var _cy = _startY

		// Card background
		var _bgCol = #006080
		if i == selected { _bgCol = #005870 }
		draw_rectangle_color(_cx, _cy, _cx + _boxW, _cy + _boxH, _bgCol, _bgCol, _bgCol, _bgCol, false)

		// Selection border
		if i == selected {
			draw_rectangle_color(_cx - 3, _cy - 3, _cx + _boxW + 3, _cy + _boxH + 3, c_white, c_white, c_white, c_white, true)
			draw_rectangle_color(_cx - 2, _cy - 2, _cx + _boxW + 2, _cy + _boxH + 2, c_white, c_white, c_white, c_white, true)
		} else {
			draw_rectangle_color(_cx, _cy, _cx + _boxW, _cy + _boxH, _bgCol, _bgCol, _bgCol, _bgCol, true)
		}

		// Djinni portrait (64x64 scaled to 128x128, centered)
		var _portraitSprite = asset_get_index(_djinn.element)
		if _portraitSprite != -1 {
			draw_sprite_stretched(_portraitSprite, 0, _cx, _cy, 128, 128)
		}
		
		var portsize = 64
		
		// Element star (6x6 scaled to 40x40)
		var _starSprite = asset_get_index(_djinn.element + "_Star_Clean")
		if _starSprite != -1 {
			draw_sprite_stretched(_starSprite, 0, _cx + 132, _cy + 4, portsize,portsize)
		}
		
		var namey = _cy + 4 + (portsize/2) - (string_height(_djinn.name)/2)
		
		// Djinni name
		var _nameX = _cx + 136 + portsize
		draw_set_color(c_black)
		draw_text(_nameX + offset, namey + offset, _djinn.name)
		draw_set_color(c_white)
		draw_text(_nameX, namey, _djinn.name)

		// Element label (colored)
		var _elemCol = c_white
		switch _djinn.element {
			case "Venus": _elemCol = global.c_venus; break
			case "Mars": _elemCol = global.c_mars; break
			case "Jupiter": _elemCol = global.c_jupiter; break
			case "Mercury": _elemCol = global.c_mercury; break
		}
		var _elemText = _djinn.element
		var _elemX = _nameX - 48
		draw_set_color(c_black)
		draw_text(_elemX + offset, namey + string_height("Venus") + 16 + offset, _elemText)
		draw_set_color(_elemCol)
		draw_text(_elemX, namey + string_height("Venus") + 16, _elemText)

		// Description text (wrapped)
		draw_set_color(c_black)
		draw_text_ext(_cx + 20 + offset, _cy + 140 + offset, _djinn.text, 36, _boxW - 40)
		draw_set_color(c_ltgray)
		draw_text_ext(_cx + 20, _cy + 140, _djinn.text, 36, _boxW - 40)
	}

} else {
	// Phase 1: Pick an adept to receive the djinni — full-width layout
	var _djinn = global.djinnlist[chosenDjinn]

	// Title
	draw_set_color(c_black)
	draw_text(50 + offset, 30 + offset, "Assign " + _djinn.name + " to which adept?")
	draw_set_color(c_yellow)
	draw_text(50, 30, "Assign " + _djinn.name + " to which adept?")

	// 4 adept cards across 1536px
	var _cardW = 320
	var _cardH = 500
	var _totalW = 4 * _cardW
	var _gap = (1536 - _totalW) / 5
	var _startY = 80
	var _portraitSize = 192

	// Calculate min djinn count for the balance rule
	var _minDjinn = 999
	for (var p = 0; p < array_length(global.players); p++) {
		_minDjinn = min(_minDjinn, array_length(global.players[p].djinn))
	}

	for (var i = 0; i < array_length(global.players); i++) {
		var _player = global.players[i]
		var _cx = _gap + i * (_cardW + _gap)
		var _cy = _startY
		var _eligible = array_length(_player.djinn) < _minDjinn + 1

		// Card background
		var _bgCol = #006080
		if !_eligible { _bgCol = make_color_rgb(40, 20, 20) }
		else if i == selected { _bgCol = #005870 }
		draw_rectangle_color(_cx, _cy, _cx + _cardW, _cy + _cardH, _bgCol, _bgCol, _bgCol, _bgCol, false)

		// Selection border
		if i == selected and _eligible {
			draw_rectangle_color(_cx - 3, _cy - 3, _cx + _cardW + 3, _cy + _cardH + 3, c_white, c_white, c_white, c_white, true)
			draw_rectangle_color(_cx - 2, _cy - 2, _cx + _cardW + 2, _cy + _cardH + 2, c_white, c_white, c_white, c_white, true)
		} else {
			draw_rectangle_color(_cx, _cy, _cx + _cardW, _cy + _cardH, #006080, #006080, #006080, #006080, true)
		}

		// Portrait (centered, large)
		draw_sprite_stretched(_player.portrait, 0, _cx + _cardW / 2 - _portraitSize / 2, _cy + 12, _portraitSize, _portraitSize)

		// Name
		var _nameX = _cx + _cardW / 2 - string_width(_player.name) / 2
		var _nameCol = _eligible ? c_white : c_gray
		draw_set_color(c_black)
		draw_text(_nameX + offset, _cy + _portraitSize + 24 + offset, _player.name)
		draw_set_color(_nameCol)
		draw_text(_nameX, _cy + _portraitSize + 24, _player.name)

		// Djinn count
		var _countText = string(array_length(_player.djinn)) + " djinn"
		var _countX = _cx + _cardW / 2 - string_width(_countText) / 2
		draw_set_color(c_black)
		draw_text(_countX + offset, _cy + _portraitSize + 56 + offset, _countText)
		draw_set_color(_eligible ? c_ltgray : c_gray)
		draw_text(_countX, _cy + _portraitSize + 56, _countText)

		// Ineligible label
		

		// Current djinn list inline
		var _dy = _cy + _portraitSize + 100
		for (var d = 0; d < array_length(_player.djinn); d++) {
			var _dj = global.djinnlist[_player.djinn[d]]
			var _djCol = c_white
			switch _dj.element {
				case "Venus": _djCol = global.c_venus; break
				case "Mars": _djCol = global.c_mars; break
				case "Jupiter": _djCol = global.c_jupiter; break
				case "Mercury": _djCol = global.c_mercury; break
			}
			var _djStarSpr = asset_get_index(_dj.element + "_Star")
			if _djStarSpr != -1 {
				draw_sprite_stretched(_djStarSpr, 0, _cx + 16, _dy, 20, 20)
			}
			draw_set_color(c_black)
			draw_text(_cx + 42 + offset, _dy + offset, _dj.name)
			draw_set_color(_djCol)
			draw_text(_cx + 42, _dy, _dj.name)
			_dy += 48
		}

		if !_eligible {
			draw_set_color(make_color_rgb(200, 80, 80))
			var _lockText = "Too many djinn"
			draw_text(_cx + _cardW / 2 - string_width(_lockText) / 2, _dy, _lockText)
		}

		// Show incoming djinni for selected adept
		if i == selected and _eligible {
			_dy += 4
			draw_set_color(c_black)
			draw_text(_cx + 16 + offset, _dy + offset, "+ " + _djinn.name)
			draw_set_color(c_yellow)
			draw_text(_cx + 16, _dy, "+ " + _djinn.name)
		}
	}

	// Chosen djinn info at bottom
	var _infoY = 600
	var _djinnPortrait = asset_get_index(_djinn.element + "_Djinni")
	if _djinnPortrait != -1 {
		draw_sprite_stretched(_djinnPortrait, 0, 50, _infoY-16, 64, 64)
	}
	var _elemCol = c_white
	switch _djinn.element {
		case "Venus": _elemCol = global.c_venus; break
		case "Mars": _elemCol = global.c_mars; break
		case "Jupiter": _elemCol = global.c_jupiter; break
		case "Mercury": _elemCol = global.c_mercury; break
	}
	draw_set_color(c_black)
	draw_text(126 + offset, _infoY +20 + offset, _djinn.name + " (" + _djinn.element + ")")
	draw_set_color(_elemCol)
	draw_text(126, _infoY + 20, _djinn.name + " (" + _djinn.element + ")")

}
