
#macro POOL_MELEE   0
#macro POOL_VENUS   1
#macro POOL_MARS    2
#macro POOL_JUPITER 3
#macro POOL_MERCURY 4

/// @func QueryDice(player, subset, mode)
/// @desc Canonical dice evaluation. Returns a single number.
/// @param {Struct} player   Character struct with .dicepool and .weapon
/// @param {String} subset   "all" | "elemental" | "melee" | "venus" | "mars" | "jupiter" | "mercury"
/// @param {String} mode     "affinity" | "charge" | "uncharge" | "values" | "highest" | "lowest" | "top2" | "charged_values"
function QueryDice(player, subset, mode) {
	var dpool = variable_clone(player.dicepool)
	
	
	if mode != "charge" and mode != "uncharge"{
		var pipbonus = 0
		var vbonus = player.vbonus
		var mabonus = player.mabonus
		var jbonus = player.jbonus
		var mebonus = player.mebonus
		var meleebonus = player.meleebonus

		if array_contains(player.armor, FindItemID("Guardian Ring")){ pipbonus += 1 }
		if array_contains(player.armor, FindItemID("Fairy Ring")){ pipbonus -= 1 }
		
		for (var i = 0; i < array_length(dpool[POOL_VENUS]); ++i) {
		    dpool[POOL_VENUS][i] = dpool[POOL_VENUS][i] == 0 ? 0 : max(min(dpool[POOL_VENUS][i] + pipbonus, 6), 1) + vbonus
		}
		for (var i = 0; i < array_length(dpool[POOL_JUPITER]); ++i) {
		    dpool[POOL_JUPITER][i] = dpool[POOL_JUPITER][i] == 0 ? 0 : max(min(dpool[POOL_JUPITER][i] + pipbonus, 6), 1) + jbonus
		}
		for (var i = 0; i < array_length(dpool[POOL_MARS]); ++i) {
		    dpool[POOL_MARS][i] = dpool[POOL_MARS][i] == 0 ? 0 : max(min(dpool[POOL_MARS][i] + pipbonus, 6), 1) + mabonus
		}
		for (var i = 0; i < array_length(dpool[POOL_MERCURY]); ++i) {
		    dpool[POOL_MERCURY][i] = dpool[POOL_MERCURY][i] == 0 ? 0 : max(min(dpool[POOL_MERCURY][i] + pipbonus, 6), 1) + mebonus
		}
		for (var i = 0; i < array_length(dpool[POOL_MELEE]); ++i) {
		    dpool[POOL_MELEE][i] = dpool[POOL_MELEE][i] == 0 ? 0 : max(min(dpool[POOL_MELEE][i] + pipbonus, 6), 1) + meleebonus
		}
	}
	
	
	
	var include = array_create(5, false)
	
	if player.name == "Jules" and subset != "melee"{include[POOL_JUPITER] = true}
	
	switch subset {
		case "all":
			for (var _i = 0; _i < 5; _i++) { include[_i] = true }
			break
		case "elemental":
			include[POOL_VENUS]   = true
			include[POOL_MARS]    = true
			include[POOL_JUPITER] = true
			include[POOL_MERCURY] = true
			break
		case "melee":   include[POOL_MELEE]   = true; break
		case "venus":   include[POOL_VENUS]   = true; break
		case "mars":    include[POOL_MARS]    = true; break
		case "jupiter": include[POOL_JUPITER] = true; break
		case "mercury": include[POOL_MERCURY] = true; break
	}

	// Fetch charged map only when a charge-dependent mode is requested
	var charged_map = undefined
	if mode == "charge" or mode == "uncharge" or mode == "charged_values" {
		charged_map = GetChargedDice(player).charged_map
	}

	var result  = 0
	var highest = 0
	var second  = 0
	var lowest  = 7   // sentinel — above max pip value

	switch mode {

		case "affinity":
			for (var p = 0; p < 5; p++) {
				if !include[p] { continue }
				result += array_length(dpool[p])
			}
			break

		case "charge":
			for (var p = 0; p < 5; p++) {
				if !include[p] { continue }
				var cpool = charged_map[p]
				for (var i = 0; i < array_length(cpool); i++) {
					if cpool[i] { result++ }
				}
			}
			break

		case "uncharge":
			for (var p = 0; p < 5; p++) {
				if !include[p] { continue }
				var cpool = charged_map[p]
				for (var i = 0; i < array_length(cpool); i++) {
					if !cpool[i] { result++ }
				}
			}
			break

		case "values":
			for (var p = 0; p < 5; p++) {
				if !include[p] { continue }
				var vpool = dpool[p]
				for (var i = 0; i < array_length(vpool); i++) {
					result += vpool[i]
				}
			}
			break

		case "highest":
			for (var p = 0; p < 5; p++) {
				if !include[p] { continue }
				var vpool = dpool[p]
				for (var i = 0; i < array_length(vpool); i++) {
					if vpool[i] > highest { highest = vpool[i] }
				}
			}
			result = highest
			break

		case "lowest":
			for (var p = 0; p < 5; p++) {
				if !include[p] { continue }
				var vpool = dpool[p]
				for (var i = 0; i < array_length(vpool); i++) {
					if vpool[i] < lowest and vpool[i] != 0 { lowest = vpool[i] }
				}
			}
			result = (lowest == 7) ? 0 : lowest
			break

		case "top2":
			for (var p = 0; p < 5; p++) {
				if !include[p] { continue }
				var vpool = dpool[p]
				for (var i = 0; i < array_length(vpool); i++) {
					var v = vpool[i]
					if v > highest {
						second  = highest
						highest = v
					} else if v > second {
						second = v
					}
				}
			}
			result = highest + second
			break

		case "charged_values":
			for (var p = 0; p < 5; p++) {
				if !include[p] { continue }
				var vpool = dpool[p]
				var cpool = charged_map[p]
				for (var i = 0; i < array_length(vpool); i++) {
					if cpool[i] { result += vpool[i] }
				}
			}
			break

	}

	return result
}

function GetChargedDice(player){
	var dpool       = variable_clone(player.dicepool)
	var weapon_type = global.itemcardlist[player.weapon].type

	// Apply Guardian/Fairy Ring pip bonus so charges evaluate on modified pips
	var pipbonus = 0
	if array_contains(player.armor, FindItemID("Guardian Ring")){ pipbonus += 1 }
	if array_contains(player.armor, FindItemID("Fairy Ring")){ pipbonus -= 1 }
	if (pipbonus != 0) {
		for (var p = 0; p < array_length(dpool); p++) {
			for (var i = 0; i < array_length(dpool[p]); i++) {
				dpool[p][i] = clamp(dpool[p][i] + pipbonus, 1, 6)
			}
		}
	}

	var charged_map   = []  // [pool_index][die_index] = bool
	var charged_count = 0

	// --- AXE: pairs across the whole flat pool ---
	if weapon_type == "Axe" {

		// Count occurrences of each pip value across all pools
		var pip_counts = array_create(7, 0)   // index 1-6
		for (var p = 0; p < array_length(dpool); p++) {
			var pool = dpool[p]
			for (var i = 0; i < array_length(pool); i++) {
				pip_counts[pool[i]]++
			}
		}

		// A pip value is "paired" if it appears >= 2 times
		// Each die of a paired value contributes exactly 1 charged die
		// (so if you roll three 5s that's still just 3 charged dice, all three count)
		for (var p = 0; p < array_length(dpool); p++) {
			var pool     = dpool[p]
			var pool_row = array_create(array_length(pool), false)
			for (var i = 0; i < array_length(pool); i++) {
				var is_charged = (pip_counts[pool[i]] >= 2 or pool[i] == 0)
				pool_row[i]    = is_charged
				if is_charged { charged_count++ }
			}
			array_push(charged_map, pool_row)
		}

	} else {

		// All other weapon types evaluate each die independently
		for (var p = 0; p < array_length(dpool); p++) {
			var pool     = dpool[p]
			var pool_row = array_create(array_length(pool), false)
			for (var i = 0; i < array_length(pool); i++) {
				var pip        = pool[i]
				var is_charged = false

				switch weapon_type {
					case "Short Sword": is_charged = (pip >= 4 or pip == 0); break
					case "Long Sword":  is_charged = (pip mod 2 == 0 or pip == 0); break
					case "Staff":       is_charged = (pip >= 3 or pip == 0); break
					case "Mace":        is_charged = (pip >= 5 or pip == 0); break
					default:            is_charged = (pip >= 4 or pip == 0); break  // fallback
				}

				pool_row[i] = is_charged
				if is_charged { charged_count++ }
			}
			array_push(charged_map, pool_row)
		}
	}

	return {
		charged_map:   charged_map,
		charged_count: charged_count
	}
}

