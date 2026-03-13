function UnleashDjinn(djinnID, playerID) {
	
	var _struct = variable_clone(global.AggressionSchema)
	
	var djinn   = global.djinnlist[djinnID]
	var caster  = global.players[playerID]
	_struct.dmgtype = djinn.element

	// If spent, set to ready instead of unleashing
	if (djinn.spent) {
		djinn.ready = true
		djinn.spent = false
		InjectLog(djinn.name + " was set to ready")
		instance_destroy(objDjinniMenu)
		ClearOptions()
		global.pause = false
		NextTurn()
		return
	}

	// Mark djinni as spent
	djinn.ready = false
	djinn.spent = true
	djinn.just_unleashed = true

	// Clear bottom-row action buttons so targeting Confirm/Cancel can appear
	DeleteButtons()

	// Pre-calculate weapon attack (for weapon-based djinn)
	var weapon_type   = global.itemcardlist[caster.weapon].type
	var weapon_subset = (weapon_type == "Staff") ? "melee" : "all"
	var weapon_atk    = QueryDice(caster, weapon_subset, "charge") + caster.atk + caster.atkmod

	switch djinn.name {

		// ── Charged-dice damage (1 target) ──────────────────────────────
		// dam = number of charged dice, element from djinni

		case "Bane":    // Venus: damage + poison
			_struct.dam = QueryDice(caster, "all", "charge")

			_struct.statuses = {inflict_poison: true}
			break

		case "Fever":   // Mars: damage + delusion
			_struct.dam = QueryDice(caster, "all", "charge")

			_struct.statuses = {inflict_delude: true}
			break

		case "Wheeze":  // Jupiter: damage + poison
			_struct.dam = QueryDice(caster, "all", "charge")
			_struct.statuses = {inflict_poison: true}
			break

		case "Mist":    // Mercury: damage + sleep
			_struct.dam = QueryDice(caster, "all", "charge")
			_struct.statuses = {inflict_sleep: true}
			break

		case "Char":    // Mars: damage + stun
			_struct.dam = QueryDice(caster, "all", "charge")
			_struct.statuses = {inflict_stun: true}
			break

		case "Smog":    // Jupiter: damage + delusion
			_struct.dam = QueryDice(caster, "all", "charge")
			_struct.statuses = {inflict_delude: true}
			break

		case "Blitz":   // Jupiter: damage + stun
			_struct.dam = QueryDice(caster, "all", "charge")
			_struct.statuses = {inflict_stun: true}
			break

		case "Squall":  // Jupiter: damage + stun
			_struct.dam = QueryDice(caster, "all", "charge")
			_struct.statuses = {inflict_stun: true}
			break

		case "Hail":    // Mercury: damage + 2 DEF down
			_struct.dam = QueryDice(caster, "all", "charge")
			_struct.statuses = {inflict_defdown: 2}
			break

		case "Sleet":   // Mercury: damage + 2 ATK down
			_struct.dam = QueryDice(caster, "all", "charge")

			_struct.statuses = {inflict_atkdown: 2}
			break

		case "Chill":   // Mercury: damage + clear all stats
			_struct.dam = QueryDice(caster, "all", "charge")

			_struct.statuses = {inflict_clearstats: true}
			break

		case "Shine":   // Mars: damage + delusion on adjacent
			_struct.dam = QueryDice(caster, "all", "charge")
			_struct.splash_statuses = { inflict_delude: true }
			break

		// ── Weapon attack + bonus (1 target) ────────────────────────────

		case "Flint":   // Venus: weapon + half damage done
			_struct.dam = WeaponAttack(false, false).dam
			_struct.dam += ceil(_struct.dam / 2)

			break
		case "Sap":   // Venus: weapon + half damage done
			_struct.dam = WeaponAttack(true, false).dam
			_struct.unleash.heal_hp_ratio = 0.5
			break

		case "Cannon":  // Mars: weapon + half damage done
			_struct.dam = WeaponAttack(false, false).dam
			_struct.dam += ceil(_struct.dam / 2)
			break

		case "Sour":    // Mercury: weapon + half damage done
			_struct.dam = WeaponAttack(false, false).dam
			_struct.dam += ceil(_struct.dam / 2)
			break

		case "Geode":   // Venus: weapon + charged Venus * 2
			_struct.dam = WeaponAttack(true, false).dam + WeaponAttack(false,false).dam
			break

		case "Torch":   // Mars: weapon + half charged Mars
			_struct.dam = weapon_atk
			_struct.pierce = true
			break

		case "Scorch":  // Mars: weapon + charged Mars + stun
			_struct.dam = weapon_atk
			_struct.statuses = {inflict_stun: 3}
			break

		// ── Heal all living players ─────────────────────────────────────

		case "Spritz":  // Mercury: heal all for charged Mercury
			var _heal = QueryDice(caster, "elemental", "charge")
			InjectLog(djinn.name + " healed all for " + string(_heal))
			_struct.healing = _heal
			_struct.num = 4
			_struct.target = "ally"
			_struct.dmgtype = "mercury"
			break
		case "Balm":  // Mercury: heal all for 1/2 max
			for (var _i = 0; _i < array_length(global.players); _i++) {
				var _p = global.players[_i]
				_p.hp = min(_p.hp + (_p.hpmax / 2), _p.hpmax)
			}
			InjectLog(djinn.name + " healed all adepts!")
			instance_destroy(objDjinniMenu)
			ClearOptions()
			global.pause = false
			NextTurn()
			exit
			break
		case "Tonic":  // Mercury: clear all tokens
			_struct.onConfirm.removebad = true
			_struct.target = "ally"
			_struct.num = 4
			break

		case "Crystal": // Venus: heal all for charged all
			var _heal = QueryDice(caster, "elemental", "charge") + caster.def + caster.defmod
			
			InjectLog(djinn.name + " healed all for " + string(_heal))
			_struct.target = "ally"
			_struct.num = 4
			_struct.healing = _heal
			break

		// ── Heal one (targeting) ────────────────────────────────────────

		case "Spring":  // Mercury: heal for all charge
			_struct.healing = QueryDice(caster, "all", "charge")
			_struct.target = "ally"
			_struct.num = 4
			break

		case "Breath":  // Mercury: heal one for charged all
			_struct.healing = QueryDice(caster, "all", "charge")
			_struct.target = "ally"
			break

		case "Fizz":    // Mercury: heal one for half max HP
			_struct.healing = floor(caster.hpmax / 2)
			_struct.target = "ally"
			break

		// ── PP recovery ─────────────────────────────────────────────────

		case "Ember":   // Mars: all players recover PP = charged Mars
			var _pp = QueryDice(caster, "mars", "charge")
			for (var _i = 0; _i < array_length(global.players); _i++) {
				var _p = global.players[_i]
				if _p.hp > 0 { _p.pp = min(_p.pp + _pp, _p.ppmax) }
			}
			InjectLog(djinn.name + " restored " + string(_pp) + " PP to all")
			instance_destroy(objDjinniMenu)
			ClearOptions()
			global.pause = false
			NextTurn()
			exit
			break

		case "Aroma":   // Venus: all players recover PP = charged elemental
			var _pp = QueryDice(caster, "elemental", "charge")
			for (var _i = 0; _i < array_length(global.players); _i++) {
				var _p = global.players[_i]
				if _p.hp > 0 { _p.pp = min(_p.pp + _pp, _p.ppmax) }
			}
			InjectLog(djinn.name + " restored " + string(_pp) + " PP to all")
			instance_destroy(objDjinniMenu)
			ClearOptions()
			global.pause = false
			NextTurn()
			exit
			break

		// ── Stat tokens ─────────────────────────────────────────────────

		case "Forge":   // Mars: +2 ATK to all
			for (var _i = 0; _i < array_length(global.players); _i++) {
				if global.players[_i].hp > 0 { global.players[_i].atkmod += 2 }
			}
			InjectLog(djinn.name + " boosted ATK +2 for all")
			instance_destroy(objDjinniMenu)
			ClearOptions()
			global.pause = false
			NextTurn()
			exit
			break

		case "Iron":    // Venus: +3 DEF to all
			for (var _i = 0; _i < array_length(global.players); _i++) {
				if global.players[_i].hp > 0 { global.players[_i].defmod += 3 }
			}
			InjectLog("The party's defenses are bolstered!")
			instance_destroy(objDjinniMenu)
			ClearOptions()
			global.pause = false
			NextTurn()
			exit
			break

		case "Corona":  // Mars: +1 DEF to all
		case "Breeze":  // Jupiter: +1 DEF to all
			for (var _i = 0; _i < array_length(global.players); _i++) {
				if global.players[_i].hp > 0 { global.players[_i].defmod += 2 }
			}
			InjectLog(djinn.name + " boosted DEF +2 for all")
			instance_destroy(objDjinniMenu)
			ClearOptions()
			global.pause = false
			NextTurn()
			exit
			break

		// ── Pure status infliction (no damage) ──────────────────────────

		case "Luff":    // Jupiter: psyseal 1 enemy

			_struct.statuses = {inflict_psyseal: true}
			break

		case "Fog":     // Mercury: delude 1 enemy

			_struct.statuses = {inflict_delude: true}
			break

		case "Rime":    // Mercury: psyseal 1 enemy

			_struct.statuses = {inflict_psyseal: true}
			break

		case "Waft":    // Jupiter: sleep 3 enemies

			_struct.statuses = {inflict_sleep: true}
			_struct.num = 3
			break

		// ── Gust: weapon attack, then d6 — on 5/6 a second weapon attack ─
		case "Gust":

			if irandom(5) >= 4 {
				// Second attack (no unleash)
				array_push(global.attackQueue, WeaponAttack(true,false), WeaponAttack(false,false))
				InjectLog("Gust grants a second attack!")
				instance_destroy(objDjinniMenu)
				ClearOptions()
				ProcessAttackQueue()
				exit
			}else{
				WeaponAttack(true,true)
				
				instance_destroy(objDjinniMenu)
			
				exit
			}

			break

		case "Mud": // reduces enemy move roll index by 1
			AddPassive("_mud",3,Venus875,"Mud",{},playerID)
			InjectLog("Enemies moves restricted!")
			
			instance_destroy(objDjinniMenu)
			NextTurn()
			ClearOptions()
			exit
			break
			
		case "Vine": // skips all enemy attempt targeting
			AddPassive("_vine",3,Venus875,"Vine",{},playerID)
			InjectLog("Enemies got all tangled up!")
			instance_destroy(objDjinniMenu)
			ClearOptions()
			NextTurn()
			exit
			break
		case "Mold":
			// Target's neighbours each hit it with a random attack (as if deluded)
			_struct.dam = 0
			_struct.mold = true
			break
		case "Flower":
			instance_create_depth(0,0,0,objAssignMenu,{dieset:"venus", num: 4, element: "Venus", target: "ally"})
			exit
			break
		case "Shade":
			AddPassive("damage_half",1,Mercury865,"Shade",{},playerID)
			InjectLog("The party is surrounded by a barrier")
			instance_destroy(objDjinniMenu)
			ClearOptions()
			NextTurn()
			exit
			break
		case "Granite":
			AddPassive("damage_half",1,Venus875,"Granite",{},playerID)
			InjectLog("The party is surrounded by a barrier")
			instance_destroy(objDjinniMenu)
			ClearOptions()
			NextTurn()
			exit
			break
		case "Flash":
			AddPassive("damage_cap_1",1,Mars863,"Flash",{},playerID)
			InjectLog("The party is surrounded by a barrier")
			instance_destroy(objDjinniMenu)
			ClearOptions()
			NextTurn()
			exit
			break
		case "Ground":
			AddPassive("skip_enemies", 1, Venus875, "Ground", {}, playerID)
			InjectLog("The enemies are unable to move!")
			instance_destroy(objDjinniMenu)
			ClearOptions()
			NextTurn()
			exit
			break
		case "Salt":
			global.passiveEffects = []
			for (var i = 0; i < array_length(global.players); ++i) {
			    var curr = global.players[i]
				curr.poison = false
				curr.stun = 0
				curr.sleep = false
				curr.psyseal = false
				curr.venom = false
				curr.atkmod = 0
				curr.defmod = 0
				curr.regen = 0
				curr.regheal = 0
			}
			InjectLog("Allies are cleansed!")
			instance_destroy(objDjinniMenu)
			ClearOptions()
			NextTurn()
			exit
			break
		case "Quartz":
			var healval = irandom(5)
			if healval <= 4{_struct.onConfirm.heal_hp_ratio = .5}else{_struct.healing = 9999}
			_struct.revive = 1
			_struct.target = "ally"
			break
		case "Echo":
			var attack = WeaponAttack(true,false)
			_struct.dam = attack.dam
			_struct.unleash = attack.unleash
			_struct.unleash.repeater = 1
			_struct.statuses = attack.statuses
			_struct.onConfirm.convert_element = "venus"
			_struct.dmgtype = "venus"
			break
		case "Steel":
			var heal = WeaponAttack(true,false).unleash.dam_bonus
			if WeaponAttack(true,false).unleash.double_atk{heal *= 2}
			_struct.onConfirm.heal_hp_flat = heal
			_struct.onConfirm.active = true
			break
		case "Meld":
			// Pick another adept's weapon, attack with caster's dice
			instance_destroy(objDjinniMenu)
			ClearOptions()
			instance_create_depth(0, 0, 0, objMeldPicker)
			exit
			break
		case "Petra":
			instance_destroy(objDjinniMenu)
			ClearOptions()
			DeleteButtons()
			instance_create_depth(0,0,0,objMolochPicker,{source:"djinni", caster_id: playerID})
			exit
			break
		case "Dew":
			_struct.revive = true
			_struct.healing = 9999
			_struct.target = "ally"
			break
		case "Steam":
			AddPassive("_element", 3, Mercury865,"Steam",{},playerID)
			instance_destroy(objDjinniMenu)
			ClearOptions()
			NextTurn()
			exit
			break
		case "Gel":
			_struct.dam = WeaponAttack(true,false).dam + WeaponAttack(true,false).unleash.dam_bonus
			_struct.unleash = WeaponAttack(true,false).unleash
			_struct.dmgtype = "mercury"
			break
		case "Serac":
			_struct.dam = WeaponAttack(false,false).dam
			_struct.unleash = WeaponAttack(true,false).unleash
			if irandom(5) == 0{
				_struct.dam = 9999
			}
			break
		case "Eddy":
			var _djinnsel=[]
			for (var i = 0; i < array_length(global.players); ++i) {
			    for (var j = 0; j < array_length(global.players[i].djinn); ++j) {
				    if global.djinnlist[global.players[i].djinn[j]].spent == true and global.djinnlist[global.players[i].djinn[j]].ready == true{
						array_push(_djinnsel,global.players[i].djinn[j])
					}
				}
			}
			array_shuffle(_djinnsel)
			_djinnsel[0].spent = false
			instance_destroy(objDjinniMenu)
			ClearOptions()
			NextTurn()
			exit
			break
		case "Kindle":
			AddPassive("_melee", 3, Mars863,"Kindle",{},playerID)
			instance_destroy(objDjinniMenu)
			ClearOptions()
			NextTurn()
			exit
			break
		case "Spark":
			_struct.revive = true
			_struct.healingratio = 0.5
			_struct.target = "ally"
			break
		case "Core":
			var _maxdamage = caster.melee + caster.atk + caster.atkmod
			if weapon_type != "Staff"{ _maxdamage += caster.venus + caster.mars + caster.jupiter + caster.mercury}
			if weapon_type == "Mace" {_maxdamage*=2}
			
			if WeaponAttack(true,false).dam >= _maxdamage/2{
				_struct.statuses = {inflict_clearstats: true}
			}
			_struct.dam = WeaponAttack(true,false).dam
			_struct.unleash = WeaponAttack(true,false).unleash
			break
		case "Reflux":
			caster.reflect = true
			InjectLog(caster.name + " is ready to strike back!")
			instance_destroy(objDjinniMenu)
			ClearOptions()
			global.pause = false
			NextTurn()
			exit
			break
		case "Fugue":
			_struct.dam = 1
			_struct.num = 12
			_struct.dmgtype = "mars"
			_struct.statuses = {inflict_psyseal: true}
			InjectLog("Assign "+ QueryDice(caster,"all","charge") +" damage")
			for (var i = 0; i < QueryDice(caster,"all","charge"); ++i) {
			    array_push(global.attackQueue,variable_clone(_struct))
			}
			instance_destroy(objDjinniMenu)
			ClearOptions()
			global.pause = false
			NextTurn()
			exit
			break
		case "Coal":
			// Grant partial reroll to ALL players, expires after 1 round
			for (var _ri = 0; _ri < 4; _ri++) {
				if global.players[_ri].hp > 0 {
					array_push(global.players[_ri].rerolls, {mode: "partial", uses: -1, source: "Coal", expires: 1})
				}
			}
			InjectLog("Everyone can reroll their dice!")
			instance_destroy(objDjinniMenu)
			ClearOptions()
			CreateOptions()
			NextTurn()
			exit
		case "Tinder":
			_struct.target = "ally"
			_struct.delayed = true
			_struct.delaydata = {}
			_struct.delaydata.healing = QueryDice(caster,"mars","affinity")
			_struct.delaydata.revive = true
			_struct.revive = true
			break
		case "Fury":
			_struct.dam = QueryDice(caster,"all","charge")
			_struct.statuses = {inflict_haunt: 2}
			_struct.dmgtype = "mars"
			break
		case "Kite":
			_struct.target = "ally"
			_struct.dam = 0
			_struct.onConfirm.grant_extra_turn = 1
			_struct.onConfirm.active = true
			break
		case "Zephyr":
			// Grant full reroll to ALL players, persists until used
			for (var _ri = 0; _ri < 4; _ri++) {
				if global.players[_ri].hp > 0 {
					array_push(global.players[_ri].rerolls, {mode: "full", uses: 1, source: "Zephyr", expires: -1})
				}
			}
			InjectLog("Everyone can reroll their dice!")
			instance_destroy(objDjinniMenu)
			ClearOptions()
			CreateOptions()
			NextTurn()
			exit
		case "Ether":
			_struct.ppheal = QueryDice(caster,"all","charge")
			_struct.target = "ally"
			break
		case "Haze":
			_struct.cloak = true
			_struct.target = "ally"
			break
		case "Whorl":
			_struct.dam = WeaponAttack(false,false).dam
			_struct.unleash = WeaponAttack(true,false).unleash
			if irandom(5) == 0{
				_struct.dam = 9999
			}
			break
		case "Gasp":
			_struct.num = 12
			_struct.statuses = {inflict_haunt: 2}
			break
		case "Lull":
			global.playersActed = 0
			global.turn = (global.firstPlayer + 3) mod 4
			InjectLog(caster.name + " calls for a ceasefire!")
			NextTurn()
			exit
			break
		case "Gale":
		if irandom(1) == 0{
			_struct.dam = 9999
		}
		break
			
		default:
			show_debug_message("UnleashDjinn: '" + djinn.name + "' has no implementation yet")
			InjectLog(djinn.name + " has no effect yet")
			instance_destroy(objDjinniMenu)
			global.pause = false
			NextTurn()
			break
			
	}
	// Djinn Echo passive: expand single-target djinn to 3
	if (_struct.num == 1 && CheckPassive("_DjinnEcho") != undefined) {
		_struct.num = 3
	}

	instance_destroy(objDjinniMenu)
	ClearOptions()
	SelectTargets(_struct)
}