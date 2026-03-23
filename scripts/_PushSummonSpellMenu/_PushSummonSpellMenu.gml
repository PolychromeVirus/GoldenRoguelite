/// @function _PushSummonSpellMenu(pick)
/// @desc Build a spell-picker carousel for four-cost summon spell selection.
///       pick = { name, element, playerID, summonID, splash }
function _PushSummonSpellMenu(pick) {
	var _caster   = global.players[pick.playerID]
	var _element  = pick.element
	var _allSpells = _caster.spells

	// Build filtered + max-stage spell list
	var _filteredSpells = []
	var _maxSpellIDs    = []
	for (var _i = 0; _i < array_length(_allSpells); _i++) {
		var _sp = global.psynergylist[_allSpells[_i]]
		if _sp.element != _element { continue }

		var _maxSpell = _sp
		var _maxIdx   = _allSpells[_i]
		for (var _s = 0; _s < array_length(global.psynergylist); _s++) {
			var _c = global.psynergylist[_s]
			if _c.base == _sp.base and _c.stage > _maxSpell.stage {
				_maxSpell = _c
				_maxIdx   = _s
			}
		}

		var _dup = false
		for (var _d = 0; _d < array_length(_maxSpellIDs); _d++) {
			if _maxSpellIDs[_d] == _maxIdx { _dup = true; break }
		}
		if _dup { continue }

		array_push(_filteredSpells, _allSpells[_i])
		array_push(_maxSpellIDs, _maxIdx)
	}

	// Build fake all-6s pool for damage preview
	var _savedPool = _caster.dicepool
	var _fakePool  = []
	for (var _fi = 0; _fi < 5; _fi++) {
		var _sub = []
		for (var _fj = 0; _fj < array_length(_savedPool[_fi]); _fj++) {
			array_push(_sub, 6)
		}
		array_push(_fakePool, _sub)
	}
	_caster.dicepool = _fakePool

	// Build carousel items with damage previews
	var _items = []
	for (var _ii = 0; _ii < array_length(_maxSpellIDs); _ii++) {
		var _sp      = global.psynergylist[_maxSpellIDs[_ii]]
		var _spOrig  = global.psynergylist[_filteredSpells[_ii]]
		var _prev    = CalcPreview("spell", _maxSpellIDs[_ii], _caster)
		var _detail  = ""
		var _detail_color = c_white
		if _prev.description != "" and _prev.description != "?" {
			_detail = _prev.description
			if _prev.heal > 0 { _detail_color = make_color_rgb(80, 220, 80) }
			else { _detail_color = ElementColor(_prev.element) }
		}
		var _desc = BuildVerboseDesc("spell", _maxSpellIDs[_ii], _caster)
		array_push(_items, {
			name:         _sp.name + " - " + string(_spOrig.cost) + " PP",
			element:      _sp.element,
			sprite:       asset_get_index(_sp.alias),
			right_sprite: asset_get_index("range_" + _sp.range),
			detail:       _detail,
			detail_color: _detail_color,
			desc:         _desc,
			data:         { spellID: _filteredSpells[_ii] },
		})
	}

	_caster.dicepool = _savedPool

	PopMenu()
	PushMenu(objMenuCarousel, {
		items:         _items,
		description:   "quarter",
		confirm_label: "Cast",
		draw_pane: method(undefined, function(sel, item) {
			var _descx  = 820
			var _descy  = 411
			var _offset = 4
			draw_rich_text(_descx, _descy, item.desc, 660, _offset, GoldenSun, 40, 6)
		}),
		on_confirm: method({ _pick: pick }, function(i, item) {
			ExhaustSummonDjinn(_pick.summonID)
			if _pick.splash != -1 {
				instance_create_depth(0, 0, -100, objSummonSplash, { spr: _pick.splash })
			}
			CastSummonSpell(item.data.spellID, _pick.playerID)
		}),
	})
}
