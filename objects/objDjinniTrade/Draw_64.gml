draw_sprite_ext(TestMenu, 0, 0, 0, 6, 6, 0, c_white, 1)

var offset = 4
draw_set_font(GoldenSun)

var _djinn = global.djinnlist[sourceDjinn]

// Title — djinn name + element, color-coded
var _elemCol = c_white
switch _djinn.element {
	case "Venus": _elemCol = global.c_venus; break
	case "Mars": _elemCol = global.c_mars; break
	case "Jupiter": _elemCol = global.c_jupiter; break
	case "Mercury": _elemCol = global.c_mercury; break
}
var _titleText = "Trading " + _djinn.name + " (" + _djinn.element + ")"
draw_set_color(c_black)
draw_text(50 + offset, 30 + offset, _titleText)
draw_set_color(_elemCol)
draw_text(50, 30, _titleText)

// 4 adept cards across 1536px (reuses DjinnDraft phase 1 layout)
var _cardW = 320
var _cardH = 575
var _totalW = 4 * _cardW
var _gap = (1536 - _totalW) / 5
var _startY = 80
var _portraitSize = 192

for (var i = 0; i < array_length(global.players); i++) {
	var _player = global.players[i]
	var _cx = _gap + i * (_cardW + _gap)
	var _cy = _startY
	var _isSource = (i == sourcePlayer)

	// Card background
	var _bgCol = #006080
	if _isSource { _bgCol = make_color_rgb(40, 40, 40) }
	else if i == selected { _bgCol = #005870 }
	draw_rectangle_color(_cx, _cy, _cx + _cardW, _cy + _cardH, _bgCol, _bgCol, _bgCol, _bgCol, false)

	// Selection border
	if i == selected and !_isSource {
		draw_rectangle_color(_cx - 3, _cy - 3, _cx + _cardW + 3, _cy + _cardH + 3, c_white, c_white, c_white, c_white, true)
		draw_rectangle_color(_cx - 2, _cy - 2, _cx + _cardW + 2, _cy + _cardH + 2, c_white, c_white, c_white, c_white, true)
	} else {
		draw_rectangle_color(_cx, _cy, _cx + _cardW, _cy + _cardH, _bgCol, _bgCol, _bgCol, _bgCol, true)
	}

	// Portrait
	draw_sprite_stretched(_player.portrait, 0, _cx + _cardW / 2 - _portraitSize / 2, _cy + 12, _portraitSize, _portraitSize)

	// Name
	var _nameCol = _isSource ? c_gray : c_white
	var _nameX = _cx + _cardW / 2 - string_width(_player.name) / 2
	draw_set_color(c_black)
	draw_text(_nameX + offset, _cy + _portraitSize + 24 + offset, _player.name)
	draw_set_color(_nameCol)
	draw_text(_nameX, _cy + _portraitSize + 24, _player.name)

	//// Djinn count
	//var _countText = string(array_length(_player.djinn)) + " djinn"
	//var _countX = _cx + _cardW / 2 - string_width(_countText) / 2
	//draw_set_color(c_black)
	//draw_text(_countX + offset, _cy + _portraitSize + 64 + offset, _countText)
	//draw_set_color(_isSource ? c_gray : c_ltgray)
	//draw_text(_countX, _cy + _portraitSize + 64, _countText)

	// Source label
	//if _isSource {
	//	var _srcText = "(Trading)"
	//	var _srcX = _cx + _cardW / 2 - string_width(_srcText) / 2
	//	draw_set_color(c_yellow)
	//	draw_text(_srcX, _cy + _portraitSize + 80, _srcText)
	//}

	// Current djinn list
	var _dy = _cy + _portraitSize + 70
	for (var d = 0; d < array_length(_player.djinn); d++) {
		var _dj = global.djinnlist[_player.djinn[d]]
		var _djCol = c_white
		switch _dj.element {
			case "Venus": _djCol = global.c_venus; break
			case "Mars": _djCol = global.c_mars; break
			case "Jupiter": _djCol = global.c_jupiter; break
			case "Mercury": _djCol = global.c_mercury; break
		}

		// Highlight target slot on selected card
		var _isTargetSlot = (!_isSource and i == selected and d == targetSlot)
		if _isTargetSlot {
			draw_rectangle_color(_cx + 8, _dy - 4, _cx + _cardW - 8, _dy + 36, #003050, #003050, #003050, #003050, false)
			draw_rectangle_color(_cx + 8, _dy - 4, _cx + _cardW - 8, _dy + 36, c_yellow, c_yellow, c_yellow, c_yellow, true)
		}

		var _djStarSpr = asset_get_index(_dj.element + "_Star")
		if _djStarSpr != -1 {
			draw_sprite_stretched(_djStarSpr, 0, _cx + 16, _dy+4, 20, 20)
		}
		draw_set_color(c_black)
		draw_text(_cx + 42 + offset, _dy + offset, _dj.name)
		draw_set_color(_djCol)
		draw_text(_cx + 42, _dy, _dj.name)

	

		_dy += 48
	}

	// "Give" slot (one past end) — only if target won't exceed balance rule
	// After a give: source loses 1, target gains 1. Valid if no one ends up with >1 more than anyone else.
	if !_isSource and i == selected {
		var _sourceCount = array_length(global.players[sourcePlayer].djinn)
		var _targetCount = array_length(_player.djinn)
		// Post-give: source has _sourceCount-1, target has _targetCount+1
		// Check that target+1 <= min(all post-counts) + 1
		var _canGive = true
		var _postMin = _sourceCount - 1 // source will be smallest or tied
		for (var p = 0; p < array_length(global.players); p++) {
			var _pc = array_length(global.players[p].djinn)
			if p == sourcePlayer { _pc -= 1 }
			else if p == i { _pc += 1 }
			_postMin = min(_postMin, _pc)
		}
		if (_targetCount + 1) > _postMin + 1 { _canGive = false }

		if _canGive {
			var _isGiveSlot = (targetSlot == array_length(_player.djinn))
			if _isGiveSlot {
				draw_rectangle_color(_cx + 8, _dy - 4, _cx + _cardW - 8, _dy + 36, #003050, #003050, #003050, #003050, false)
				draw_rectangle_color(_cx + 8, _dy - 4, _cx + _cardW - 8, _dy + 36, c_yellow, c_yellow, c_yellow, c_yellow, true)
			}
			draw_set_color(c_black)
			draw_text(_cx + 16 + offset, _dy + offset, "+ " + _djinn.name)
			draw_set_color(_isGiveSlot ? c_yellow : c_ltgray)
			draw_text(_cx + 16, _dy, "+ " + _djinn.name)
		}
	}
}

// Djinn portrait next to title
var _djinnPortrait = asset_get_index(_djinn.element + "_Djinni")
if _djinnPortrait != -1 {
	draw_sprite_stretched(_djinnPortrait, 0, 50 + string_width(_titleText) + 12, 14, 48, 48)
}
