/// @function BuildVerboseDesc(action_type, action_id, player)
/// @desc Returns a verbose English description for the right-pane detail view.
function BuildVerboseDesc(action_type, action_id, player = undefined) {
	var _prev = CalcPreview(action_type, action_id, player)
	if player == undefined{

		player = variable_clone(global.characterlist[0])

		player.name = "Caster"

	}
	switch action_type {
		case "spell":  return _BVD_Spell(action_id, player, _prev)
		case "djinni":
			var _djinn_result = _BVD_Djinn(action_id, player, _prev)
			var _dj = global.djinnlist[action_id]
			var _dj_prefix = ""
			if (!_dj.ready && _dj.spent)       { _dj_prefix = "(Standby)\n" }
			else if (!_dj.ready && !_dj.spent) { _dj_prefix = "(In Recovery)\n" }
			return _dj_prefix + _djinn_result
		case "item":   return _BVD_Item(action_id, player, _prev)
		case "summon": return _BVD_Summon(action_id, player, _prev)
	}
	return _prev.description
}

// ─── Spell ───────────────────────────────────────────────────────────────────
// Format for damage: "[Range X] Element Damage // Component1 + Component2"
// Format for heals:  "[Range X] Recover <amount> HP"
// Format for utility: natural language
// _ic ternary: combat = " (computed number)", out of combat = ""
// Weapon Attack Damage = WeaponAttack(false,false) — no unleash
// Weapon Attack        = WeaponAttack(true,false)  — with unleash

function _BVD_Spell(action_id, player, prev) {
	var _spell = global.psynergylist[action_id]
	var _elem  = _spell.element
	var _ic    = global.inCombat
	var _dam   = 0
	var _range = real(_spell.range)
	var _res   = CheckPassive("_Resonate")
	if _res != undefined and _res.data.mode == "Range"  { _range += _res.data.amount }
	if _res != undefined and _res.data.mode == "Damage" { _dam   += _res.data.amount }

	var _tgt  = _BVD_TargetStr(_spell.targetType, prev.targets, _range)
	var _pre  = "[" + _tgt + "]\n"
	var _suff = _range > 1 ? "ies" : "y"

	switch _spell.base {

		case "Astral Blast":
			var _a = _ic ? " (" + string(WeaponAttack(false,false).dam)+ ")"      : ""
			var _b = _ic ? " (" + string(QueryDice(player,"jupiter","charge")) + ")" : ""
			return string_ext("{0}Jupiter Damage: Weapon Attack Damage{1} + Jupiter Charge{2}", [_pre, _a, _b])

		case "Backstab":
			var _a = _ic ? " (" + string(WeaponAttack(false,false).dam) + ")" : ""
			return string_ext("{0}Jupiter Damage: Weapon Attack{1} + 2\n10% chance to down.", [_pre, _a])

		case "Beam":
			if _spell.stage == 1 {
				var _a = _ic ? " (" + string(QueryDice(player,"mars","uncharge")) + ")"   : ""
				var _b = _ic ? " (" + string(QueryDice(player,"mars","charge") * 2) + ")" : ""
				return string_ext("{0}Mars Damage: Uncharged Mars{1} + 2x Mars Charge{2}", [_pre, _a, _b])
			}
			var _a = _ic ? " (" + string(QueryDice(player,"mars","charge") * 3) + ")" : ""
			return string_ext("{0}Mars Damage: 3x Mars Charge{1}", [_pre, _a])

		case "Blast":
			var _bnum = 0
			if player.venus   > 0 { _bnum++ }
			if player.mars    > 0 { _bnum++ }
			if player.jupiter > 0 { _bnum++ }
			if player.mercury > 0 { _bnum++ }
			var _bpre  = _ic ? "[Range " + string(_bnum) + "] " : "[Range X] "
			var _xsuff = _ic ? "" : "\n(X = # of unique elements)"
			if _spell.stage == 1 {
				var _a = _ic ? " (" + string(QueryDice(player,"all","charge")) + ")": ""
				return string_ext("{0}Mars Damage: All Charge{1}{2}", [_bpre, _a, _xsuff])
			}
			if _spell.stage == 2 {
				var _a = _ic ? " (" + string(QueryDice(player,"all","charge")) + ")" : ""
				var _b = _ic ? " (" + string(_bnum * 2) + ")"               : ""
				return string_ext("{0}Mars Damage: All Charge{1} + 2x X{2}{3}", [_bpre, _a, _b, _xsuff])
			}
			var _a = _ic ? " (" + string(QueryDice(player,"venus","highest")) + ")"   : ""
			var _b = _ic ? " (" + string(QueryDice(player,"mars","highest")) + ")"    : ""
			var _c = _ic ? " (" + string(QueryDice(player,"jupiter","highest")) + ")" : ""
			var _d = _ic ? " (" + string(QueryDice(player,"mercury","highest")) + ")" : ""
			return string_ext("[Range 3]\nMars Damage:Highest Venus{0} + Highest Mars{1} + Highest Jupiter{2} + Highest Mercury{3}", [_a, _b, _c, _d])

		case "Bolt":
			var _a = _ic ? string(prev.dam) : string(_spell.damage)
			return string_ext("{0}{1} Jupiter Damage\nInflict Stun", [_pre, _a])

		case "Break":
			return string_ext("{0}Reset ATK and DEF", [_pre])

		case "Burn Off":
			return string_ext("{0}Reset ATK and DEF", [_pre, _suff])

		case "Cloak":
			return string_ext("{0}Immune to damage and effects (1 round)", [_pre, _suff])

		case "Cool":
			if _spell.stage == 1 {
				var _a = _ic ? string(prev.dam) : string(_spell.damage)
				return string_ext("{0}{1} Mercury Damage", [_pre, _a])
			}
			if _spell.stage == 2 {
				var _a = _ic ? " (" + string(QueryDice(player,"mercury","charge")) + ")" : ""
				return string_ext("{0}Mercury Damage: Mercury Charge{1}", [_pre, _a])
			}
			var _a = _ic ? " (" + string(QueryDice(player,"all","charge")) + ")" : ""
			return string_ext("{0}Mercury Damage: All Charge{1}", [_pre, _a])

		case "Cure":
			if _spell.stage == 1 {
				var _a = _ic ? " (" + string(QueryDice(player,"venus","highest")) + ")" : ""
				var _b = player.name
				return string_ext("{0}Recover HP: Highest Venus{1}, {2} recovers the same amount.", [_pre, _a,_b])
			}
			if _spell.stage == 2 {
				var _a = _ic ? " (" + string(QueryDice(player,"venus","top2")) + ")" : ""
				var _b = player.name
				return string_ext("{0}Recover HP: 2 Highest Venus{1}, {2} recovers the same amount.", [_pre, _a,_b])
			}
				var _a = _ic ? " (" + string(QueryDice(player,"venus","top2")*2) + ")" : ""
				var _b = player.name
				return string_ext("{0}Recover HP: 2x 2 Highest Venus{1}, {2} recovers the same amount.", [_pre, _a,_b])

		case "Delude":
			return string_ext("{0}Inflict Delusion", [_pre])

		case "Diamond Dust":
			if _spell.stage == 2 {
				var _a = _ic ? " (" + string(WeaponAttack(false,false).dam * 2) + ")" : ""
				return string_ext("{0}Mercury Damage: 2x Weapon Attack Damage{1}", [_pre, _a])
			}
			var _a = _ic ? " (" + string(WeaponAttack(false,false).dam) + ")" : ""
			return string_ext("{0}Mercury Damage: Weapon Attack Damage{1}\nNeighbours take 50% of amount done", [_pre, _a])

		case "Djinn Echo":
			if _spell.stage >= 2 { return "[Passive]\nDjinn abilities with Range 1 become Range 3 (1 Round). Unleash an ally's Djinni." }
			return "[Passive]\nDjinn abilities with Range 1 become Range 3 (1 Round)"

		case "Douse": case "Flare": case "Ray":
			var _a = _ic ? string(prev.dam) : string(_spell.damage)
			return string_ext("{0}{1} " + _elem + " Damage", [_pre, _a])

		case "Dull":
			return string_ext("{0}Reduce ATK by 3", [_pre])

		case "Frost":
			if _spell.stage == 1 {
				var _a = _ic ? " (" + string(QueryDice(player,"melee","charge"))       + ")" : ""
				return string_ext("{0}Mercury Damage: Melee Charge{1}", [_pre, _a])
			}
			var _a = _ic ? " (" + string(QueryDice(player,"melee","charge"))       + ")" : ""
			var _b = _ic ? " (" + string(QueryDice(player,"mercury","charge") * 2) + ")" : ""
			return string_ext("{0}Mercury Damage: Melee Charge{1} + 2x Mercury Charge{2}", [_pre, _a, _b])

		case "Froth":
			var _a = _ic ? " (" + string(QueryDice(player,"mercury","charge")) + ")" : ""
			if _spell.stage < 3 {
				var _b = _ic ? (QueryDice(player,"venus","charge") >= 2 ? "\n-2 DEF" : "") : "\n-2 DEF if Venus Charge >= 2"
				return string_ext("{0}Mercury Damage: Mercury Charge{1}{2}", [_pre, _a, _b])
			}
			var _b = _ic ? " (" + string(QueryDice(player,"venus","charge")) + ")" : ""
			return string_ext("{0}Mercury Damage: Mercury Charge{1}\n-{2} DEF", [_pre, _a, _b])

		case "Fume":
			if _spell.stage == 1 {
				var _a = _ic ? string(prev.dam) : string(_spell.damage)
				return string_ext("{0}{1} Mars Damage", [_pre, _a])
			}
			if _spell.stage == 2 {
				var _a = _ic ? " (" + string(QueryDice(player,"mars","values")) + ")" : ""
				return string_ext("{0}Mars Damage: Mars Values{1}", [_pre, _a])
			}
			var _a = _ic ? " (" + string(QueryDice(player,"mars","values") * 2) + ")" : ""
			return string_ext("{0}Mars Damage: 2x Mars Values{1}", [_pre, _a])

		case "Gaia":
			if _spell.stage == 1 {
				var _a = _ic ? " (" + string(QueryDice(player,"venus","affinity")) + ")" : ""
				return string_ext("{0}Venus Damage: Venus Power{1}", [_pre, _a])
			}
			if _spell.stage == 2 {
				var _a       = _ic ? " (" + string(QueryDice(player,"venus","affinity") * 2) + ")" : ""
				var _g2range = _ic ? (QueryDice(player,"jupiter","charge") > 0 ? 6 : _range) : _range
				var _g2pre   = "[Range " + string(_g2range) + "] "
				return string_ext("{0}Venus Damage: Venus Power{1}\n(Range 6 if Jupiter Charge > 0)", [_g2pre, _a])
			}
			var _a = _ic ? " (" + string(QueryDice(player,"venus","affinity")) + ")" : ""
			var _b = _ic ? " (" + string(QueryDice(player,"jupiter","charge")) + ")" : ""
			return string_ext("{0}Venus Damage: Venus Power{1} x2^Jupiter Charge{2}", [_pre, _a,_b])

		case "Ice":
			if _spell.stage == 1 {
				var _a = _ic ? " (" + string(QueryDice(player,"all","charge")) + ")" : ""
				return string_ext("{0}Mercury Damage: All Charge{1}", [_pre, _a])
			}
			if _spell.stage == 2 {
				var _a = _ic ? " (" + string(QueryDice(player,"mercury","charge") * 2) + ")" : ""
				return string_ext("{0}Mercury Damage: 2x Mercury Charge{1}", [_pre, _a])
			}
			var _a = _ic ? " (" + string(QueryDice(player,"all","charge") * 2) + ")" : ""
			return string_ext("{0}Mercury Damage: 2x All Charge{1}", [_pre, _a])

		case "Impact":
			return string_ext("{0}Increase ATK by 3", [_pre])

		case "Planet Diver":
			if _spell.stage == 1 {
				var _has_both = player.venus > 0 and player.mars > 0
				if _ic {
					if _has_both {
						var _a = string(QueryDice(player,"venus","highest"))
						var _b = string(QueryDice(player,"mars","highest"))
						return string_ext("{0}Mars Damage: 2 Elemental Dice ({1} + {2}) x 2\n(x2 if one is Venus and the other Mars)", [_pre, _a, _b])
					}
					var _a = " (" + string(QueryDice(player,"elemental","top2")) + ")"
					return string_ext("{0}Mars Damage: 2 Elemental Dice{1}\n(x2 if one is Venus and the other Mars)", [_pre, _a])
				}
				return string_ext("{0}Mars Damage: 2 Elemental Dice\n(x2 if one is Venus and the other Mars)", [_pre])
			}
			var _a = _ic ? " (" + string(QueryDice(player,"all","values")) + ")" : ""
			return string_ext("{0}Set to 1 health and receive half healing for a turn. Next turn do Mars Damage or Venus Damage: All Values{1}", [_pre, _a])

		case "Plasma":
			if _spell.stage >= 3 { return string_ext("{0}Jupiter Damage: Randomly explode for each Jupiter Die", [_pre]) }
			return string_ext("{0}Jupiter Damage: Assign Jupiter Dice", [_pre])

		case "Ply":
		
			var _b = _ic ? " (" + string(QueryDice(player,"mercury","affinity")) + ")" : ""
			if _spell.stage == 3 { return string_ext("{0}Recover all HP + Regen Mercury Power{1} (3 Rounds)", [_pre]) }
			var _a = _ic ? " (" + string(prev.heal) + ")" : ""
			return _spell.stage == 1 ? string_ext("{0}Recover {1} HP + Regen 3 (3 Rounds)", [_pre, _a]) : string_ext("{0}Recover {1} HP + Regen Mercury Power{2} (3 Rounds)", [_pre,_a, _b])

		case "Prism":
			if _spell.stage < 3 {
				var _a = _ic ? " (" + string(QueryDice(player,"mercury","highest")) + ")" : ""
				var _b = _ic ? " (" + string(QueryDice(player,"jupiter","charge")) + ")" : ""
				return string_ext("{0}Mercury Damage: Highest Mercury{1} + X{2} targets skip their turn\n(X is Jupiter Charge)", [_pre, _a, _b])
			}
			var _a = _ic ? " (" + string(QueryDice(player,"mercury","highest") * 2) + ")" : ""
			return string_ext("{0}1 Mercury Damage: Hits X{1} Times\n(X is 2x Highest Mercury)", [_pre, _a])

		case "Psy Drain":
			var _a = _ic ? " (" + string(QueryDice(player,"all","charge")) + ")" : ""
			return string_ext("{0}Recover PP: All Charge{1}", [_pre, _a])

		case "Quake":
			if _spell.stage == 1 {
				var _a = _ic ? string(prev.dam) : string(_spell.damage)
				return string_ext("{0}{1} Venus Damage", [_pre, _a])
			}
			if _spell.stage == 2 {
				var _a = _ic ? " (" + string(QueryDice(player,"venus","affinity")) + ")" : ""
				return string_ext("{0}Venus Damage: Venus Power{1} + 3", [_pre, _a])
			}
			var _a = _ic ? " (" + string(QueryDice(player,"venus","affinity") * 2) + ")" : ""
			return string_ext("{0}Venus Damage: 2x Venus Power{1}", [_pre, _a])

		case "Ragnarok":
			if _spell.stage == 2 {
				var _a = _ic ? " (" + string(QueryDice(player,"venus","values") * 2) + ")" : ""
				return string_ext("{0}Venus Damage: Venus Values{1}", [_pre, _a])
			}
			var _a = _ic ? " (" + string(QueryDice(player,"venus","values")) + ")" : ""
			return string_ext("{0}Venus Damage: Venus Values{1}\n(Repeat)", [_pre, _a])

		case "Resonate":

			var _a = _ic ? ( _spell.stage == 2 ? " (" + string(QueryDice(player,"venus","charge")) + ") " : " (" + string(floor(QueryDice(player,"venus","charge") / 2)) + ") ") : ""

			return _spell.stage == 1 ? string_ext("[Passive]\nIncrease Range or Defense of multi-target spells by X{1} (1 Round)\n(X is 1/2 Venus Charge)", [_pre,_a]) :
			string_ext("[Passive]\nIncrease Range or Defense of multi-target spells by X{1} (1 Round)\n(X is Venus Charge)", [_pre,_a])

		case "Restore":
			return string_ext("{0}Cure Status", [_pre])

		case "Revive":
			var _a = _ic ?" (" + string(QueryDice(player,"venus","affinity") * 2)  + " HP)" : ""
			return string_ext("{0}Revive at end of round: 2x Venus Power{1} HP", [_pre, _a])

		case "Root":
			var _rt = (_spell.stage == 1) ? "3" : "6"
			return string_ext("{0}Grant {1} Root Tokens\n(+2 HP, +1 DEF per round)", [_pre, _rt])

		case "Slash":
			if _spell.stage == 3 {
				var _a = _ic ? " (" + string(WeaponAttack(false,false).dam) + ")" : ""
				return string_ext("{0}Jupiter Damage: Weapon Attack Damage{1} - Pierces DEF\n(+ Target DEF if 2+ Mercury Charge)\n(Repeat)", [_pre, _a])
			}
			if _spell.stage == 2 {
				var _a = _ic ? " (" + string(WeaponAttack(false,false).dam) + ")" : ""
				return string_ext("{0}Jupiter Damage: Weapon Attack Damage{1} - Pierces DEF\n(+ Target DEF if 2+ Mercury Charge)", [_pre, _a])
			}
			if _spell.stage == 1 {
				var _a = _ic ? " (" + string(WeaponAttack(false,false).dam) + ")" : ""
				return string_ext("{0}Normal Damage: Weapon Attack Damage{1} - Pierces DEF", [_pre, _a])
			}
			

		case "Sleep":
			return string_ext("{0}Inflict Sleep", [_pre])

		case "Spire":
			if _spell.stage == 1 {
				var _a = _ic ? " (" + string(QueryDice(player,"all","charge")) + ")" : ""
				return string_ext("{0}Venus Damage: All Charge{1}", [_pre, _a])
			}
			if _spell.stage == 2 {
				var _a = _ic ? " (" + string(QueryDice(player,"venus","charge") * 2) + ")" : ""
				return string_ext("{0}Venus Damage: 2x Venus Charge{1}", [_pre, _a])
			}
			var _a = _ic ? " (" + string(QueryDice(player,"all","charge") * 2) + ")" : ""
			return string_ext("{0}Venus Damage: 2x All Charge{1}", [_pre, _a])

		case "Thorn":
			var _a = _ic ? " (" + string(prev.dam) + ")" : ""
			if _spell.stage == 1 {
				return string_ext("{0}{1} Venus Damage", [_pre, _a])
			}
			if _spell.stage == 2 {
				var _a = _ic ? " (" + string(QueryDice(player,"venus","charge")) + ")" : ""
				return string_ext("{0}Venus Damage: Venus Charge{1}", [_pre, _a])
			}
			var _a = _ic ? " (" + string(QueryDice(player,"all","charge")) + ")" : ""
			return string_ext("{0}Venus Damage: All Charge{1}", [_pre, _a])

		case "Volcano":
			var _base = (_spell.stage == 1) ? 4 : (_spell.stage == 2 ? 6 : 10)
			var _a    = _ic ? " (" + string(QueryDice(player,"mars","affinity")) + ")" : ""
			return string_ext("{0}Mars Damage: Mars Power{2} + {1}", [_pre, string(_base), _a])

		case "Ward":
			return string_ext("{0}Increase DEF by 3", [_pre])

		case "Whirlwind":
			var _a = _ic ? " (" + string(QueryDice(player,"jupiter","charge") * 2) + ")" : ""
			if _spell.stage == 3 {
				var _b = _ic ? " (" + string(QueryDice(player,"all","charge") - QueryDice(player,"jupiter","charge")) + ")" : ""
				return string_ext("{0}Jupiter Damage: 2x Jupiter Charge{1} + Non-Jupiter Charge{2}", [_pre, _a, _b])
			}
			return string_ext("{0}Jupiter Damage: 2x Jupiter Charge{1}", [_pre, _a])

		case "Wish":
			if _spell.stage == 1 {
				var _a = _ic ? " (" + string(QueryDice(player,"mercury","highest")) + ")" : ""
				return string_ext("{0}Recover HP: Highest Mercury{1}", [_pre, _a])
			}
			if _spell.stage == 2 {
				var _a = _ic ? " (" + string(QueryDice(player,"mercury","highest"))  + ")" : ""
				var _b = _ic ? " (" + string(QueryDice(player,"mercury","affinity")) + ")" : ""
				return string_ext("{0}Recover HP: Highest Mercury{1} + Mercury Power{2}", [_pre, _a, _b])
			}
			var _a = _ic ? " (" + string(QueryDice(player,"all","charge") * 2)      + ")" : ""
			var _b = _ic ? " (" + string(QueryDice(player,"mercury","affinity"))     + ")" : ""
			return string_ext("{0}Recover HP: All Charge{1} + Mercury Power{2}", [_pre, _a, _b])

		case "Aegis":
			var _a = _ic ? " (" + string(QueryDice(player,"venus","charge")) + ")" : ""
			if _spell.stage == 1 {
				return string_ext("{0}+X{1} DEF, -X{1} ATK\n(X is Venus Charge)\nPsynergy is affected by ATK (1 Round)", [_pre, _a])
			}
			return string_ext("{0}+X{1} DEF, -X{1} ATK\n(X is Venus Charge)\n(No ATK down if Venus Charge is max)", [_pre, _a])
		case "Miracle":
			var _v  = _ic ? " (" + string(QueryDice(player,"venus","charge"))   + ")" : ""
			var _ma = _ic ? " (" + string(QueryDice(player,"mars","charge"))    + ")" : ""
			var _j  = _ic ? " (" + string(QueryDice(player,"jupiter","charge")) + ")" : ""
			var _me = _ic ? " (" + string(QueryDice(player,"mercury","charge")) + ")" : ""
			return string_ext("[Self] +{0} DEF (Venus Charge)\n[" + _tgt +"] {2} Mars Damage (Mars Charge)\n[{3}] Inflict Random Status (Jupiter Charge)\n[Range 1 Ally] Recover {4} HP (Mercury Charge)", [_v,_pre,_ma,_j,_me])

		default: return _spell.text
	}
}

// ─── Djinn ───────────────────────────────────────────────────────────────────
// Available locals: _djinn, _tgt, prev (CalcPreview result)
// Weapon Attack Damage = WeaponAttack(false,false) — no unleash
// Weapon Attack        = WeaponAttack(true,false)  — with unleash

function _BVD_Djinn(action_id, player, prev) {
	var _djinn = global.djinnlist[action_id]

	var _ic    = global.inCombat
	var _echo  = CheckPassive("_DjinnEcho")
	var _range = (_echo != undefined) ? 3 : 1
	var _tgt   = _BVD_TargetStr("Other", prev.targets, _range)
	var _pre   = "[" + _tgt + "]\n"
	var _e     = _djinn.element

	switch _djinn.name {

		// ── All-charge damage ────────────────────────────────────────────
		case "Bane": case "Wheeze":
			var _a = _ic ? " (" + string(QueryDice(player,"all","charge")) + ")" : ""
			return string_ext("{0}" + _e + " Damage: All Charge{1}\nInflict Poison", [_pre, _a])

		case "Fever": case "Smog":
			var _a = _ic ? " (" + string(QueryDice(player,"all","charge")) + ")" : ""
			return string_ext("{0}" + _e + " Damage: All Charge{1}\nInflict Delude", [_pre, _a])

		case "Mist":
			var _a = _ic ? " (" + string(QueryDice(player,"all","charge")) + ")" : ""
			return string_ext("{0}" + _e + " Damage: All Charge{1}\nInflict Sleep", [_pre, _a])

		case "Char": case "Blitz": case "Squall":
			var _a = _ic ? " (" + string(QueryDice(player,"all","charge")) + ")" : ""
			return string_ext("{0}" + _e + " Damage: All Charge{1}\nInflict Stun", [_pre, _a])

		case "Hail":
			var _a = _ic ? " (" + string(QueryDice(player,"all","charge")) + ")" : ""
			return string_ext("{0}" + _e + " Damage: All Charge{1}\n-2 DEF", [_pre, _a])

		case "Sleet":
			var _a = _ic ? " (" + string(QueryDice(player,"all","charge")) + ")" : ""
			return string_ext("{0}" + _e + " Damage: All Charge{1}\n-2 ATK", [_pre, _a])

		case "Chill":
			var _a = _ic ? " (" + string(QueryDice(player,"all","charge")) + ")" : ""
			return string_ext("{0}" + _e + " Damage: All Charge{1}\nClear all stat changes", [_pre, _a])

		case "Fugue":
			var _a = _ic ? " (" + string(QueryDice(player,"all","charge")) + ")" : ""
			return string_ext("{0} 1 Mars Damage: Hits X times{1}\nInflict Psy Seal\n(X is All Charge)", [_pre, _a])

		case "Shine":
			var _a = _ic ? " (" + string(QueryDice(player,"all","charge")) + ")" : ""
			return string_ext("{0}Mars Damage: All Charge{1}\nDelude neighbours", [_pre, _a])

		case "Fury":
			var _a = _ic ? " (" + string(QueryDice(player,"all","charge")) + ")" : ""
			return string_ext("{0}Mars Damage: All Charge{1}\nIgnores DEF.", [_pre, _a])

		// ── Weapon-based damage ──────────────────────────────────────────
		case "Flint": case "Cannon": case "Sour":
			var _a = _ic ? " (" + string(WeaponAttack(false,false).dam) + ")" : ""
			var _b = _ic ? " (" + string(floor(WeaponAttack(false,false).dam / 2)) + ")" : ""
			return string_ext("{0}" + _e +" Damage: Weapon Attack{1} + X{2}\n(X is 1/2 of damage)", [_pre, _a, _b])

		case "Sap":
			var _a = _ic ? " (" + string(WeaponAttack(true,false).dam) + ")" : ""
			var _b = _ic ? " (" + string(WeaponAttack(false,false).dam / 2) + ")" : ""
			return string_ext("{0}Venus Damage: Weapon Attack{1} + Heal X{2} HP\n(X is 1/2 of damage)", [_pre, _a, _b])

		case "Geode":
			var _a = _ic ? " (" + string(WeaponAttack(true,false).dam)  + ")" : ""
			var _b = _ic ? " (" + string(WeaponAttack(false,false).dam) + ")" : ""
			return string_ext("{0}" + _e + " Damage: Weapon Attack{1} (With Unleash) + Weapon Attack{2} + (Without Unleash)", [_pre, _a, _b])

		case "Torch": case "Scorch":
			var _a = _ic ? " (" + string(WeaponAttack(false,false).dam) + ")" : ""
			return string_ext("{0}" + _e + " Damage: Weapon Attack Damage{1}", [_pre, _a])

		case "Gel":
			var _a = _ic ? " (" + string(WeaponAttack(true,false).dam)                   + ")" : ""
			var _b = _ic ? " (" + string(WeaponAttack(true,false).unleash.dam_bonus * 2) + ")" : ""
			return string_ext("{0}" + _e + " Damage: Weapon Attack{1} + 2x Unleash{2}", [_pre, _a, _b])

		case "Serac": case "Whorl":
			var _a = _ic ? " (" + string(WeaponAttack(false,false).dam) + ")" : ""
			return string_ext("{0}" + _e + " Damage: Weapon Attack{1}\nChance to instantly down", [_pre, _a])

		case "Echo":
			var _a = _ic ? " (" + string(WeaponAttack(true,false).dam)              + ")" : ""
			var _b = _ic ? " (" + string(WeaponAttack(true,false).unleash.dam_bonus) + ")" : ""
			return string_ext("{0}Venus Damage: Weapon Attack{1}\nUnleash Bonus{2} triggers twice", [_pre, _a, _b])

		case "Core":
			var _a = _ic ? " (" + string(WeaponAttack(true,false).dam) + ")" : ""
			return string_ext("{0}Mars Damage: Weapon Attack{1}\nIf half of max damage is done - Reset ATK and DEF", [_pre, _a])

		case "Gust":
			var _a = _ic ? " (" + string(WeaponAttack(true,false).dam) + ")" : ""
			return string_ext("{0}Jupiter Damage: Weapoon Attack{1}\nChance to Attack again", [_pre, _a])

		// ── Healing (all allies) ─────────────────────────────────────────
		case "Spritz":
			var _a = _ic ? " (" + string(QueryDice(player,"elemental","charge")) + ")" : ""
			return string_ext("{0}Recover HP: Elemental Charge{1}", [_pre, _a])

		case "Balm":
			return string_ext("{0}Recover 50% Max HP\n\nStays Standby when played", [_pre])

		case "Crystal":
			var _a = _ic ? " (" + string(QueryDice(player,"elemental","charge")) + ")" : ""
			var _b = _ic ? " (" + string(player.def + player.defmod)             + ")" : ""
			return string_ext("{0}Recover HP: Elemental Charge{1} + DEF{2}", [_pre, _a, _b])
		case "Steel":
			var _a = _ic ? " (" + string(WeaponAttack(true,false).dam)               + ")" : ""
			var _b = _ic ? " (" + string(WeaponAttack(true,false).unleash.dam_bonus) + ")" : ""
			return string_ext("{0}Venus Damage: Weapon Attack{1}\nRecover HP: Unleash Bonus{2}", [_pre, _a, _b])

		// ── Healing (single) ─────────────────────────────────────────────
		case "Spring": case "Breath":
			var _a = _ic ? " (" + string(QueryDice(player,"all","charge")) + ")" : ""
			return string_ext("{0}Recover HP: All Charge{1}", [_pre, _a])

		case "Fizz":
			return string_ext("{0}Recover 50% HP", [_pre])

		// ── PP recovery ──────────────────────────────────────────────────
		case "Ember":
			var _a = _ic ? " (" + string(QueryDice(player,"mars","charge")) + ")" : ""
			return string_ext("{0}Restore PP: Mars Charge{1}", [_pre, _a])

		case "Aroma":
			var _a = _ic ? " (" + string(QueryDice(player,"elemental","charge")) + ")" : ""
			return string_ext("{0}Restore PP: Elemental Charge{1}", [_pre, _a])

		case "Ether":
			var _a = _ic ? " (" + string(QueryDice(player,"all","charge")) + ")" : ""
			return string_ext("{0}Restore PP: All Charge{1}", [_pre, _a])
		case "Reflux":
			var _mod = (player.name == "Garet" or player.name == "Tyrell") ? player.atkmod * 2 : player.atkmod;
			var _a = _ic ? " (" + string(player.atk + _mod) + ")" : ""

			return string_ext("[Passive]\nAttackers take ATK{1} damage", [_pre, _a, _tgt])

		// ── Revive ───────────────────────────────────────────────────────
		case "Quartz": return string_ext("{0}Revive (50% Max HP, chance to heal to full)", [_pre, _tgt])
		case "Dew":    return string_ext("{0}Revive (Full HP)\n\nStays Standby when played", [_pre, _tgt])
		case "Spark":  return string_ext("{0}Revive (50% Max HP)", [_pre, _tgt])
		case "Tinder":
			var _a = _ic ? " (" + string(QueryDice(player,"mars","affinity")) + ")" : ""
			return string_ext("{0}Revive at end of round: Mars Power{1} HP", [_pre, _a])

		// ── Stat buffs ───────────────────────────────────────────────────
		case "Forge":                return string_ext("{0}Increase ATK", [_pre, _tgt])
		case "Iron":                 return string_ext("{0}Increase DEF", [_pre, _tgt])
		case "Corona": case "Breeze": return string_ext("{0}Increase DEF", [_pre, _tgt])

		// ── Status infliction ────────────────────────────────────────────
		case "Luff": case "Rime":  return string_ext("{0}Inflict Psy Seal", [_pre, _tgt])
		case "Fog":                return string_ext("{0}Inflict Delude", [_pre, _tgt])
		case "Waft":               return string_ext("{0}Inflict Sleep", [_pre, _tgt])
		case "Gasp":               return string_ext("{0}Inflict Haunt\n\nStays Standby when played", [_pre, _tgt])

		// ── Status cure ──────────────────────────────────────────────────
		case "Tonic": return string_ext("{0}Clear Status", [_pre, _tgt])
		case "Salt":  return string_ext("{0}Clear All Effects", [_pre, _tgt])

		// ── Passives / utility ───────────────────────────────────────────
		case "Shade": case "Granite": return string_ext("[Passive]\nReduce Damage Taken by 50%", [])
		case "Flash":    return string_ext("[Passive]\nCap incoming damage to a max of 1\n\nStays Standby when played", [_pre, _tgt])
		case "Ground":   return string_ext("[Passive]\nSkip next Enemy Turn", [_pre])
		case "Mud":      return string_ext("[Passive]\nReduce enemy skill choice by 1 (3 rounds)", [_pre])
		case "Vine":     return string_ext("[Passive]\nAll enemy attempts to inflict status fail (3 rounds)", [_pre])
		case "Steam":    return string_ext("[Passive]\nIncrease Elemental Power", [_pre])
		case "Kindle":   return string_ext("[Passive]\nIncrease Melee Power", [_pre])
		case "Coal":     return string_ext("{0}Gain 1 Partial Reroll until end of turn", [_pre, _tgt])
		case "Zephyr":   return string_ext("{0}Gain 1 Reroll", [_pre, _tgt])
		case "Lull":     return string_ext("[Instant]\nEnd this round immediately (return to first player)", [_pre, _tgt])
		case "Haze":     return string_ext("{0}Immune to damage and effects (1 round)\n\nStays Standby when played", [_pre, _tgt])
		case "Flower":   return string_ext("{0}Recover HP: Assign Venus Dice", [_pre, _tgt])
		case "Petra":    return string_ext("[Passive]\nReroll an enemy move (3 rounds)", [_pre, _tgt])
		case "Gale":     return string_ext("{0}50% to down instantly", [_pre, _tgt])
		case "Eddy":     return "[Instant]\nPut one djinni in recovery into Standby\n\nStays Standby when unleashed"
		case "Kite":     return string_ext("{0}Gain an extra turn", [_pre])
		case "Meld":     return string_ext("{0}Weapon Attack: Use an ally's weapon", [_pre])
		case "Mold":     return string_ext("{0}Neighbours attack target", [_pre])

		default: return _djinn.text
	}
}

// ─── Item ────────────────────────────────────────────────────────────────────
// Available locals: _item, _tgt, prev (CalcPreview result)

function _BVD_Item(action_id, player, prev) {
	var _item = global.itemcardlist[action_id]
	var _tgt  = _BVD_TargetStr("Ally", prev.targets, 1)

	var _ic = global.inCombat
	switch _item.name {
		case "Herb":          return "[Range 1]\nRecover 3 HP"
		case "Antidote":          return "[Range 1]\nCure Poison"
		case "Lucky Medal":          return "[All Allies]\nGain an extra turn"
		case "Nut":           return "[Range 1]\nRecover 6 HP"
		case "Vial":          return "[Range 1]\nRecover 10 HP"
		case "Potion":        return "[Range 1]\nRecover 20 HP"
		case "Psy Crystal":   return "[Range 1]\nRestore 3 PP"
		case "Water of Life": return "[Range 1]\nRevive (Full HP)"
		case "Mist Potion":   return "[All Allies]\nRecover 100% HP"
		case "Oil Drop":
			var _a = _ic ? " (" + string(QueryDice(player,"elemental","charge")) + ")" : ""
			return string_ext("[All Opposing]\nMars Damage: Elemental Charge{0} + 1", [_a])
		case "Bramble Seed":
			var _a = _ic ? " (" + string(QueryDice(player,"elemental","charge")) + ")" : ""
			return string_ext("[All Opposing]\nVenus Damage: Elemental Charge{0} + 1", [_a])
		case "Crystal Powder":
			var _a = _ic ? " (" + string(QueryDice(player,"elemental","charge")) + ")" : ""
			return string_ext("[All Opposing]\nMercury Damage: Elemental Charge{0} + 1", [_a])
		case "Weasel's Claw":
			var _a = _ic ? " (" + string(QueryDice(player,"elemental","charge")) + ")" : ""
			return string_ext("[All Opposing]\nJupiter Damage: Elemental Charge{0} + 1", [_a])
		case "Smoke Bomb": return "[Range 3]\nInflict Delude"
		case "Sleep Bomb": return "[Range 3]\nInflict Sleep"
		default: return _item.text
	}
}

// ─── Summon ──────────────────────────────────────────────────────────────────

function _BVD_Summon(action_id, player, prev) {
	var _summon = global.summonlist[action_id]
	var _ic     = global.inCombat
	var _range  = _summon.range

	// Build cost string
	var _cost = ""
	if _summon.venus   > 0 { _cost += string(_summon.venus)   + "V " }
	if _summon.mars    > 0 { _cost += string(_summon.mars)    + "Ma " }
	if _summon.jupiter > 0 { _cost += string(_summon.jupiter) + "J " }
	if _summon.mercury > 0 { _cost += string(_summon.mercury) + "Me " }
	_cost = "[Cost: " + string_trim(_cost) + "]\n"

	switch _summon.name {

		case "Zagan":
			var _a = _ic ? " (" + string(WeaponAttack(false,false).dam) + ")" : ""
			return _cost + string_ext("[Range {0}]\nVenus Damage: Weapon Attack Damage{1}\n-3 DEF", [string(_range), _a])

		case "Megaera":
			var _a = _ic ? " (" + string(WeaponAttack(false,false).dam) + ")" : ""
			return _cost + string_ext("[All Opposing]\nVenus Damage: 2x Weapon Attack{1}\n+3 ATK to all allies", [_a])

		case "Flora":
			var _total_jup = 0
			for (var _p = 0; _p < array_length(global.players); _p++) {
				if (global.players[_p].hp > 0) { _total_jup += global.players[_p].jupiter }
			}
			var _a = _ic ? " (" + string(_total_jup) + ")" : ""
			return _cost + string_ext("[Range {0}]\nJupiter Damage: All Party Jupiter Power{1}\nInflict Sleep", [string(_range), _a])

		case "Catastrophe":
			var _a = _ic ? " (" + string(WeaponAttack(true,false).dam) + ")" : ""
			return _cost + string_ext("[All Opposing]\nVenus Damage: Weapon Attack{1}", [_a])

		case "Azul":
			var _a = _ic ? " (" + string(QueryDice(player,"elemental","affinity")) + ")" : ""
			return _cost + string_ext("[Range {0}]\nMercury Damage: Elemental Power{1}\nInflict Stun", [string(_range), _a])

		case "Haures":
			return _cost + "[All Opposing]\nInflict Poison\n(Poison deals 2 damage)"

		case "Coatlicue":
			return _cost + "[All Allies]\nRecover HP to full\nRegen 5 HP (5 Rounds)"

		case "Ulysses":
			return _cost + "[Passive]\nEnemies skip 2 turns\n(Bosses skip 3 turns)"

		case "Iris":
			return _cost + "[All Allies]\nRecover HP to full\nDamage capped to 1 (1 Round)\nDamage halved (2 Rounds)"

		case "Charon":
			return _cost + "[Range 1]\nInstant KO"

		case "Judgment":
			return _cost + "[All Opposing]\nVenus Damage: Cast a Venus spell at max tier with all 6s"

		case "Meteor":
			return _cost + "[All Opposing]\nMars Damage: Cast a Mars spell at max tier with all 6s"

		case "Thor":
			return _cost + "[All Opposing]\nJupiter Damage: Cast a Jupiter spell at max tier with all 6s"

		case "Boreas":
			return _cost + "[All Opposing]\nMercury Damage: Cast a Mercury spell at max tier with all 6s"

		case "Moloch":
			return _cost + "[Passive]\nNullify a chosen enemy move number permanently"

		case "Eclipse":
			return _cost + "[All Opposing]\nJupiter Damage: 50% Max HP\n(10% to Bosses)\nInflict Delude"

		case "Daedalus":
			var _a = _ic ? " (" + string(QueryDice(player,"all","values")) + ")" : ""
			return _cost + string_ext("[Range {0}]\nJupiter Damage: All Dice Values{1}\nNeighbours take 50%", [string(_range), _a])

		default: return _cost + _summon.text
	}
}

// ─── Shared helpers ──────────────────────────────────────────────────────────

/// Returns target string: "1 Opponent", "3 Opponents", "All Allies", "Self", etc.
/// tgt_type is the spell's targetType field; tgt_category is CalcPreview.targets;
/// range is the numeric count (already boosted by Resonate if applicable).
function _BVD_TargetStr(tgt_type, tgt_category, range) {
	switch tgt_category {
		case "All Allies":  return "All Allies"
		case "All Enemies": return "All Opponents"
		case "Self":        return "Self"
	}
	if tgt_type == "Self"  { return "Self" }
	if tgt_type == "Ally"  { return (range == 1) ? "1 Ally"     : string(range) + " Allies" }
	if range == 12{return "All Opposing"}
	return (range == 1) ? "Range 1" : "Range " + string(range)
}
