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
		case "djinni": return _BVD_Djinn(action_id, player, _prev)
		case "item":   return _BVD_Item(action_id, player, _prev)
	}
	return _prev.description
}

// ─── Spell ───────────────────────────────────────────────────────────────────
// Format for damage: "[Range X] Element Damage // Component1 + Component2"
// Format for heals:  "[Range X] Recover <amount> HP"
// Format for utility: natural language
// _ic ternary: combat = computed number, out of combat = keyword label
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
	var _pre  = "[Range " + string(_range) + "] "
	var _suff = _range > 1 ? "ies" : "y"

	switch _spell.base {

		case "Astral Blast":
			var _a = _ic ? string(WeaponAttack(false,false).dam)        : "Weapon Attack Damage"
			var _b = _ic ? string(QueryDice(player,"jupiter","charge")) : "Jupiter Charge"
			return string_ext("{0}Normal + Jupiter Damage // {1} + {2}", [_pre, _a, _b])

		case "Backstab":
			var _a = _ic ? string(WeaponAttack(false,false).dam) : "Weapon Attack Damage"
			return string_ext("{0}Normal + Jupiter Damage // {1} + 2. 10% chance to down.", [_pre, _a])

		case "Beam":
			if _spell.stage == 1 {
				var _a = _ic ? string(QueryDice(player,"mars","uncharge"))   : "Uncharged Mars"
				var _b = _ic ? string(QueryDice(player,"mars","charge") * 2) : "2x Mars Charge"
				return string_ext("{0}Mars Damage // {1} + {2}", [_pre, _a, _b])
			}
			var _a = _ic ? string(QueryDice(player,"mars","charge") * 3) : "3x Mars Charge"
			return string_ext("{0}Mars Damage // {1}", [_pre, _a])

		case "Blast":
			var _bnum = 0
			if player.venus   > 0 { _bnum++ }
			if player.mars    > 0 { _bnum++ }
			if player.jupiter > 0 { _bnum++ }
			if player.mercury > 0 { _bnum++ }
			var _bpre  = _ic ? "[Range " + string(_bnum) + "] " : "[Range X] "
			var _xsuff = _ic ? "" : " (X = # of unique elements)"
			if _spell.stage == 1 {
				var _a = _ic ? string(QueryDice(player,"all","charge")) : "All Charge"
				return string_ext("{0}Mars Damage // {1}{2}", [_bpre, _a, _xsuff])
			}
			if _spell.stage == 2 {
				var _a = _ic ? string(QueryDice(player,"all","charge")) : "All Charge"
				var _b = _ic ? string(_bnum * 2)                        : "2x X"
				return string_ext("{0}Mars Damage // {1} + {2}{3}", [_bpre, _a, _b, _xsuff])
			}
			var _a = _ic ? string(QueryDice(player,"venus","highest"))   : "Highest Venus"
			var _b = _ic ? string(QueryDice(player,"mars","highest"))    : "Highest Mars"
			var _c = _ic ? string(QueryDice(player,"jupiter","highest")) : "Highest Jupiter"
			var _d = _ic ? string(QueryDice(player,"mercury","highest")) : "Highest Mercury"
			return string_ext("[Range 3] Mars Damage // {0} + {1} + {2} + {3}", [_a, _b, _c, _d])

		case "Bolt":
			var _a = string(real(_spell.damage) + (_ic ? _dam : 0))
			return string_ext("{0}Jupiter Damage // {1}. Inflict Stun.", [_pre, _a])

		case "Break":
			return string_ext("{0}Reset ATK and DEF", [_pre])

		case "Burn Off":
			return string_ext("[Range {0} All{1}] Reset ATK and DEF", [string(_range), _suff])

		case "Cloak":
			return string_ext("[Range {0} All{1}] Immune to damage or effects for 1 round", [string(_range), _suff])

		case "Cool":
		var _a = _ic ? string(_spell.damage) : "2"
			if _spell.stage == 1 {
				return string_ext("{0}Mercury Damage // {1}", [_pre, _a])
			}
			if _spell.stage == 2 {
				var _a = _ic ? string(QueryDice(player,"mercury","charge")) : "Mercury Charge"
				return string_ext("{0}Mercury Damage // {1}", [_pre, _a])
			}
			var _a = _ic ? string(QueryDice(player,"all","charge")) : "All Charge"
			return string_ext("{0}Mercury Damage // {1}", [_pre, _a])

		case "Cure":
			if _spell.stage == 1 {
				var _a = _ic ? string(QueryDice(player,"venus","highest")) : "Highest Venus"
				return string_ext("{0}Recover {1} HP. Caster recovers the same amount.", [_pre, _a])
			}
			if _spell.stage == 2 {
				var _a = _ic ? string(QueryDice(player,"venus","top2")) : "Top 2 Venus"
				return string_ext("{0}Recover {1} HP. Caster recovers the same amount.", [_pre, _a])
			}
			var _a = _ic ? string(QueryDice(player,"venus","top2") * 2) : "2x Top 2 Venus"
			return string_ext("{0}Recover {1} HP. Caster recovers the same amount.", [_pre, _a])

		case "Delude":
			return string_ext("{0}Inflict Delusion", [_pre])

		case "Diamond Dust":
			if _spell.stage == 2 {
				var _a = _ic ? string(WeaponAttack(false,false).dam * 2) : "2x Weapon Attack Damage"
				return string_ext("{0}Mercury Damage // {1}", [_pre, _a])
			}
			var _a = _ic ? string(WeaponAttack(false,false).dam) : "Weapon Attack Damage"
			return string_ext("{0}Mercury Damage // {1}. Neighbours take 50% splash.", [_pre, _a])

		case "Djinn Echo":
			if _spell.stage >= 2 { return "[Passive] Djinn abilities with Range 1 become Range 3 (1 Round). Unleash an ally's Djinni." }
			return "[Passive] Djinn abilities with Range 1 become Range 3 (1 Round)"

		case "Douse": case "Flare": case "Ray":
			return string_ext("{0}" + _elem + " Damage // {1}", [_pre, string(real(_spell.damage))])

		case "Dull":
			return string_ext("{0}Reduce ATK by 3", [_pre])

		case "Frost":
			if _spell.stage == 1 {
				var _a = _ic ? string(QueryDice(player,"melee","charge")) : "Melee Charge"
				return string_ext("{0}Mercury Damage // {1}", [_pre, _a])
			}
			var _a = _ic ? string(QueryDice(player,"melee","charge"))       : "Melee Charge"
			var _b = _ic ? string(QueryDice(player,"mercury","charge") * 2) : "2x Mercury Charge"
			return string_ext("{0}Mercury Damage // {1} + {2}", [_pre, _a, _b])

		case "Froth":
			var _a = _ic ? string(QueryDice(player,"mercury","charge")) : "Mercury Charge"
			if _spell.stage < 3 {
				var _b = _ic ? (QueryDice(player,"venus","charge") >= 2 ? ". -2 DEF" : "") : ". -2 DEF if Venus Charge >= 2"
				return string_ext("{0}Mercury Damage // {1}{2}", [_pre, _a, _b])
			}
			var _b = _ic ? string(QueryDice(player,"venus","charge")) : "Venus Charge"
			return string_ext("{0}Mercury Damage // {1}. -{2} DEF", [_pre, _a, _b])

		case "Fume":
			if _spell.stage == 1 {
				return string_ext("{0}Mars Damage // {1}", [_pre, string(real(_spell.damage))])
			}
			if _spell.stage == 2 {
				var _a = _ic ? string(QueryDice(player,"mars","values")) : "Mars Values"
				return string_ext("{0}Mars Damage // {1}", [_pre, _a])
			}
			var _a = _ic ? string(QueryDice(player,"mars","values") * 2) : "2x Mars Values"
			return string_ext("{0}Mars Damage // {1}", [_pre, _a])

		case "Gaia":
			if _spell.stage == 1 {
				var _a = _ic ? string(QueryDice(player,"venus","affinity")) : "Venus Power"
				return string_ext("{0}Venus Damage // {1}", [_pre, _a])
			}
			if _spell.stage == 2 {
				var _a       = _ic ? string(QueryDice(player,"venus","affinity") * 2) : "2x Venus Power"
				var _g2range = _ic ? (QueryDice(player,"jupiter","charge") > 0 ? 6 : _range) : _range
				var _g2pre   = "[Range " + string(_g2range) + "] "
				var _b       = _ic ? "" : " (Range 6 if Jupiter Charge > 0)"
				return string_ext("{0}Venus Damage // {1}{2}", [_g2pre, _a, _b])
			}
			var _a = _ic ? string(prev.dam) : "Venus Power x 2^Jupiter Charge"
			return string_ext("{0}Venus Damage // {1}", [_pre, _a])

		case "Ice":
			if _spell.stage == 1 {
				var _a = _ic ? string(QueryDice(player,"all","charge")) : "All Charge"
				return string_ext("{0}Mercury Damage // {1}", [_pre, _a])
			}
			if _spell.stage == 2 {
				var _a = _ic ? string(QueryDice(player,"mercury","charge") * 2) : "2x Mercury Charge"
				return string_ext("{0}Mercury Damage // {1}", [_pre, _a])
			}
			var _a = _ic ? string(QueryDice(player,"all","charge") * 2) : "2x All Charge"
			return string_ext("{0}Mercury Damage // {1}", [_pre, _a])

		case "Impact":
			return string_ext("{0}Grant ATK Up", [_pre])

		case "Planet Diver":
			if _spell.stage == 1 {
				var _a = _ic ? string(QueryDice(player,"venus","highest")) : "Highest Venus"
				var _b = _ic ? string(QueryDice(player,"mars","highest"))  : "Highest Mars"
				return string_ext("{0}Mars Damage // ({1} + {2}) x 2", [_pre, _a, _b])
			}
			var _a = _ic ? string(QueryDice(player,"all","values")) : "All Dice Power"
			return string_ext("{0}Normal Damage // {1}", [_pre, _a])

		case "Plasma":
			if _spell.stage >= 3 { return string_ext("{0}Jupiter Damage // Assigned Jupiter Dice (Repeat per Charge)", [_pre]) }
			return string_ext("{0}Jupiter Damage // Assigned Jupiter Dice", [_pre])

		case "Ply":
			if _spell.stage == 3 { return string_ext("{0}Full HP Recover", [_pre]) }
			var _a = _ic ? string(prev.heal) : (_spell.stage == 1 ? "Highest Mercury" : "Mercury Count")
			return string_ext("{0}Recover {1} HP", [_pre, _a])

		case "Prism":
			if _spell.stage < 3 {
				var _a = _ic ? string(QueryDice(player,"mercury","highest")) : "Highest Mercury"
				return string_ext("{0}Mercury Damage // {1}", [_pre, _a])
			}
			var _a = _ic ? string(QueryDice(player,"mercury","highest") * 2) : "2x Highest Mercury"
			return string_ext("{0}Mercury Damage // {1}", [_pre, _a])

		case "Psy Drain":
			var _a = _ic ? string(prev.heal) : "All Charges"
			return string_ext("{0}Recover {1} PP", [_pre, _a])

		case "Quake":
			if _spell.stage == 1 {
				return string_ext("{0}Venus Damage // {1}", [_pre, string(real(_spell.damage))])
			}
			if _spell.stage == 2 {
				var _a = _ic ? string(QueryDice(player,"venus","affinity")) : "Venus Count"
				return string_ext("{0}Venus Damage // 3 + {1}", [_pre, _a])
			}
			var _a = _ic ? string(QueryDice(player,"venus","affinity") * 2) : "2x Venus Count"
			return string_ext("{0}Venus Damage // {1}", [_pre, _a])

		case "Ragnarok":
			if _spell.stage == 2 {
				var _a = _ic ? string(QueryDice(player,"venus","values") * 2) : "2x Venus Power"
				return string_ext("{0}Venus Damage // {1}", [_pre, _a])
			}
			var _a = _ic ? string(QueryDice(player,"venus","values")) : "Venus Power"
			return string_ext("{0}Venus Damage // {1}", [_pre, _a])

		case "Resonate":
			return string_ext("{0}Gain Resonate: Expand next multi-target Spell or Summon", [_pre])

		case "Restore":
			return string_ext("{0}Cure Status", [_pre])

		case "Revive":
			var _a = _ic ? string(prev.heal) : "2x Venus Count"
			return string_ext("{0}Revive ({1} HP)", [_pre, _a])

		case "Root":
			var _rt = (_spell.stage == 1) ? "3" : "6"
			return string_ext("{0}Grant {1} Root Tokens", [_pre, _rt])

		case "Slash":
			if _spell.stage == 3 {
				var _a = _ic ? string(WeaponAttack(false,false).dam * 2) : "2x Weapon Attack Damage"
				return string_ext("{0}" + _elem + " Damage // {1}", [_pre, _a])
			}
			var _a = _ic ? string(WeaponAttack(false,false).dam) : "Weapon Attack Damage"
			return string_ext("{0}" + _elem + " Damage // {1}", [_pre, _a])

		case "Sleep":
			return string_ext("{0}Inflict Sleep", [_pre])

		case "Spire":
			if _spell.stage == 1 {
				var _a = _ic ? string(QueryDice(player,"all","charge")) : "All Charge"
				return string_ext("{0}Venus Damage // {1}", [_pre, _a])
			}
			if _spell.stage == 2 {
				var _a = _ic ? string(QueryDice(player,"venus","charge") * 2) : "2x Venus Charge"
				return string_ext("{0}Venus Damage // {1}", [_pre, _a])
			}
			var _a = _ic ? string(QueryDice(player,"all","charge") * 2) : "2x All Charge"
			return string_ext("{0}Venus Damage // {1}", [_pre, _a])

		case "Thorn":
		var _a = _ic ? string(_spell.damage) : "2"
		
			if _spell.stage == 1 {
				return string_ext("{0}Venus Damage // {1}", [_pre, _a])
			}
			if _spell.stage == 2 {
				var _a = _ic ? string(QueryDice(player,"venus","charge")) : "Venus Charge"
				return string_ext("{0}Venus Damage // {1}", [_pre, _a])
			}
			var _a = _ic ? string(QueryDice(player,"all","charge")) : "All Charge"
			return string_ext("{0}Venus Damage // {1}", [_pre, _a])

		case "Volcano":
			var _base = (_spell.stage == 1) ? 4 : (_spell.stage == 2 ? 6 : 10)
			var _a    = _ic ? string(QueryDice(player,"mars","affinity")) : "Mars Count"
			return string_ext("{0}Mars Damage // {1} + {2}", [_pre, string(_base), _a])

		case "Ward":
			return string_ext("{0}Grant DEF Up", [_pre])

		case "Whirlwind":
			var _a = _ic ? string(QueryDice(player,"jupiter","charge") * 2) : "2x Jupiter Charge"
			if _spell.stage == 3 {
				var _b = _ic ? string(QueryDice(player,"all","charge") - QueryDice(player,"jupiter","charge")) : "Bonus Charges"
				return string_ext("{0}Jupiter Damage // {1} + {2}", [_pre, _a, _b])
			}
			return string_ext("{0}Jupiter Damage // {1}", [_pre, _a])

		case "Wish":
			if _spell.stage == 1 {
				var _a = _ic ? string(QueryDice(player,"mercury","highest")) : "Highest Mercury"
				return string_ext("{0}Recover {1} HP", [_pre, _a])
			}
			if _spell.stage == 2 {
				var _a = _ic ? string(QueryDice(player,"mercury","highest"))  : "Highest Mercury"
				var _b = _ic ? string(QueryDice(player,"mercury","affinity")) : "Mercury Count"
				return string_ext("{0}Recover {1} + {2} HP", [_pre, _a, _b])
			}
			var _a = _ic ? string(QueryDice(player,"all","charge") * 2)      : "2x All Charge"
			var _b = _ic ? string(QueryDice(player,"mercury","affinity"))     : "Mercury Count"
			return string_ext("{0}Recover {1} + {2} HP", [_pre, _a, _b])

		case "Aegis":
			if prev.description == "DEF+" { return string_ext("{0}Grant DEF Up", [_pre]) }
			return string_ext("{0}Grant DEF Up. Inflict ATK Down if Charges Remain.", [_pre])
		case "Miracle":
			var _v = string(QueryDice(player,"venus","charge"))
			var _ma = string(QueryDice(player,"mars","charge"))
			var _j = string(QueryDice(player,"jupiter","charge"))
			var _me = string(QueryDice(player,"mercury","charge"))
			return string_ext("[Self] +{0} DEF\n{1}{2} Mars Damage\n[{3}] Inflict Random Status\n[Range 1 Ally] Recover {4}", [_v,_pre,_ma,_j,_me])

		default: return _spell.text
	}
}

// ─── Djinn ───────────────────────────────────────────────────────────────────
// Available locals: _djinn, _tgt, prev (CalcPreview result)
// Weapon Attack Damage = WeaponAttack(false,false) — no unleash
// Weapon Attack        = WeaponAttack(true,false)  — with unleash

function _BVD_Djinn(action_id, player, prev) {
	var _djinn = global.djinnlist[action_id]
	if _djinn.spent { return "Set " + _djinn.name + " to Ready" }

	var _ic    = global.inCombat
	var _echo  = CheckPassive("_DjinnEcho")
	var _range = (_echo != undefined) ? 3 : 1
	var _pre   = "[Range " + string(_range) + "] "
	var _tgt   = _BVD_TargetStr("Other", prev.targets, _range)
	var _e     = _djinn.element

	switch _djinn.name {

		// ── All-charge damage ────────────────────────────────────────────
		case "Bane": case "Fever": case "Wheeze": case "Mist":
		case "Char": case "Smog": case "Blitz": case "Squall":
		case "Hail": case "Sleet": case "Chill": case "Fugue":
			var _a = _ic ? string(QueryDice(player,"all","charge")) : "All Charges"
			return string_ext("{0}" + _e + " Damage // {1}", [_pre, _a])

		case "Shine":
			var _a = _ic ? string(QueryDice(player,"all","charge")) : "All Charges"
			return string_ext("{0}" + _e + " Damage // {1}. Spreads Statuses.", [_pre, _a])

		case "Fury":
			var _a = _ic ? string(QueryDice(player,"all","charge")) : "All Charges"
			return string_ext("{0}" + _e + " Damage // {1}. Ignores Defense.", [_pre, _a])

		// ── Weapon-based damage ──────────────────────────────────────────
		case "Flint": case "Cannon": case "Sour":
			var _a = _ic ? string(WeaponAttack(false,false).dam) : "Weapon Attack Damage"
			return string_ext("{0}" + _e + " Damage // {1} + {1}x0.5", [_pre, _a])

		case "Sap":
			var _a = _ic ? string(WeaponAttack(true,false).dam) : "Weapon Attack"
			return string_ext("{0}" + _e + " Damage // {1}", [_pre, _a])

		case "Geode":
			var _a = _ic ? string(WeaponAttack(true,false).dam)  : "Weapon Attack"
			var _b = _ic ? string(WeaponAttack(false,false).dam) : "Weapon Attack Damage"
			return string_ext("{0}" + _e + " Damage // {1} + {2}", [_pre, _a, _b])

		case "Torch": case "Scorch":
			var _a = _ic ? string(WeaponAttack(false,false).dam) : "Weapon Attack Damage"
			return string_ext("{0}" + _e + " Damage // {1}", [_pre, _a])

		case "Gel":
			var _a = _ic ? string(WeaponAttack(true,false).dam)               : "Weapon Attack"
			var _b = _ic ? string(WeaponAttack(true,false).unleash.dam_bonus) : "Unleash Bonus"
			return string_ext("{0}" + _e + " Damage // {1} + {2}", [_pre, _a, _b])

		case "Serac": case "Whorl":
			var _a = _ic ? string(WeaponAttack(false,false).dam) : "Weapon Attack Damage"
			return string_ext("{0}" + _e + " Damage // {1}", [_pre, _a])

		case "Echo":
			var _a = _ic ? string(WeaponAttack(false,false).dam)              : "Weapon Attack Damage"
			var _b = _ic ? string(WeaponAttack(true,false).unleash.dam_bonus) : "Unleash Bonus"
			return string_ext("{0}" + _e + " Damage // {1} + {2}x2", [_pre, _a, _b])

		case "Core":
			var _a = _ic ? string(WeaponAttack(true,false).dam) : "Weapon Attack"
			return string_ext("{0}" + _e + " Damage // {1}", [_pre, _a])

		case "Gust":
			var _a = _ic ? string(WeaponAttack(false,false).dam) : "Weapon Attack Damage"
			return string_ext("{0}" + _e + " Damage // {1}", [_pre, _a])

		// ── Healing (all allies) ─────────────────────────────────────────
		case "Spritz":
			var _a = _ic ? string(prev.heal) : "Elemental Charge"
			return string_ext("{0}Recover {1} HP", [_pre, _a, _tgt])

		case "Balm":
			var _a = _ic ? string(prev.heal) : "50% Max HP"
			return string_ext("{0}Recover {1} HP", [_pre, _a, _tgt])

		case "Crystal":
			var _a = _ic ? string(QueryDice(player,"elemental","charge")) : "Elemental Charge"
			var _b = _ic ? string(player.def + player.defmod)             : "DEF"
			return string_ext("{0}Recover {1} + {2} HP", [_pre, _a, _b, _tgt])
		case "Steel":
			var _a = _ic ? string(WeaponAttack(true,false).dam) : "Weapon Attack"
			var _b = _ic ? "and recover " + string(WeaponAttack(true,false).dam_bonus) + " HP"             : "Unleash damage converted to healing"
			return string_ext("{0}{1} {2}", [_pre, _a, _b, _tgt])

		// ── Healing (single) ─────────────────────────────────────────────
		case "Spring": case "Breath":
			var _a = _ic ? string(prev.heal) : "All Charges"
			return string_ext("{0}Recover {1} HP", [_pre, _a, _tgt])

		case "Fizz":
			return string_ext("{0}Recover 50% HP", [_pre, _tgt])

		// ── PP recovery ──────────────────────────────────────────────────
		case "Ember":
			var _a = _ic ? string(prev.heal) : "Mars Charge"
			return string_ext("{0}Restore {1} PP", [_pre, _a, _tgt])

		case "Aroma":
			var _a = _ic ? string(prev.heal) : "Elemental Charge"
			return string_ext("{0}Restore {1} PP", [_pre, _a, _tgt])

		case "Ether":
			var _a = _ic ? string(prev.heal) : "All Charges"
			return string_ext("{0}Restore {1} PP", [_pre, _a, _tgt])
		case "Reflux":
			var _a = _ic ? string(player.atk) : "ATK"
			return string_ext("[Self] Attackers take {1}", [_pre, _a, _tgt])

		// ── Revive ───────────────────────────────────────────────────────
		case "Quartz": return string_ext("{0}Revive {1} (50% Max HP)", [_pre, _tgt])
		case "Dew":    return string_ext("{0}Revive {1} (Full HP)", [_pre, _tgt])
		case "Spark":  return string_ext("{0}Revive {1} (1 HP)", [_pre, _tgt])
		case "Tinder":
			var _a = _ic ? string(prev.heal) : "Mars Count"
			return string_ext("{0}Revive {1} ({2} HP)", [_pre, _tgt, _a])

		// ── Stat buffs ───────────────────────────────────────────────────
		case "Forge":                return string_ext("{0}Increase ATK", [_pre, _tgt])
		case "Iron":                 return string_ext("{0}Increase DEF", [_pre, _tgt])
		case "Corona": case "Breeze": return string_ext("{0}Increase DEF", [_pre, _tgt])

		// ── Status infliction ────────────────────────────────────────────
		case "Luff": case "Rime":  return string_ext("{0}Inflict Psy Seal", [_pre, _tgt])
		case "Fog":                return string_ext("{0}Inflict Delude", [_pre, _tgt])
		case "Waft":               return string_ext("{0}Inflict Sleep", [_pre, _tgt])
		case "Gasp":               return string_ext("{0}Inflict Haunt", [_pre, _tgt])

		// ── Status cure ──────────────────────────────────────────────────
		case "Tonic": return string_ext("{0}Clear bad tokens", [_pre, _tgt])
		case "Salt":  return string_ext("{0}Clear all tokens", [_pre, _tgt])

		// ── Passives / utility ───────────────────────────────────────────
		case "Shade": case "Granite": return string_ext("[Passive] Reduce Damage Taken by 50%", [])
		case "Flash":    return string_ext("[Passive] Cap incoming damage to a max of 1", [_pre, _tgt])
		case "Ground":   return string_ext("[Passive] Skip next Enemy Turn", [_pre])
		case "Mud":      return string_ext("[Passive] Reduce enemy skill choice by 1 (3 rounds)", [_pre])
		case "Vine":     return string_ext("[Passive] All enemy attempts to inflict status fail (3 rounds)", [_pre])
		case "Steam":    return string_ext("[Passive] Increase Elemental Power", [_pre])
		case "Kindle":   return string_ext("[Passive] Increase Melee Power", [_pre])
		case "Coal":     return string_ext("{0}Gain 1 Partial Reroll until end of turn", [_pre, _tgt])
		case "Zephyr":   return string_ext("{0}Gain 1 Reroll", [_pre, _tgt])
		case "Lull":     return string_ext("[Instant] Start over combat order", [_pre, _tgt])
		case "Haze":     return string_ext("{0}Immune to damage and effects (1 round)", [_pre, _tgt])
		case "Flower":   return string_ext("{0}Assign Venus Dice", [_pre, _tgt])
		case "Petra":    return string_ext("[Passive] Reroll an enemy move (3 rounds)", [_pre, _tgt])
		case "Gale":     return string_ext("{0}50% to down instantly", [_pre, _tgt])

		default: return _djinn.text
	}
}

// ─── Item ────────────────────────────────────────────────────────────────────
// Available locals: _item, _tgt, prev (CalcPreview result)

function _BVD_Item(action_id, player, prev) {
	var _item = global.itemcardlist[action_id]
	var _tgt  = _BVD_TargetStr("Ally", prev.targets, 1)

	switch _item.name {
		case "Herb":          return string_ext("{0} HP Heal", [string(prev.heal), _tgt])
		case "Nut":           return string_ext("{0} HP Heal", [string(prev.heal), _tgt])
		case "Vial":          return string_ext("{0} HP Heal", [string(prev.heal), _tgt])
		case "Potion":        return string_ext("{0} HP Heal", [string(prev.heal), _tgt])
		case "Psy Crystal":   return string_ext("+3 PP", [_tgt])
		case "Water of Life": return string_ext("Revive {0} (Full HP)", [_tgt])
		case "Mist Potion":   return string_ext("100% HP Heal", [_tgt])
		case "Oil Drop":
			var _a = global.inCombat ? string(prev.dam) : "Elemental Charge + 1"
			return string_ext("{0} Mars Damage", [_a])
		case "Bramble Seed":
			var _a = global.inCombat ? string(prev.dam) : "Elemental Charge + 1"
			return string_ext("{0} Venus Damages", [_a])
		case "Crystal Powder":
			var _a = global.inCombat ? string(prev.dam) : "Elemental Charge + 1"
			return string_ext("{0} Mercury Damage", [_a])
		case "Weasel's Claw":
			var _a = global.inCombat ? string(prev.dam) : "Elemental Charge + 1"
			return string_ext("{0} Jupiter Damage", [_a])
		case "Smoke Bomb": return "Inflict Delude"
		case "Sleep Bomb": return "Inflict Sleep"
		default:           return ""
	}
}

// ─── Shared helpers ──────────────────────────────────────────────────────────

/// Returns target string: "1 Opponent", "3 Opponents", "All Allies", "Self", etc.
/// tgt_type is the spell's targetType field; tgt_category is CalcPreview.targets;
/// range is the numeric count (already boosted by Resonate if applicable).
function _BVD_TargetStr(tgt_type, tgt_category, range) {
	switch tgt_category {
		case "All Allies":  return "All Allies"
		case "All Enemies": return "All Enemies"
		case "Self":        return "Self"
	}
	if tgt_type == "Self"  { return "Self" }
	if tgt_type == "Ally"  { return (range == 1) ? "1 Ally"     : string(range) + " Allies" }
	return (range == 1) ? "1 Opponent" : string(range) + " Opponents"
}
