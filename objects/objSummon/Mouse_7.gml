
// Don't push if a menu is already open
if array_length(global.menu_stack) > 0 { exit }

// Build items from known summons
var _items = []
for (var i = 0; i < array_length(global.knownSummons); i++) {
	var _id     = global.knownSummons[i]
	var _summon = global.summonlist[_id]
	var _spr    = asset_get_index(_summon.alias)

	var _desc = BuildVerboseDesc("summon", _id, global.players[global.turn])
	var _prev = CalcPreview("summon", _id, global.players[global.turn])
	var _detail_text = ""
	var _detail_color = c_white
	if global.inCombat and _prev.description != "" {
		_detail_text = _prev.description
		if _prev.heal > 0 { _detail_color = make_color_rgb(80, 220, 80) }
		else if _prev.dam > 0 { _detail_color = ElementColor(_summon.element) }
	}

	array_push(_items, {
		name:         _summon.name,
		sprite:       (_spr != -1) ? _spr : -1,
		detail:       _detail_text,
		detail_color: _detail_color,
		desc:         _desc,
		data:         { summon_id: _id },
		cost_venus:   _summon.venus,
		cost_mars:    _summon.mars,
		cost_jupiter: _summon.jupiter,
		cost_mercury: _summon.mercury,
		is_charon:    (_summon.name == "Charon"),
	})
}

PushMenu(objMenuCarousel, {
	items:         _items,
	description:   "quarter",
	confirm_label: "Summon",
	filter:        method({ _items: _items }, function(i) {
		return !isSummonable(global.summonlist[_items[i].data.summon_id])
	}),
	on_confirm: function(i, item) {
		DeleteButtons()
		PopMenu()
		CastSummon(item.data.summon_id, global.turn)
	},
	draw_pane: method(undefined, function(sel, item) {
		var _descx     = 820
		var _descy     = 406
		var _offset    = 4
		var _star_size = 48
		var _star_gap  = -8
		var _cx        = _descx

		draw_set_font(GoldenSun)

		var _elements = ["Venus", "Mars", "Jupiter", "Mercury"]
		var _costs    = [item.cost_venus, item.cost_mars, item.cost_jupiter, item.cost_mercury]

		if item.is_charon {
			repeat (2) {
				draw_sprite_stretched(asset_get_index("None_Star_Clean"), 0, _cx, _descy, _star_size, _star_size)
				_cx += _star_size + _star_gap
			}
		} else {
			for (var _e = 0; _e < 4; _e++) {
				repeat (_costs[_e]) {
					draw_sprite_stretched(asset_get_index(_elements[_e] + "_Star_Clean"), 0, _cx, _descy, _star_size, _star_size)
					_cx += _star_size + _star_gap
				}
			}
		}

		var _text_y = _descy + _star_size + _offset + 4
		draw_rich_text(_descx, _text_y, item.desc, 660, _offset, GoldenSun, 40, 5)
	}),
})
