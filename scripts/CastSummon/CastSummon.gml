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
			global.pendingAnim = [
				{ type: "meteor", element: "venus", fires_hit: false, speed: 5, accel: 0.3, trail: 0, impact_foot: true, shake: 5, shake_duration: 15, linger: 5,
					sub: [{ type: "burst", at: "hit", count: 20, max_speed: 3, max_scale: 2, trail: 0 }] },
				{ type: "pillar", element: "venus", fires_hit: true, hold: 25, shake: 3, shake_duration: 10, target_splash: "splash" },
				{ type: "fire", element: "venus", fires_hit: false, rate: 2, width: 0.3, life: 20, life_var: 10, hold: 30, linger: 15, trail: 0 }
			]
			break

		// ── Megaera: 2× weapon attack (separate targets) + party +3 ATK ─
		case "Megaera":
			_struct.splash = Megaera1122

			var _meg_burst = [{ type: "burst", element: "mars", fires_hit: true, count: 30, max_speed: 4, max_scale: 2, trail: 0 }]
			var _meg1 = WeaponAttack(true,false,Megaera1122)
			var _meg2 = WeaponAttack(true,false,Megaera1122)
			_meg1.anim = _meg_burst
			_meg2.anim = _meg_burst
			var _meg_buff = { callback: method({ pid: playerID, sid: summonID, alias: summon.alias }, function() {
				AddPassive("party_atk", 3, asset_get_index(alias), "Megaera", {amount: 0}, pid)
				for (var _me = 0; _me < array_length(global.players); _me++) {
					if (global.players[_me].hp > 0) {
						global.players[_me].atkmod += 3
					}
				}
				global.players[pid].atkmod_fresh = true
				InjectLog("Party ATK increased by 3!")
				instance_create_depth(0, 0, 500, objSummonSplash, { spr: Megaera1122 })
				MakeTurnDelay(30, NextTurn)
			}) }
			global.attackQueue = [_meg1, _meg2, _meg_buff]
			
			
			
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
			global.pendingAnim = [{ type: "drizzle", element: "jupiter", color: #ff69b4, fires_hit: true, single_anim: true,
				hit_delay: 100, hold: 140, linger: 50, rate: 2, drop_scale: 0.1, drop_speed: 0.1, spread: 8, scl: 1, scl_var: 0, grav: 0.01, wiggle: 0.3, wiggle_spd: 0.08, life: 120, life_var: 30 }]
			break

		// ── Catastrophe: weapon attack all enemies ─────────────────────
		case "Catastrophe":
			_struct.dam = WeaponAttack(true,false).dam
			_struct.num = 12
			global.pendingAnim = [
				{ type: "flash", element: "jupiter", fires_hit: true, hold: 10, stagger_damage: true, stagger: 15 }
			]
			break

		// ── Azul: elemental affinity to all + stun ─────────────────────
		case "Azul":
			_struct.splash = Azul1104
			_struct.dam = QueryDice(caster, "elemental", "affinity")
			_struct.statuses = { inflict_stun: true }
			_struct.num = 12
			global.pendingAnim = [
				{ type: "fire", element: "mercury", fires_hit: true, target_all: true,
				  screen_tint: AnimColor("mercury"), screen_tint_alpha: 0.4, screen_tint_hold: 9999,
				  rate: 1, width: 0.4, life: 15, life_var: 10, hold: 100, linger: 20, trail: 0, hit_delay: 50 }
			]
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
			global.pendingAnim = [
				{ type: "cloud", element: "venus", color: #4B0082, fires_hit: true, target_all: true, hold: 120, cloud_hold: 100, linger: 30, hit_delay: 50, height: 0.5, scl: 5, scl_var: 3, count: 400, alpha: 0.95, spawn: 40, vert_spread: 30, hit_tint: c_black, hit_tint_duration: 40 }
			]
			break

		// ── Coatlicue: heal all to full + 5-round regen ────────────────
		case "Coatlicue":
			_struct.splash = Coatlicue1111
			for (var _p = 0; _p < array_length(global.players); _p++) {
				
					var _coat_heal = global.players[_p].hpmax - global.players[_p].hp
					if (global.players[_p].halfheal and _coat_heal > 0) { _coat_heal = floor(_coat_heal / 2) }
					global.players[_p].hp = min(global.players[_p].hp + _coat_heal, global.players[_p].hpmax)
				
			}
			InjectLog("All allies recovered HP!")
			var _coat_data = { amount: 5 }
			AddPassive("regen", 5, asset_get_index(summon.alias), "Coatlicue", _coat_data, playerID)
			instance_create_depth(0, 0, 0, TurnDelay, {wait: 30, on_complete: NextTurn})
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
			instance_create_depth(0, 0, 0, TurnDelay, {wait: 30, on_complete: NextTurn})
			_handled = true
			break

		// ── Iris: heal all + damage cap 1 round + damage half 2 rounds ─
		case "Iris":
			_struct.splash = Iris1117
			for (var _p = 0; _p < array_length(global.players); _p++) {
				
					var _coat_heal = global.players[_p].hpmax - global.players[_p].hp
					if (global.players[_p].halfheal and _coat_heal > 0) { _coat_heal = floor(_coat_heal / 2) }
					global.players[_p].hp = min(global.players[_p].hp + _coat_heal, global.players[_p].hpmax)
				}
			
			InjectLog("All allies healed to full!")
			AddPassive("damage_cap_1", 1, asset_get_index(summon.alias), "Iris", {}, playerID)
			AddPassive("damage_half", 2, asset_get_index(summon.alias), "Iris", {}, playerID)
			InjectLog("Party shielded from damage!")
			instance_create_depth(0, 0, 0, TurnDelay, {wait: 30, on_complete: NextTurn})
			_handled = true
			break

		// ── Charon: pair-cost instant-kill ──────────────────────────────
		case "Charon":
			_struct.splash = Charon1110
			// Count ready djinn
			var _charon_ready = 0
			for (var _cp = 0; _cp < array_length(global.players); _cp++) {
				var _cpl = global.players[_cp]
				if variable_struct_exists(_cpl, "djinn") {
					for (var _cd = 0; _cd < array_length(_cpl.djinn); _cd++) {
						var _cdj = global.djinnlist[_cpl.djinn[_cd]]
						if (_cdj.ready or _cdj.spent) { _charon_ready++ }
					}
				}
			}
			// Count eligible (non-boss) targets
			var _charon_eligible = 0
			var _cmc = instance_number(objMonster)
			for (var _ci = 0; _ci < _cmc; _ci++) {
				var _cinst = instance_find(objMonster, _ci)
				if _cinst.monsterHealth > 0 and !_cinst.boss { _charon_eligible++ }
			}
			var _charon_max = min(floor(_charon_ready / 2), _charon_eligible)
			if _charon_max <= 0 {
				InjectLog("No valid targets for Charon!")
				instance_create_depth(0, 0, 0, TurnDelay, {wait: 30, on_complete: NextTurn})
				_handled = true
				break
			}
			_handled = true
			ExhaustSummonDjinn(summonID)
			PushMenu(objMenuSlider, {
				minim: 1, maxim: _charon_max, value: 1,
				confirm_label: "Reap",
				label: function(v) { return "Djinn to spend: " + string(v * 2) },
				preview: function(v) { return "Targets to reap: " + string(v) },
				on_confirm: method({ sid: summonID }, function(v) {
					// Spend v*2 random ready djinn
					var _spent = 0
					var _needed = v * 2
					for (var _p = 0; _p < array_length(global.players); _p++) {
						var _pl = global.players[_p]
						if !variable_struct_exists(_pl, "djinn") { continue }
						for (var _d = 0; _d < array_length(_pl.djinn); _d++) {
							if _spent >= _needed { break }
							var _dj = global.djinnlist[_pl.djinn[_d]]
							if (_dj.ready or _dj.spent) {
								_dj.ready = false
								_dj.spent = false
								global.justSummoned = true
								_spent++
							}
						}
						if _spent >= _needed { break }
					}
					InjectLog("Charon consumes " + string(_spent) + " djinn!")
					// Queue instant-kill targeters
					for (var _k = 0; _k < v; _k++) {
						var _s = variable_clone(global.AggressionSchema)
						_s.dam     = 9999
						_s.target  = "enemy"
						_s.num     = 1
						_s.source  = "summon"
						_s.dmgtype = "none"
						_s.splash  = (_k == 0) ? Charon1110 : -1
						_s.anim    = [{ type: "cloud", element: "jupiter", color: #4B0082, fires_hit: true, hold: 20, linger: 15, hit_delay: 10, count: 50 }]
						array_push(global.attackQueue, _s)
					}
					PopMenu()
					ProcessAttackQueue()
				}),
			})
			exit
			break

		// ── Four-cost spell emulators ───────────────────────────────────
		case "Judgment":
			_struct.splash = Judgment1118
			_defer_djinn = true
			global.summonSpellPick = { name: summon.name, element: summon.element, playerID: playerID, summonID: summonID, splash: _struct.splash }
			_PushSummonSpellMenu(global.summonSpellPick)
			_handled = true
			exit
			break
		case "Meteor":
			_struct.splash = Meteor1123
			_defer_djinn = true
			global.summonSpellPick = { name: summon.name, element: summon.element, playerID: playerID, summonID: summonID, splash: _struct.splash }
			_PushSummonSpellMenu(global.summonSpellPick)
			_handled = true
			exit
			break
		case "Thor":
			_struct.splash = Thor1130
			_defer_djinn = true
			global.summonSpellPick = { name: summon.name, element: summon.element, playerID: playerID, summonID: summonID, splash: _struct.splash }
			_PushSummonSpellMenu(global.summonSpellPick)
			_handled = true
			exit
			break
		case "Boreas":
			_struct.splash = Boreas1105
			_defer_djinn = true
			global.summonSpellPick = { name: summon.name, element: summon.element, playerID: playerID, summonID: summonID, splash: _struct.splash }
			_PushSummonSpellMenu(global.summonSpellPick)
			_handled = true
			exit
			break

		// ── Moloch: pick a number to nullify on enemy move lists ───────
		case "Moloch":
			_struct.splash = Moloch1124
			_handled = true
			ExhaustSummonDjinn(summonID)
			// Freeze all enemies: greyscale + damage frame for ~2 seconds
			var _mol_count = instance_number(objMonster)
			for (var _mi = 0; _mi < _mol_count; _mi++) {
				var _mon = instance_find(objMonster, _mi)
				if _mon.monsterHealth > 0 {
					_mon.damage_timer = 120
					_mon.frozen = 1
					_mon.image_speed = 0
				}
			}
			// Open slider after a brief pause
			instance_create_depth(0, 0, 0, TurnDelay, { wait: 30, on_complete: method({ pid: playerID }, function() {
				PushMenu(objMenuSlider, {
					minim: 1, maxim: 20, value: 1,
					confirm_label: "Nullify",
					label: function(v) { return "Nullify enemy move #" + string(v) },
					on_confirm: method({ pid: pid }, function(v) {
						AddPassive("nullify_move", -1, asset_get_index("Moloch"), "Moloch", { number: v }, pid)
						InjectLog("Moloch nullifies enemy move #" + string(v) + "!")
						// Unfreeze all enemies
						var _mc = instance_number(objMonster)
						for (var _m = 0; _m < _mc; _m++) {
							var _mon = instance_find(objMonster, _m)
							_mon.frozen = 0
							_mon.image_speed = 1
							_mon.damage_timer = 0
						}
						PopMenu()
						NextTurn()
					}),
				})
			}) })
			exit
			break

		// ── Eclipse: half max HP to enemies (10% to bosses) + delude all ─
		case "Eclipse":
			_struct.splash = Eclipse1114
			// Build animation: black screen tint → white pillars with fire on all enemies
			var _ecl_monsters = []
			var _ecl_count = instance_number(objMonster)
			for (var _m = 0; _m < _ecl_count; _m++) {
				var _mon = instance_find(objMonster, _m)
				if (_mon.monsterHealth > 0) { array_push(_ecl_monsters, _mon) }
			}
			// Queue: sustained black flash, then white pillars + fire
			QueueAnim("flash", "jupiter", _ecl_monsters[0], {
				type: "flash", element: "jupiter", target: _ecl_monsters[0],
				color: c_black, fires_hit: false, hold: 60, peak: 10, alpha: 0.6, sustain: true, blend: "normal"
			})
			for (var _em = 0; _em < array_length(_ecl_monsters); _em++) {
				QueueAnim("pillar", "jupiter", _ecl_monsters[_em], {
					type: "pillar", element: "jupiter", target: _ecl_monsters[_em],
					color: c_white, fires_hit: (_em == 0), hit_delay: 10,
					outer_w: 24, core_w: 14,
					hold: 30, fade: 20, linger: 10,
					fire_overlay: true, fire_rate: 2, fire_w: 20,
					shake: 0
				})
			}
			// On hit: apply damage
			var _ecl_on_hit = method({ mons: _ecl_monsters }, function() {
				ScreenShake(6, 15)
				for (var _m = 0; _m < array_length(mons); _m++) {
					var _mon = mons[_m]
					if (_mon.monsterHealth <= 0) { continue }
					var _eclipse_dam = 0
					if (_mon.boss == 1) {
						_eclipse_dam = max(1, ceil(_mon.maxhp * 0.1))
					} else {
						_eclipse_dam = max(1, ceil(_mon.maxhp * 0.5))
					}
					_mon.monsterHealth -= _eclipse_dam
					_mon.flash_timer = FLASH_DURATION; _mon.damage_timer = DAMAGE_DURATION; _mon.flash_color = ElementColor("jupiter")
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
			})
			// On complete: check victory + next turn
			var _ecl_resolve = function() {
				CheckVictory()
				MakeTurnDelay(20, NextTurn)
			}
			PlayAnimation(_ecl_on_hit, _ecl_resolve)
			_handled = true
			break

		// ── Daedalus: all dice values to target, cascade half to neighbors ─
		case "Daedalus":
			_struct.splash = Daedalus1113
			_defer_splash = true
			_struct.dam = QueryDice(caster, "all", "values")
			_struct.num = 1
			global.daedalusCascade = true
			global.daedalusAnim = true
			break

		default:
			show_debug_message("CastSummon: '" + summon.name + "' has no implementation yet")
			_handled = true
			break
	}

	// Exhaust djinn now unless deferred (four-cost summons defer until spell confirm)
	if !_defer_djinn {
		ExhaustSummonDjinn(summonID)
	}

	// Show splash (unless deferred for targeting summons or four-cost)
	if !_defer_splash and !_defer_djinn and _struct.splash != -1 {
		instance_create_depth(0, 0, 500, objSummonSplash, { spr: _struct.splash })
	}

	if (_handled) { exit }

	// ── Dispatch (targeting summons) ────────────────────────────────────
	// Store splash for objMonsterTarget to show on confirm
	
	

	if (_struct.num > 0) {
		SelectTargets(_struct)
	} else {
		instance_create_depth(0, 0, 0, TurnDelay, {wait: 30, on_complete: function(){NextTurn()}})
	}
}



