/// @function ExhaustSummonDjinn(summonID)
/// @desc Put required djinn into recovery for a given summon
function ExhaustSummonDjinn(summonID) {
	global.justSummoned = true
	var summon = global.summonlist[summonID]
	var elements = ["Venus", "Mars", "Jupiter", "Mercury"]
	var costs = [summon.venus, summon.mars, summon.jupiter, summon.mercury]
	for (var e = 0; e < 4; e++){
		var count = costs[e]
		if count <= 0 { continue }

		var eligible = []
		for (var p = 0; p < array_length(global.players); p++){
			var pl = global.players[p]
			if variable_struct_exists(pl, "djinn"){
				for (var d = 0; d < array_length(pl.djinn); d++){
					var djinn = global.djinnlist[pl.djinn[d]]
					if (djinn.ready or djinn.spent) and djinn.element == elements[e]{
						array_push(eligible, pl.djinn[d])
					}
				}
			}
		}

		eligible = array_shuffle(eligible)
		for (var k = 0; k < count; k++){
			global.djinnlist[eligible[k]].ready = false
			global.djinnlist[eligible[k]].spent = false
			global.djinnlist[eligible[k]].just_unleashed = true
		}
	}
	CreateDicePool()
}

function CastSummon(summonID, playerID){
	var summon = global.summonlist[summonID]
	var caster = global.players[playerID]
	var _struct = variable_clone(global.AggressionSchema)
	_struct.source = "summon"

	// ── Splash sprite — each case can override _splash below ───────────
	_struct.splash = asset_get_index(summon.alias)
	// Whether to defer splash until after targeting confirms
	var _defer_splash = false
	// Whether to defer djinn exhaustion (four-cost summons)
	var _defer_djinn = false

	// ── Pre-calculate weapon attack (used by several summons) ───────────
	var weapon_type   = global.itemcardlist[caster.weapon].type
	var weapon_subset = (weapon_type == "Staff") ? "melee" : "all"
	var weapon_atk    = QueryDice(caster, weapon_subset, "charge") + caster.atk + caster.atkmod

	// ── Calculate effect based on summon name ───────────────────────────
	_struct.dam     = 0
	_struct.num     = summon.range
	_struct.element = summon.element
	_struct.statuses = {}
	var _handled = false

	switch (summon.name) {

		// ── Zagan: weapon attack + target & neighbors -3 DEF ────────────
		case "Zagan":
			_struct.splash = Zagan2
			_defer_splash = true
			_struct.dam = weapon_atk
			_struct.statuses = { inflict_defdown: 3 }
			break

		// ── Megaera: 2× weapon attack (separate targets) + party +3 ATK ─
		case "Megaera":
			_struct.splash = Megaera1122

			// Party ATK buff
			AddPassive("party_atk", 3, asset_get_index(summon.alias), "Megaera", {amount: 0}, playerID)
			for (var _me = 0; _me < array_length(global.players); _me++) {
				if (global.players[_me].hp > 0) {
					global.players[_me].atkmod += 3
				}
			}
			caster.atkmod_fresh = true
			InjectLog("Party ATK increased by 3!")
			global.attackQueue = [WeaponAttack(true,false,Megaera1122),WeaponAttack(true,false,Megaera1122)]
			DestroyAllBut()
			ClearOptions()
			DeleteButtons()
			ProcessAttackQueue()
			_handled = true
			ExhaustSummonDjinn(summonID)
			exit
			break

		// ── Flora: total Jupiter affinity of ALL characters + sleep ────
		case "Flora":
			_struct.splash = Flora1115
			_struct.dam = 0
			for (var _fp = 0; _fp < array_length(global.players); _fp++) {
				if (global.players[_fp].hp > 0) {
					_struct.dam += global.players[_fp].jupiter
				}
			}
			_struct.statuses = { inflict_sleep: true }
			break

		// ── Catastrophe: weapon attack all enemies ─────────────────────
		case "Catastrophe":
			_struct.dam = WeaponAttack(true,false).dam
			_struct.num = 12
			break

		// ── Azul: elemental affinity to all + stun ─────────────────────
		case "Azul":
			_struct.splash = Azul1104
			_struct.dam = QueryDice(caster, "elemental", "affinity")
			_struct.statuses = { inflict_stun: true }
			break

		// ── Haures: poison all + poison does 2 damage ──────────────────
		case "Haures":
			_struct.splash = Haures1116
			_struct.dam = 0
			_struct.statuses = { inflict_poison: true }
			_struct.num = 12
			var _haures_data = { amount: 2 }
			AddPassive("poison_buff", -1, asset_get_index(summon.alias), "Haures", _haures_data, playerID)
			InjectLog("Poison will now deal 2 damage!")
			break

		// ── Coatlicue: heal all to full + 5-round regen ────────────────
		case "Coatlicue":
			_struct.splash = Coatlicue1111
			for (var _p = 0; _p < array_length(global.players); _p++) {
				if (global.players[_p].hp > 0) {
					var _coat_heal = global.players[_p].hpmax - global.players[_p].hp
					if (global.players[_p].halfheal and _coat_heal > 0) { _coat_heal = floor(_coat_heal / 2) }
					global.players[_p].hp = min(global.players[_p].hp + _coat_heal, global.players[_p].hpmax)
				}
			}
			InjectLog("All allies recovered HP!")
			var _coat_data = { amount: 5 }
			AddPassive("regen", 5, asset_get_index(summon.alias), "Coatlicue", _coat_data, playerID)
			instance_destroy(objSummonMenu)
			global.pause = false
			instance_create_depth(0, 0, 0, TurnDelay, {wait: 30})
			_handled = true
			break

		// ── Ulysses: skip 2 enemy turns OR 3 boss turns (boss encounter only) ─
		case "Ulysses":
			_struct.splash = Ulysses1132
			var _has_boss = false
			var _mc = instance_number(objMonster)
			for (var _mi = 0; _mi < _mc; _mi++) {
				if (instance_find(objMonster, _mi).boss == 1) { _has_boss = true; break }
			}
			var _uly_data = {}
			if (_has_boss) {
				AddPassive("skip_bosses", 3, asset_get_index(summon.alias), "Ulysses", _uly_data, playerID)
				InjectLog("Bosses lose turns!")
			} else {
				AddPassive("skip_enemies", 2, asset_get_index(summon.alias), "Ulysses", _uly_data, playerID)
				InjectLog("Enemies can't move!")
			}
			instance_destroy(objSummonMenu)
			global.pause = false
			instance_create_depth(0, 0, 0, TurnDelay, {wait: 30})
			_handled = true
			break

		// ── Iris: heal all + damage cap 1 round + damage half 2 rounds ─
		case "Iris":
			_struct.splash = Iris1117
			for (var _p = 0; _p < array_length(global.players); _p++) {
				if (global.players[_p].hp > 0) {
					var _coat_heal = global.players[_p].hpmax - global.players[_p].hp
					if (global.players[_p].halfheal and _coat_heal > 0) { _coat_heal = floor(_coat_heal / 2) }
					global.players[_p].hp = min(global.players[_p].hp + _coat_heal, global.players[_p].hpmax)
				}
			}
			InjectLog("All allies healed to full!")
			AddPassive("damage_cap_1", 1, asset_get_index(summon.alias), "Iris", {}, playerID)
			AddPassive("damage_half", 2, asset_get_index(summon.alias), "Iris", {}, playerID)
			InjectLog("Party shielded from damage!")
			instance_destroy(objSummonMenu)
			global.pause = false
			instance_create_depth(0, 0, 0, TurnDelay, {wait: 30})
			_handled = true
			break

		// ── Charon: pair-cost instant-kill ──────────────────────────────
		case "Charon":
			instance_destroy(objSummonMenu)
			global.pause = true
			instance_create_depth(0, 0, 0, objCharonPicker, _struct)
			ExhaustSummonDjinn(summonID)
			exit
			break

		// ── Four-cost spell emulators ───────────────────────────────────
		case "Judgment":
			_struct.splash = Judgment1118
			_defer_djinn = true
			global.summonSpellPick = { name: summon.name, element: summon.element, playerID: playerID, summonID: summonID, splash: _struct.splash }
			instance_destroy(objSummonMenu)
			global.pause = true
			instance_create_depth(0, 0, 0, objSummonSpellPicker, global.summonSpellPick)
			_handled = true
			exit
			break
		case "Meteor":
			_struct.splash = Meteor1123
			_defer_djinn = true
			global.summonSpellPick = { name: summon.name, element: summon.element, playerID: playerID, summonID: summonID, splash: _struct.splash }
			instance_destroy(objSummonMenu)
			global.pause = true
			instance_create_depth(0, 0, 0, objSummonSpellPicker, global.summonSpellPick)
			_handled = true
			exit
			break
		case "Thor":
			_struct.splash = Thor1130
			_defer_djinn = true
			global.summonSpellPick = { name: summon.name, element: summon.element, playerID: playerID, summonID: summonID, splash: _struct.splash }
			instance_destroy(objSummonMenu)
			global.pause = true
			instance_create_depth(0, 0, 0, objSummonSpellPicker, global.summonSpellPick)
			_handled = true
			exit
			break
		case "Boreas":
			_struct.splash = Boreas1105
			_defer_djinn = true
			global.summonSpellPick = { name: summon.name, element: summon.element, playerID: playerID, summonID: summonID, splash: _struct.splash }
			instance_destroy(objSummonMenu)
			global.pause = true
			instance_create_depth(0, 0, 0, objSummonSpellPicker, global.summonSpellPick)
			_handled = true
			exit
			break

		// ── Moloch: pick a number to nullify on enemy move lists ───────
		case "Moloch":
			_struct.splash = Moloch1124
			instance_destroy(objSummonMenu)
			global.pause = true
			instance_create_depth(0, 0, 0, objMolochPicker, {source: "summon", caster_id: playerID})
			_handled = true
			ExhaustSummonDjinn(summonID)
			exit
			break

		// ── Eclipse: half max HP to enemies (10% to bosses) + delude all ─
		case "Eclipse":
			_struct.splash = Eclipse1114
			var _mon_count = instance_number(objMonster)
			for (var _m = 0; _m < _mon_count; _m++) {
				var _mon = instance_find(objMonster, _m)
				if (_mon.monsterHealth <= 0) { continue }
				var _eclipse_dam = 0
				if (_mon.boss == 1) {
					_eclipse_dam = max(1, ceil(_mon.maxhp * 0.1))
				} else {
					_eclipse_dam = max(1, ceil(_mon.maxhp * 0.5))
				}
				_mon.monsterHealth -= _eclipse_dam
				_mon.flash_timer = 8
				if (_mon.monsterHealth <= 0) {
					_mon.monsterHealth = 0
					global.gold += 1
				}
				InjectLog(_mon.name + " takes " + string(_eclipse_dam) + " Jupiter damage!")
				if (_mon.monsterHealth > 0) {
					_mon.delude = true
					InjectLog(_mon.name + " is deluded!")
				}
			}
			// Check victory
			var _any_alive = false
			for (var _m = 0; _m < _mon_count; _m++) {
				if (instance_find(objMonster, _m).monsterHealth != 0) { _any_alive = true; break }
			}
			instance_destroy(objSummonMenu)
			if (!_any_alive and _mon_count > 0) {
				InjectLog("Combat Victory!")
				global.firstPlayer = global.turn
				global.inCombat = false
				global.pause = false
				CombatCleanup()
				ClearOptions()
				instance_create_depth(0, 0, -10, objPostBattle)
			} else {
				global.pause = false
				instance_create_depth(0, 0, 0, TurnDelay, {wait: 30})
			}
			_handled = true
			break

		// ── Daedalus: all dice values to target, cascade half to neighbors ─
		case "Daedalus":
			_struct.splash = Daedalus1113
			_defer_splash = true
			_struct.dam = QueryDice(caster, "all", "values")
			global.daedalusCascade = true
			break

		default:
			show_debug_message("CastSummon: '" + summon.name + "' has no implementation yet")
			instance_destroy(objSummonMenu)
			global.pause = false
			_handled = true
			break
	}

	// Exhaust djinn now unless deferred (four-cost summons defer until spell confirm)
	if !_defer_djinn {
		ExhaustSummonDjinn(summonID)
	}

	// Show splash (unless deferred for targeting summons or four-cost)
	if !_defer_splash and !_defer_djinn and _struct.splash != -1 {
		instance_create_depth(0, 0, -100, objSummonSplash, { spr: _struct.splash })
	}

	if (_handled) { exit }

	// ── Dispatch (targeting summons) ────────────────────────────────────
	// Store splash for objMonsterTarget to show on confirm
	
	instance_destroy(objSummonMenu)
	DeleteButtons()
	global.pause = false

	if (_struct.num > 0) {
		SelectTargets(_struct)
	} else {
		instance_create_depth(0, 0, 0, TurnDelay, {wait: 30})
	}
}



