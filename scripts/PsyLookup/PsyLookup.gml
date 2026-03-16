// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function PsyLookup(spellid){
	var _entries = []
	for (var _i = 0; _i < array_length(global.psynergylist); _i++) {
		var _sp = global.psynergylist[_i]
		array_push(_entries, {
			name:    _sp.name,
			spell:   _sp,
		})
	}

	PushMenu(objMenuLibrary, {
		entries:    _entries,
		start_index: spellid,
		draw_entry: function(entry, i) {
			var _sp     = entry.spell
			var _drawx  = 50
			var _drawy  = 120
			var _offset = 4
			var _nl     = 72

			if _sp.character != "" {
				var _charpic = asset_get_index(_sp.character)
				if _charpic == -1 { _charpic = Unidentified }
				draw_sprite_stretched(_charpic, 0, 1536 - _drawx - 128, _drawy, 128, 128)
			}

			draw_sprite_stretched(asset_get_index(_sp.element + "_Star"), 0, _drawx + 16, _drawy, 32, 32)
			draw_set_color(c_black)
			draw_text(_drawx + 72 + _offset, _drawy + _offset, _sp.element + " - " + string(_sp.cost) + " PP")
			draw_set_color(c_white)
			draw_text(_drawx + 72, _drawy, _sp.element + " - " + string(_sp.cost) + " PP")

			_drawy += _nl
			draw_sprite_stretched(asset_get_index(_sp.alias), 0, _drawx, _drawy, 64, 64)
			var _rx = _drawx + 72
			draw_sprite_stretched(asset_get_index("range_" + _sp.range), 0, _rx, _drawy + 8, 128, 43)

			var _stagetext = "Stage " + string(_sp.stage)
			if _sp.stage > 1 { _stagetext += " (Evolves from " + _sp.base + ")" }
			draw_set_color(c_black)
			draw_text(_rx + 72 + _offset, _drawy + 20 + _offset, _stagetext)
			draw_set_color(c_white)
			draw_text(_rx + 72, _drawy + 20, _stagetext)

			_drawy += _nl + 36
			draw_set_color(c_black)
			draw_text_ext(_drawx + _offset, _drawy + _offset, _sp.text, 50, 1000)
			draw_set_color(c_white)
			draw_text_ext(_drawx, _drawy, _sp.text, 50, 1000)
		},
	})
}
