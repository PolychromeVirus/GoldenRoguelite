/// @function CalcPreview(action_type, action_id, player)
/// @desc Returns a preview struct { dam, element, heal, targets, description }
///       Read-only: no PP deduction, no state changes.
function CalcPreview(action_type, action_id, player) {
	var result = { dam: 0, element: "damage", heal: 0, targets: "Enemy", description: "" }

	switch action_type {

		// ── ATTACK ──────────────────────────────────────────────────────
		case "attack":
			result.dam = WeaponAttack(true,false).dam
			result.element = "damage"
			result.targets = "Enemy"
			result.description = string(result.dam)
			break

		// ── SPELL ───────────────────────────────────────────────────────
		case "spell":
			var spell = global.psynergylist[action_id]
			result.element = spell.element
			result.targets = (spell.targetType == "Ally") ? "Ally" : "Enemy"

			var weapon_type = global.itemcardlist[player.weapon].type
			var weapon_subset = (weapon_type == "Staff") ? "melee" : "all"
			var weapon_atk = WeaponAttack(false,false).dam

			switch spell.base {
				// Tier 1: flat damage
				case "Bolt": case "Douse": case "Flare": case "Ray":
					result.dam = real(spell.damage)
					break

				case "Astral Blast":
					if spell.stage == 1 { result.dam = weapon_atk + QueryDice(player, "jupiter", "charge") }
					else { result.dam = QueryDice(player, "jupiter", "values") }
					break
				case "Beam":
					if spell.stage == 1 { result.dam = QueryDice(player, "mars", "uncharge") + QueryDice(player, "mars", "charge") * 2 }
					else { result.dam = QueryDice(player, "mars", "charge") * 3 }
					break
				case "Blast":
					var _bnum = 0
					if player.venus > 0   { _bnum++ }
					if player.mars > 0    { _bnum++ }
					if player.jupiter > 0 { _bnum++ }
					if player.mercury > 0 { _bnum++ }
					result.dam = QueryDice(player, "all", "charge")
					if spell.stage == 2 { result.dam += _bnum * 2 }
					if spell.stage == 3 {
						if player.venus > 0   { result.dam += QueryDice(player, "venus", "highest") }
						if player.mars > 0    { result.dam += QueryDice(player, "mars", "highest") }
						if player.jupiter > 0 { result.dam += QueryDice(player, "jupiter", "highest") }
						if player.mercury > 0 { result.dam += QueryDice(player, "mercury", "highest") }
					}
					break
				case "Cool":
					if spell.stage == 1 { result.dam = 2 }
					else if spell.stage == 2 { result.dam = QueryDice(player, "mercury", "charge") }
					else { result.dam = QueryDice(player, "all", "charge") }
					break
				case "Diamond Dust":
					result.dam = weapon_atk
					if spell.stage == 2 { result.dam *= 2 }
					break
				case "Frost":
					if spell.stage == 1 { result.dam = QueryDice(player, "melee", "charge") }
					else if spell.stage == 2 { result.dam = QueryDice(player, "mercury", "charge") * 2 + QueryDice(player, "melee", "charge") }
					else { result.dam = QueryDice(player, "melee", "charge") + QueryDice(player, "mercury", "charge") * 2 }
					break
				case "Froth":
					if spell.stage < 3 {
						result.dam = QueryDice(player, "mercury", "charge")
					} else {
						result.dam = QueryDice(player, "mercury", "charge") * 2
					}
					break
				case "Fume":
					if spell.stage == 1 { result.dam = real(spell.damage) }
					else if spell.stage == 2 { result.dam = QueryDice(player, "mars", "values") }
					else { result.dam = QueryDice(player, "mars", "values") * 2 }
					break
				case "Gaia":
					result.dam = QueryDice(player, "venus", "affinity")
					if spell.stage == 2 { result.dam *= 2 }
					if spell.stage == 3 { result.dam *= power(2, QueryDice(player, "jupiter", "charge")) }
					break
				case "Ice":
					if spell.stage == 1 { result.dam = QueryDice(player, "all", "charge") }
					else if spell.stage == 2 { result.dam = QueryDice(player, "mercury", "charge") * 2 }
					else { result.dam = QueryDice(player, "all", "charge") * 2 }
					break
				case "Prism":
					if spell.stage < 3 {
						result.dam = QueryDice(player, "mercury", "highest")
					} else {
						result.dam = QueryDice(player, "mercury", "highest") * 2
					}
					break
				case "Quake":
					if spell.stage == 1 { result.dam = real(spell.damage) }
					else if spell.stage == 2 { result.dam = 3 + QueryDice(player, "venus", "affinity") }
					else { result.dam = QueryDice(player, "venus", "affinity") * 2 }
					break
				case "Ragnarok":
					result.dam = QueryDice(player, "venus", "values")
					if spell.stage == 2 { result.dam *= 2 }
					break
				case "Slash":
					result.dam = weapon_atk
					if spell.stage == 3 { result.dam *= 2 }
					break
				case "Spire":
					if spell.stage == 1 { result.dam = QueryDice(player, "all", "charge") }
					else if spell.stage == 2 { result.dam = QueryDice(player, "venus", "charge") * 2 }
					else { result.dam = QueryDice(player, "all", "charge") * 2 }
					break
				case "Thorn":
					if spell.stage == 1 { result.dam = 2 }
					else if spell.stage == 2 { result.dam = QueryDice(player, "venus", "charge") }
					else { result.dam = QueryDice(player, "all", "charge") }
					break
				case "Volcano":
					var base_flat = 4
					if spell.stage == 2 { base_flat = 6 }
					else if spell.stage == 3 { base_flat = 10 }
					result.dam = base_flat + QueryDice(player, "mars", "affinity")
					break
				case "Whirlwind":
					result.dam = QueryDice(player, "jupiter", "charge") * 2
					if spell.stage == 3 { result.dam += QueryDice(player, "all", "charge") - QueryDice(player, "jupiter", "charge") }
					break

				// Offensive utility spells
				case "Plasma":
					if spell.stage >= 3 {
						result.dam = QueryDice(player, "jupiter", "highest")
						result.description = string(result.dam) + "x" + string(QueryDice(player, "jupiter", "charge"))
					} else {
						result.description = "Assign " + string((spell.stage == 2) ? 5 : 3) + " dice"
					}
					return result
				case "Backstab":
					result.dam = weapon_atk + 2
					break
				case "Planet Diver":
					if spell.stage == 1{
						if player.venus > 0 and player.mars > 0{
							result.dam += QueryDice(player,"venus","highest")
							result.dam += QueryDice(player,"mars","highest")
							result.dam *= 2
					
						}else{
							result.dam = QueryDice(player, "elemental", "top2")
						}
					}else{
					
						result.dam = QueryDice(player,"all","values")
					
					}
				
					
					break

				// Status-only offensive
				case "Dull":
					result.dam = 0
					result.description = "ATK -3"
					return result
				case "Delude":
					result.dam = 0
					result.description = "Delude"
					return result
				case "Sleep":
					result.dam = 0
					result.description = "Sleep"
					return result
				case "Break":
					result.dam = 0
					result.description = "Clear Stats"
					return result

				// Ally buff/utility
				case "Aegis":
					result.heal = 0
					result.targets = "Ally"
					var _aegis = QueryDice(player, "venus", "charge")
					if (spell.stage >= 2 && _aegis == QueryDice(player, "venus", "affinity")) { result.description = "DEF +" + string(_aegis) }
					else { result.description = "DEF +" + string(_aegis) + " / ATK -" + string(_aegis) }
					return result
				case "Ward":
					result.targets = "Ally"
					result.description = "DEF +3"
					return result
				case "Impact":
					result.targets = "Ally"
					result.description = "ATK +3"
					return result
				case "Root":
					var _rt = (spell.stage == 1) ? 3 : 6
					result.targets = "Ally"
					result.description = string(_rt) + " Root"
					return result
				case "Revive":
					result.heal = QueryDice(player, "venus", "affinity") * 2
					result.targets = "Ally"
					result.description = "Revive"
					return result
				case "Burn Off":
					result.targets = (spell.stage >= 2) ? "All Allies" : "Ally"
					result.description = "Clear Buffs"
					return result
				case "Restore":
					result.targets = (spell.stage >= 2) ? "All Allies" : "Ally"
					result.description = "Cure Status"
					return result
				case "Resonate":
					result.targets = "Self"
					result.description = "Buff Spells"
					return result
				case "Cloak":
					result.targets = "Ally"
					result.description = "Cloak"
					return result
				case "Djinn Echo":
					result.targets = "Self"
					result.description = (spell.stage >= 2) ? "Djinn x3 + Unleash" : "Djinn x3"
					return result

				// Healing spells
				case "Aura":
					result.heal = QueryDice(player, "mars", "lowest")
					if spell.stage >= 2 { result.heal += QueryDice(player, "mars", "highest") }
					if spell.stage == 3 { result.heal *= 2 }
					result.targets = "All Allies"
					break
				case "Cure":
					if spell.stage == 1 { result.heal = QueryDice(player, "venus", "highest") }
					else if spell.stage == 2 { result.heal = QueryDice(player, "venus", "top2") }
					else { result.heal = QueryDice(player, "venus", "top2") * 2 }
					result.targets = "Ally"
					break
				case "Ply":
					if spell.stage == 1 { result.heal = QueryDice(player, "mercury", "highest") }
					else if spell.stage == 2 { result.heal = QueryDice(player, "mercury", "affinity") }
					else { result.heal = 9999 }
					result.targets = "Ally"
					break
				case "Wish":
					if spell.stage == 1 { result.heal = QueryDice(player, "mercury", "highest") }
					else if spell.stage == 2 { result.heal = QueryDice(player, "mercury", "highest") + QueryDice(player, "mercury", "affinity") }
					else { result.heal = QueryDice(player, "all", "charge") * 2 + QueryDice(player, "mercury", "affinity") }
					result.targets = "All Allies"
					break
					break
				case "Psy Drain":
					result.heal = QueryDice(player, "all", "charge")
					result.description = string(result.heal) + " PP"
					return result

				default:
					result.description = "?"
					return result
			}

			// Build description string (if not already set above)
			if result.description == "" {
				if result.heal > 0 {
					result.description = string(result.heal) + " HP"
				} else if result.dam > 0 {
					result.description = string(result.dam)
				} else {
					result.description = "?"
				}
			}
			break

		// ── ITEM ────────────────────────────────────────────────────────
		case "item":
			var itemdata = global.itemcardlist[action_id]
			switch itemdata.name {
				case "Herb":       result.heal = 3; result.targets = "Ally"; break
				case "Nut":        result.heal = 6; result.targets = "Ally"; break
				case "Vial":       result.heal = 10; result.targets = "Ally"; break
				case "Potion":     result.heal = 20; result.targets = "Ally"; break
				case "Psy Crystal": result.heal = 3; result.targets = "Ally"; result.description = "+3 PP"; return result
				case "Water of Life": result.heal = player.hpmax; result.targets = "Ally"; result.description = "Revive"; return result
				case "Mist Potion": result.heal = 99; result.targets = "All Allies"; result.description = "Full Heal All"; return result
				case "Oil Drop":
					result.dam = QueryDice(player, "elemental", "charge") + 1
					result.element = "Mars"; result.targets = "All Enemies"; break
				case "Bramble Seed":
					result.dam = QueryDice(player, "elemental", "charge") + 1
					result.element = "Venus"; result.targets = "All Enemies"; break
				case "Crystal Powder":
					result.dam = QueryDice(player, "elemental", "charge") + 1
					result.element = "Mercury"; result.targets = "All Enemies"; break
				case "Weasel's Claw":
					result.dam = QueryDice(player, "elemental", "charge") + 1
					result.element = "Jupiter"; result.targets = "All Enemies"; break
				case "Smoke Bomb":
					result.description = "Delude"
					result.targets = "Enemy"
					return result
				case "Sleep Bomb":
					result.description = "Sleep"
					result.targets = "Enemy"
					return result
				default:
					result.description = ""
					return result
			}

			if result.heal > 0 {
				result.description = string(result.heal) + " HP"
			} else if result.dam > 0 {
				result.description = string(result.dam)
			}
			break

		// ── DJINNI ──────────────────────────────────────────────────────
		case "djinni":
			var djinn = global.djinnlist[action_id]
			result.element = djinn.element
			var weapon_atk = WeaponAttack(false,false).dam

			// Spent djinn just get set to ready
			if djinn.spent {
				result.description = "Set Ready"
				return result
			}

			switch djinn.name {
				// Charged-dice damage (1 target)
				case "Bane": case "Fever": case "Wheeze": case "Mist":
				case "Char": case "Smog": case "Blitz": case "Squall":
				case "Hail": case "Sleet": case "Chill": case "Shine":
					result.dam = QueryDice(player, "all", "charge")
					break

				// Weapon attack + bonus (1 target)
				case "Flint": case "Cannon": case "Sour":
					result.dam = WeaponAttack(false,false).dam
					result.dam += ceil(result.dam / 2)
					break
				case "Sap":
					result.dam = WeaponAttack(true,false).dam
					break
				case "Geode":
					result.dam = WeaponAttack(true,false).dam + WeaponAttack(false,false).dam
					break
				case "Torch":
					result.dam = weapon_atk
					break
				case "Scorch":
					result.dam = weapon_atk
					break

				// Heal all
				case "Spritz":
					result.heal = QueryDice(player, "elemental", "charge")
					result.targets = "All Allies"
					break
				case "Balm":
					result.heal = floor(player.hpmax / 2)
					result.targets = "All Allies"
					break
				case "Crystal":
					result.heal = QueryDice(player, "elemental", "charge") + player.def + player.defmod
					result.targets = "All Allies"
					break

				// Heal one
				case "Spring": case "Breath":
					result.heal = QueryDice(player, "all", "charge")
					result.targets = "Ally"
					break
				case "Fizz":
					result.heal = floor(player.hpmax / 2)
					result.targets = "Ally"
					break

				// PP recovery
				case "Ember":
					result.description = string(QueryDice(player, "mars", "charge")) + " PP All"
					result.targets = "All Allies"
					return result
				case "Aroma":
					result.description = string(QueryDice(player, "elemental", "charge")) + " PP All"
					result.targets = "All Allies"
					return result
				case "Ether":
					result.description = string(QueryDice(player, "all", "charge")) + " PP"
					result.targets = "Ally"
					return result

				// Stat buffs (all)
				case "Forge":
					result.description = "ATK +2 All"
					result.targets = "All Allies"
					return result
				case "Iron":
					result.description = "DEF +2 All"
					result.targets = "All Allies"
					return result
				case "Corona": case "Breeze":
					result.description = "DEF +2 All"
					result.targets = "All Allies"
					return result

				// Status infliction
				case "Luff": case "Rime":
					result.description = "Psy Seal"
					return result
				case "Fog":
					result.description = "Delude"
					return result
				case "Waft":
					result.description = "Sleep x3"
					return result
				case "Fury":
					result.dam = QueryDice(player, "all", "charge")
					break
				case "Gasp":
					result.description = "Haunt All"
					return result

				// Weapon-based djinn
				case "Gel":
					result.dam = WeaponAttack(true,false).dam + WeaponAttack(true,false).unleash.dam_bonus
					break
				case "Serac": case "Whorl":
					result.dam = WeaponAttack(false,false).dam
					break
				case "Echo":
					result.dam = WeaponAttack(false,false).dam + (WeaponAttack(true,false).unleash.dam_bonus * 2)
					break
				case "Core":
					result.dam = WeaponAttack(true,false).dam
					break

				// Revive/heal targeting
				case "Quartz":
					result.heal = floor(player.hpmax / 2)
					result.targets = "Ally"
					result.description = "Revive"
					return result
				case "Dew":
					result.heal = 9999
					result.targets = "Ally"
					result.description = "Revive"
					return result
				case "Spark":
					result.targets = "Ally"
					result.description = "Revive 50%"
					return result
				case "Tinder":
					result.heal = QueryDice(player, "mars", "affinity")
					result.targets = "Ally"
					result.description = "Revive (delayed)"
					return result

				// Tonic
				case "Tonic":
					result.targets = "All Allies"
					result.description = "Cure Status"
					return result

				// Steel
				case "Steel":
					var _sb = WeaponAttack(true,false).unleash.dam_bonus
					result.description = "+" + string(_sb) + " HP on hit"
					return result

				// Passives / utility
				case "Shade": case "Granite":
					result.description = "Halve DMG"
					result.targets = "All Allies"
					return result
				case "Flash":
					result.description = "Cap DMG 1"
					result.targets = "All Allies"
					return result
				case "Ground":
					result.description = "Skip Enemies"
					result.targets = "All Allies"
					return result
				case "Salt":
					result.description = "Cleanse All"
					result.targets = "All Allies"
					return result
				case "Mud":
					result.description = "Restrict"
					return result
				case "Vine":
					result.description = "Tangle"
					return result
				case "Steam":
					result.description = "Element Buff"
					return result
				case "Kindle":
					result.description = "Melee Buff"
					return result
				case "Reflux":
					result.description = "Counter"
					result.targets = "Self"
					return result
				case "Coal":
					result.description = "Reroll (pick)"
					result.targets = "All Allies"
					return result
				case "Zephyr":
					result.description = "Reroll (full)"
					result.targets = "All Allies"
					return result
				case "Lull":
					result.description = "Ceasefire"
					return result
				case "Haze":
					result.targets = "Ally"
					result.description = "Cloak"
					return result
				case "Flower":
					result.description = "Assign Venus"
					result.targets = "Ally"
					return result
				case "Petra":
					result.description = "Pick Target"
					return result
				case "Gust":
					result.dam = WeaponAttack(true,false).dam
					break
				case "Gale":
					result.description = "50% KO"
					return result
				case "Fugue":
					result.dam = QueryDice(player, "all", "charge")
					break

				default:
					result.description = "?"
					return result
			}

			// Build description
			if result.heal > 0 {
				result.description = string(result.heal) + " HP"
			} else if result.dam > 0 {
				result.description = string(result.dam)
			} else {
				result.description = "?"
			}
			break

		default:
			result.description = "?"
			break
	}

	return result
}

