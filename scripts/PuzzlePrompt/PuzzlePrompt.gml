/// @function PuzzlePrompt(puzzle_index, challenge_index)
/// @desc Push a centred prompt for a floor puzzle (disarm or skip).
function PuzzlePrompt(puzzle_index, challenge_index) {
	var _puzzle = global.puzzlelist[puzzle_index]
	var _spell  = _puzzle.spell_alias
	var _caster = -1
	var _no_caster    = false
	var _is_overload  = false
	var _overload_elem = ""

	if string_pos("Overload", _puzzle.name) > 0 {
		var _req = ""
		if      string_pos("Venus",   _puzzle.name) > 0 { _req = "jupiter" }
		else if string_pos("Mars",    _puzzle.name) > 0 { _req = "mercury" }
		else if string_pos("Jupiter", _puzzle.name) > 0 { _req = "venus"   }
		else if string_pos("Mercury", _puzzle.name) > 0 { _req = "mars"    }
		_overload_elem = _req
		_is_overload   = true
		for (var _i = 0; _i < array_length(global.players); _i++) {
			var _p = global.players[_i]
			if _p.hp <= 0 { continue }
			if string_lower(_p.element) == _req and _p.pp >= 8 { _caster = _i; break }
		}
		if _caster < 0 { _no_caster = true }
	} else if _spell == "" {
		_no_caster = true
	} else {
		_caster = FindSpellCaster(_spell)
		if _caster < 0 { _no_caster = true }
	}

	// Third line: who can disarm, or why nobody can
	var _line3 = ""
	if _no_caster {
		_line3 = _is_overload
			? "No " + _overload_elem + " adept with 8 PP!"
			: "No one can cast " + _spell + "!"
	} else {
		if _is_overload {
			_line3 = global.players[_caster].name + ": Spend 8 PP to disarm?"
		} else {
			var _psyID = FindPsyID(_spell, 0)
			var _cost  = global.psynergylist[_psyID].cost
			_line3 = global.players[_caster].name + ": Cast " + _spell + "? (" + string(_cost) + " PP)"
		}
	}

	var _btns = []
	if !_no_caster {
		array_push(_btns, {
			label:    "Disarm",
			sprite:   yes,
			on_click: method(
				{
					pi:       puzzle_index,
					ci:       challenge_index,
					puz:      _puzzle,
					is_ov:    _is_overload,
					caster:   _caster,
					spell:    _spell,
					ov_elem:  _overload_elem,
				},
				function() {
					var _ch = global.floorChallenges[ci]
					if is_ov {
						global.players[caster].pp -= 8
						InjectLog(global.players[caster].name + " absorbs the " + ov_elem + " overload!")
					} else {
						var _psyID = FindPsyID(spell, 0)
						global.players[caster].pp -= global.psynergylist[_psyID].cost
						InjectLog(global.players[caster].name + " casts " + spell + "!")
					}
					_ch.completed = true
					if puz.trap {
						for (var _i = array_length(global.floorEffects) - 1; _i >= 0; _i--) {
							if global.floorEffects[_i].puzzle_index == pi {
								array_delete(global.floorEffects, _i, 1)
							}
						}
						InjectLog("Trap disarmed!")
					} else {
						ApplyPuzzleReward(puz)
					}
				}
			),
		})
	}
	array_push(_btns, { label: "Skip", sprite: no, on_click: function() {} })

	PushMenu(objMenuPrompt, {
		lines: [
			{ text: _puzzle.name, color: _puzzle.trap ? c_red : c_lime },
			{ text: _puzzle.trap ? _puzzle.disarm_text : _puzzle.reward_text, color: c_white },
			{ text: _line3, color: _no_caster ? c_red : c_yellow },
		],
		buttons: _btns,
	})
}
