/// @function _BuildArtifactList()
/// @desc Called at the start of each dungeon (dungeon > 0). Adds weapons + armor from the
///       previous chapter's recipe CSV to global.artifactlist, then applies one upgrade pass
///       to every weapon already in the list.
function _BuildArtifactList() {
	if (global.dungeon == 0) { exit }

	// --- 1. Add new artifacts from previous chapter's recipe ---
	var _prev_dun = global.dungeonlist[global.dungeon - 1]
	var _recipe_file = string_replace_all(_prev_dun.name, " ", "_") + "_Recipe.csv"
	var _rf = load_csv(_recipe_file)
	if (_rf < 0) { exit }

	// Build a set of names already in artifactlist to avoid duplicates
	var _existing_names = {}
	for (var _k = 0; _k < array_length(global.artifactlist); _k++) {
		_existing_names[$ global.artifactlist[_k].name] = true
	}

	for (var i = 0; i < ds_grid_height(_rf); i++) {
		var _name = string(_rf[# 0, i])
		if (variable_struct_exists(_existing_names, _name)) { continue }

		var _base_id = FindItemID(_name)
		if (_base_id < 0) { continue }
		var _base = global.itemcardlist[_base_id]

		// Only weapons and armor (skip Healing / Battle / Money / Special items)
		if (_base.type == "Healing" || _base.type == "Battle" || _base.type == "Money" || _base.type == "Special") { continue }

		var _mod = variable_clone(_base)
		_mod.artifact = true
		_mod.artifact_bonus_text = ""

		// Weapons get elemental upgrade options; armor does not
		if (variable_struct_exists(_base, "melee")) {
			var _ele_opts = ["elemental"]
			if (_base.venus   > 0) { array_push(_ele_opts, "venus")   }
			if (_base.mars    > 0) { array_push(_ele_opts, "mars")    }
			if (_base.jupiter > 0) { array_push(_ele_opts, "jupiter") }
			if (_base.mercury > 0) { array_push(_ele_opts, "mercury") }
			_mod.artifact_ele_options = _ele_opts
		}

		array_push(global.itemcardlist, _mod)
		_mod.itemcard_id = array_length(global.itemcardlist) - 1
		array_push(global.artifactlist, _mod)
	}
	ds_grid_destroy(_rf)

	// --- 2. Upgrade pass: one upgrade on every weapon in artifactlist ---
	var _enames = { elemental: "Elemental", venus: "Venus", mars: "Mars", jupiter: "Jupiter", mercury: "Mercury" }

	for (var i = 0; i < array_length(global.artifactlist); i++) {
		var _art = global.artifactlist[i]
		if (!variable_struct_exists(_art, "artifact_ele_options")) { continue } // armor: skip

		var _bonus = ""
		if (irandom(1) == 0) {
			// Melee upgrade
			var _m = irandom_range(1, 2)
			_art.melee += _m
			_bonus = "+" + string(_m) + " Melee"
		} else {
			// Elemental upgrade
			var _opts = _art.artifact_ele_options
			var _pick = _opts[irandom(array_length(_opts) - 1)]
			_art[$ _pick] += 1
			_bonus = "+1 " + _enames[$ _pick]
		}

		if (_art.artifact_bonus_text == "") {
			_art.artifact_bonus_text = _bonus
			_art.name += "+"
		} else {
			_art.artifact_bonus_text += ", " + _bonus
			_art.name += "+"
		}
	}
}
