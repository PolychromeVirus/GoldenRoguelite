/// @desc Receives struct: { puzzle_index, challenge_index }
var _puzzle = global.puzzlelist[puzzle_index]
puzzle = _puzzle
spell_name = _puzzle.spell_alias
caster = -1
no_caster = false

// Overload puzzles: check for opposing element adept with 8+ PP
if (string_pos("Overload", _puzzle.name) > 0) {
	// Opposing element disarms: Venus→Jupiter, Mars→Mercury, Jupiter→Venus, Mercury→Mars
	var _required_elem = ""
	if (string_pos("Venus", _puzzle.name) > 0) _required_elem = "jupiter"
	else if (string_pos("Mars", _puzzle.name) > 0) _required_elem = "mercury"
	else if (string_pos("Jupiter", _puzzle.name) > 0) _required_elem = "venus"
	else if (string_pos("Mercury", _puzzle.name) > 0) _required_elem = "mars"
	overload_element = _required_elem
	is_overload = true
	for (var _i = 0; _i < array_length(global.players); _i++) {
		var _p = global.players[_i]
		if (_p.hp <= 0) continue
		if (string_lower(_p.element) == _required_elem && _p.pp >= 8) {
			caster = _i
			break
		}
	}
	if (caster < 0) no_caster = true
} else if (_puzzle.spell_alias == "") {
	// No spell can disarm (e.g. Falling Rocks)
	is_overload = false
	overload_element = ""
	no_caster = true
} else {
	is_overload = false
	overload_element = ""
	caster = FindSpellCaster(spell_name)
	if (caster < 0) no_caster = true
}

global.pause = true
DeleteButtons()

if (!no_caster) {
	var _confirmSprite = { image: yes, text: "Disarm" }
	instance_create_depth(BUTTON3, BOTTOMROW, 0, objConfirm, _confirmSprite)
}
instance_create_depth(BUTTON5, BOTTOMROW, 0, objCancel)