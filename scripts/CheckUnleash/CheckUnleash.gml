/// @func CountSixes(player, subset)
/// @desc Count pip values == 6 in dicepool
/// @param {Struct} player   Character struct with .dicepool
/// @param {String} subset   "melee" or "all"
function CountSixes(player, subset) {
	var dpool = player.dicepool
	var count = 0
	for (var p = 0; p < 5; p++) {
		if subset == "melee" and p != POOL_MELEE { continue }
		for (var i = 0; i < array_length(dpool[p]); i++) {
			if dpool[p][i] == 6 { count++ }
		}
	}
	return count
}

/// @func CountFivesAndSixes(player, subset)
/// @desc Count pip values >= 5 in dicepool
/// @param {Struct} player   Character struct with .dicepool
/// @param {String} subset   "melee" or "all"
function CountFivesAndSixes(player, subset) {
	var dpool = player.dicepool
	var count = 0
	for (var p = 0; p < 5; p++) {
		if subset == "melee" and p != POOL_MELEE { continue }
		for (var i = 0; i < array_length(dpool[p]); i++) {
			if dpool[p][i] >= 5 { count++ }
		}
	}
	return count
}

/// @func CheckUnleash(player)
/// @desc Check if the current weapon triggers an unleash effect based on dice state
/// @param {Struct} player   Character struct
/// @returns {Struct} unleash result
function CheckUnleash(player) {
	var result = {
		active: false,
		name: "",
		dam_bonus: 0,
		element: "",
		num: 1,
		statuses: {},
		heal_hp_ratio: 0,
		heal_pp_ratio: 0,
		heal_hp_flat: 0,
		heal_pp_flat: 0,
		splash_ratio: 0,
		splash_element: "normal",
		double_atk: false,
		convert_element: "",
		instant_kill: false
	}

	var weapon = global.itemcardlist[player.weapon]
	var wname = weapon.name
	var sixes_all = CountSixes(player, "all")
	var sixes_melee = CountSixes(player, "melee")
	
	switch player.name{
		case "Flint":
			if sixes_all >= 2{
				result.active = true
				result.name = "Summon Venus"
				result.dam_bonus = ceil((QueryDice(player,"all","charge") + player.atk + player.atkmod) * 0.5)
				return result
			}
			break	
		case "Cannon":
			if sixes_all >= 2{
				result.active = true
				result.name = "Summon Mars"
				result.dam_bonus = ceil((QueryDice(player,"all","charge") + player.atk + player.atkmod) * 0.5)
				return result
		
			}
			break
		case "Waft":
		if sixes_all >= 2{
				result.active = true
				result.name = "Summon Jupiter"
				result.dam_bonus = 3
				result.statuses.inflict_sleep = true
				return result
			}
			break	
		case "Sleet":
		if sixes_all >= 2{
				result.active = true
				result.name = "Summon Mercury"
				result.dam_bonus = 3
				result.statuses.inflict_atkdown = 3
				return result
			}
			break	
	
	}
	
	
	switch wname {

		// ===== AUTO (always active) =====
		case "Arctic Blade":
			result.active = true
			result.name = "Blizzard"
			result.dam_bonus = sixes_all
			result.convert_element = "mercury"
			break

		case "Elven Rapier":
			result.active = true
			result.name = "Vorpal Slash"
			result.dam_bonus = sixes_all
			result.convert_element = "jupiter"
			break

		case "Psynergy Rod":
			result.active = true
			result.name = "Psy Leech"
			result.heal_pp_flat = sixes_all
			break

		case "Angelic Ankh":
			result.active = true
			result.name = "Life Leech"
			result.heal_hp_flat = sixes_all
			break

		case "Staff of Anubis":
			// +X venus dam where X = dead enemy count
			var _dead = 0
			var _mcount = instance_number(objMonster)
			for (var _m = 0; _m < _mcount; _m++) {
				if instance_find(objMonster, _m).monsterHealth <= 0 { _dead++ }
			}
			result.active = true
			result.name = "Sarcophagus"
			result.dam_bonus = _dead
			result.convert_element = "venus"
			break

		case "Kikuichimonji":
			result.active = true
			result.name = "Asura"
			result.double_atk = true
			break

		case "Huge Sword":
			result.active = true
			result.name = "Heavy Divide"
			result.convert_element = "venus"
			break

		case "Crystal Rod":
			result.active = true
			result.name = "Drown"
			result.dam_bonus = sixes_all * 2
			result.convert_element = "mercury"
			if sixes_melee >= 3 {
				result.instant_kill = true
			}
			break

		case "Dracomace":
			result.active = true
			result.name = "Aging Gas"
			result.heal_hp_flat = CountFivesAndSixes(player, "all")
			break

		// ===== DUAL 6s (CountSixes >= 2) =====
		case "Pirate's Sword":
			if sixes_all >= 2 {
				result.active = true
				result.name = "Dreamtide"
				result.statuses = { inflict_sleep: true }
				result.splash_ratio = 0.5
				result.splash_element = "mercury"
			}
			break

		case "Vulcan Axe":
			if sixes_all >= 2 {
				result.active = true
				result.name = "Vulcan Axe"
				result.dam_bonus = 2
				result.convert_element = "mars"
				result.splash_ratio = 0.5
				result.splash_element = "mars"
			}
			break

		case "Grievous Mace":
			if sixes_all >= 2 {
				result.active = true
				result.name = "Grievous Mace"
				result.dam_bonus = 2
				result.convert_element = "venus"
			}
			break

		case "Burning Axe":
			if sixes_all >= 2 {
				result.active = true
				result.name = "Broil"
				result.dam_bonus = QueryDice(player, "all", "uncharge")
				result.convert_element = "mars"
			}
			break

		case "Storm Brand":
			if sixes_all >= 2 {
				result.active = true
				result.name = "Storm Brand"
				result.dam_bonus = 3
				result.convert_element = "mercury"
				result.statuses = { inflict_atkdown: 1 }
			}
			break

		case "Pirate's Sabre":
			if sixes_all >= 2 {
				result.active = true
				result.name = "Scorpionfish"
				result.statuses = { inflict_venom: true }
				result.splash_ratio = 0.5
				result.splash_element = "damage"
			}
			break

		// ===== TRIPLE 6s (CountSixes >= 3) =====
		case "Blessed Mace":
			if sixes_all >= 3 {
				result.active = true
				result.name = "Blessed Mace"
				result.heal_hp_ratio = 1.0
			}
			break

		case "Assassin Blade":
			if sixes_melee >= 3 {
				result.active = true
				result.name = "Assassin Blade"
				result.instant_kill = true
			}
			break

		case "Swift Blade":
			if sixes_melee >= 3 {
				result.active = true
				result.name = "Swift Blade"
				result.dam_bonus = 0  // handled specially: dam *= 3
				result.convert_element = "jupiter"
			}
			break

		case "Gaia Blade":
			if sixes_all >= 3 {
				result.active = true
				result.name = "Gaia Blade"
				result.convert_element = "venus"
				result.num = 3
			}
			break

		case "Soul Brand":
			if sixes_all >= 3 {
				result.active = true
				result.name = "Soul Brand"
				result.heal_pp_ratio = 0.5
			}
			break

		// ===== SOLO 6 (CountSixes == 1) =====
		case "Bandit's Sword":
			if sixes_all == 1 {
				result.active = true
				result.name = "Bandit's Sword"
				result.convert_element = "jupiter"
				result.num = 12
			}
			break

		case "Witch's Wand":
			if sixes_all == 1 {
				result.active = true
				result.name = "Witch's Wand"
				result.convert_element = "jupiter"
				result.statuses = { inflict_stun: true }
			}
			break

		case "Rune Blade":
			if sixes_melee == 1 {
				result.active = true
				result.name = "Rune Blade"
				result.statuses = { inflict_psyseal: true }
			}
			break

		// ===== SPECIAL TRIGGERS =====
		case "Ninja Blade":
			if QueryDice(player, "all", "charged_values") >= 10 {
				result.active = true
				result.name = "Ninja Blade"
				result.statuses = { inflict_defdown: 3 }
			}
			break

		case "Cloud Wand":
			// All melee dice >= 5
			var _melee_pool = player.dicepool[POOL_MELEE]
			var _all_high = (array_length(_melee_pool) > 0)
			for (var _i = 0; _i < array_length(_melee_pool); _i++) {
				if _melee_pool[_i] < 5 { _all_high = false; break }
			}
			if _all_high {
				result.active = true
				result.name = "Cloud Wand"
				result.statuses = { inflict_stun: true }
				result.splash_ratio = 0
				result.splash_element = "stun"
			}
			break

		// Zodiac Wand: (Psy) unleash — handled in CastSpell, not here

		case "Hagbone Mace":
			// Charged melee >= half of max melee dice
			var _melee_count = array_length(player.dicepool[POOL_MELEE])
			var _charged_melee = 0
			var _cmap = GetChargedDice(player).charged_map
			for (var _i = 0; _i < array_length(_cmap[POOL_MELEE]); _i++) {
				if _cmap[POOL_MELEE][_i] { _charged_melee++ }
			}
			if _melee_count > 0 and _charged_melee >= ceil(_melee_count / 2) {
				result.active = true
				result.name = "Wyrd Curse"
				result.statuses = { inflict_poison: true }
			}
			break

		default:
			// No unleash for this weapon
			break
	}

	return result
}
