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
		var _sp = global.psynergylist[_maxSpellIDs[_ii]]
		var _prevDam = CalcPreview(_maxSpellIDs[_ii], pick.playerID)
		var _detail  = "Dmg: " + string(_prevDam) + "  Range: " + string(_sp.range)
		array_push(_items, { name: _sp.name, detail: _detail, data: { spellID: _filteredSpells[_ii] } })
	}

	_caster.dicepool = _savedPool

	PopMenu()
	PushMenu(objMenuCarousel, {
		items:         _items,
		confirm_label: "Cast",
		on_confirm:    method({ _pick: pick }, function(i, item) {
			ExhaustSummonDjinn(_pick.summonID)
			if _pick.splash != -1 {
				instance_create_depth(0, 0, -100, objSummonSplash, { spr: _pick.splash })
			}
			CastSummonSpell(item.data.spellID, _pick.playerID)
		}),
	})
}
