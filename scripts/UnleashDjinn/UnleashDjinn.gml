function UnleashDjinn(djinnID, playerID) {
	
	var _struct = variable_clone(global.AggressionSchema)

	var djinn   = global.djinnlist[djinnID]
	var caster  = global.players[playerID]
	_struct.source  = "djinni"
	_struct.dmgtype = djinn.element
	_struct.djinn_id = djinnID
	_struct.cast_name = caster.name + " unleashes " + djinn.name + "!"
	_struct.num = 1

	// If spent, set to ready instead of unleashing
	if (djinn.spent) {
		djinn.ready = true
		djinn.spent = false
		InjectLog(djinn.name + " was set to ready")
		
		MakeTurnDelay(60,NextTurn)
		return
	}

	// Mark djinni as spent
	djinn.ready = false
	djinn.spent = true
	djinn.just_unleashed = true

	// Clear bottom-row action buttons so targeting Confirm/Cancel can appear
	

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
			_struct.anim = [{ type: "burst", element: "venus", fires_hit: true, sfx: Explosion1, count: 15, max_speed: 2, max_scale: 1.5, duration: 20, shake: 2, shake_duration: 8 }]
			break

		case "Fever":   // Mars: damage + delusion
			_struct.dam = QueryDice(caster, "all", "charge")
			_struct.statuses = {inflict_delude: true}
			_struct.anim = [{ type: "burst", element: "mars", fires_hit: true, sfx: Explosion1, count: 15, max_speed: 2, max_scale: 1.5, duration: 20, shake: 2, shake_duration: 8 }]
			break

		case "Wheeze":  // Jupiter: damage + poison
			_struct.dam = QueryDice(caster, "all", "charge")
			_struct.statuses = {inflict_poison: true}
			_struct.anim = [{ type: "wind", element: "jupiter", fires_hit: true, sfx: MoveSpellSound, hit_delay: 20, hold: 30, shake: 1, shake_duration: 6 }]
			break

		case "Mist":    // Mercury: damage + sleep
			_struct.dam = QueryDice(caster, "all", "charge")
			_struct.statuses = {inflict_sleep: true}
			_struct.anim = [{ type: "cloud", element: "mercury", fires_hit: true, sfx: MagicSound, hit_delay: 40, spawn: 20 }]
			break

		case "Char":    // Mars: damage + stun
			_struct.dam = QueryDice(caster, "all", "charge")
			_struct.statuses = {inflict_stun: true}
			_struct.anim = [{ type: "flash", element: "mars", fires_hit: true, sfx: Explosion1, hold: 15, peak: 3 }]
			break

		case "Smog":    // Jupiter: damage + delusion
			_struct.dam = QueryDice(caster, "all", "charge")
			_struct.statuses = {inflict_delude: true}
			_struct.anim = [{ type: "cloud", element: "jupiter", fires_hit: true, sfx: MagicSound, hit_delay: 40, spawn: 20 }]
			break

		case "Blitz":   // Jupiter: damage + stun
			_struct.dam = QueryDice(caster, "all", "charge")
			_struct.statuses = {inflict_stun: true}
			_struct.anim = [{ type: "pillar", element: "jupiter", fires_hit: true, sfx: BigRockHit, hold: 20, shake: 3, shake_duration: 10 }]
			break

		case "Squall":  // Jupiter: damage + stun
			_struct.dam = QueryDice(caster, "all", "charge")
			_struct.statuses = {inflict_stun: true}
			_struct.anim = [{ type: "burst", element: "jupiter", fires_hit: true, sfx: Explosion1, count: 20, max_speed: 3, max_scale: 2, duration: 25, shake: 3, shake_duration: 10 }]
			break

		case "Hail":    // Mercury: damage + 2 DEF down
			_struct.dam = QueryDice(caster, "all", "charge")
			_struct.statuses = {inflict_defdown: 2}
			_struct.anim = [{ type: "burst", element: "mercury", fires_hit: true, sfx: Explosion1, count: 20, max_speed: 3, max_scale: 1, duration: 25, shake: 2, shake_duration: 8 }]
			break

		case "Sleet":   // Mercury: damage + 2 ATK down
			_struct.dam = QueryDice(caster, "all", "charge")
			_struct.statuses = {inflict_atkdown: 2}
			_struct.anim = [{ type: "drizzle", element: "mercury", fires_hit: true, sfx: RunningWater, hit_delay: 40, hold: 40, linger: 20,
				rate: 6, drop_scale: 0.3, spread: 1.2, drop_speed: 1.5 }]
			break

		case "Chill":   // Mercury: damage + clear all stats
			_struct.dam = QueryDice(caster, "all", "charge")
			_struct.statuses = {inflict_clearstats: true}
			_struct.anim = [{ type: "burst", element: "mercury", fires_hit: true, sfx: Explosion1, count: 25, max_speed: 3, max_scale: 2, duration: 30, shake: 3, shake_duration: 12 }]
			break

		case "Shine":   // Mars: damage + delusion on adjacent
			_struct.dam = QueryDice(caster, "all", "charge")
			_struct.splash_statuses = { inflict_delude: true }
			_struct.anim = [{ type: "flash", element: "mars", fires_hit: true, sfx: Explosion1, hold: 20, peak: 4 }]
			break

		// ── Weapon attack + bonus (1 target) ────────────────────────────

		case "Flint":   // Venus: weapon + half damage done
			_struct.dam = WeaponAttack(false, false).dam
			_struct.dam += ceil(_struct.dam / 2)
			_struct.anim = [{ type: "meteor", element: "venus", fires_hit: true, sfx: BigRockHit, sfx_start: FallSound, speed: 4, accel: 0.2, trail: 0, shake: 4, shake_duration: 12, linger: 15,
				sub: [{ type: "burst", at: "hit", count: 25, max_speed: 3, max_scale: 2, trail: 0 }] }]
			break
		case "Sap":   // Venus: weapon + half damage done
			_struct.dam = WeaponAttack(true, false).dam
			_struct.unleash.heal_hp_ratio = 0.5
			_struct.anim = [{ type: "burst", element: "venus", fires_hit: true, sfx: DrainSound, count: 15, max_speed: 2, max_scale: 1.5, duration: 20, shake: 2, shake_duration: 8 }]
			break

		case "Cannon":  // Mars: weapon + half damage done
			_struct.dam = WeaponAttack(false, false).dam
			_struct.dam += ceil(_struct.dam / 2)
			_struct.anim = [{ type: "meteor", element: "mars", fires_hit: true, sfx: BigRockHit, sfx_start: FallSound, speed: 4, accel: 0.2, trail: 0, shake: 4, shake_duration: 12, linger: 15,
				sub: [{ type: "burst", at: "hit", count: 25, max_speed: 3, max_scale: 2, trail: 0 }] }]
			break

		case "Sour":    // Mercury: weapon + half damage done
			_struct.dam = WeaponAttack(false, false).dam
			_struct.dam += ceil(_struct.dam / 2)
			_struct.anim = [{ type: "meteor", element: "mercury", fires_hit: true, sfx: BigRockHit, sfx_start: FallSound, speed: 4, accel: 0.2, trail: 0, shake: 4, shake_duration: 12, linger: 15,
				sub: [{ type: "burst", at: "hit", count: 25, max_speed: 3, max_scale: 2, trail: 0 }] }]
			break

		case "Geode":   // Venus: weapon + charged Venus * 2
			_struct.dam = WeaponAttack(true, false).dam + WeaponAttack(false,false).dam
			_struct.anim = [{ type: "burst", element: "venus", fires_hit: true, sfx: Explosion1, count: 30, max_speed: 3, max_scale: 2.5, duration: 30, shake: 4, shake_duration: 15 }]
			break

		case "Torch":   // Mars: weapon + half charged Mars
			_struct.dam = weapon_atk
			_struct.pierce = true
			_struct.anim = [{ type: "fire", element: "mars", fires_hit: true, sfx: FireSound, hit_delay: 30, rate: 3, width: 0.4, life: 30, life_var: 15, hold: 40, linger: 20, shake: 2, shake_duration: 10 }]
			break

		case "Scorch":  // Mars: weapon + charged Mars + stun
			_struct.dam = weapon_atk
			_struct.statuses = {inflict_stun: true}
			_struct.anim = [{ type: "burst", element: "mars", fires_hit: true, sfx: Explosion1, count: 20, max_speed: 3, max_scale: 2, duration: 25, shake: 3, shake_duration: 12 }]
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
				_p.hp = min(_p.hp + floor(_p.hpmax / 2), _p.hpmax)
			}
			InjectLog(djinn.name + " healed all adepts!")
			PushMenu(objMenuGrid,{read_only: true, corner: "topright"})
			
			MakeTurnDelay(120,NextTurn)
			exit
			break
		case "Tonic":  // Mercury: clear all tokens
			_struct.onConfirm.removebad = true
			_struct.onConfirm.removepoison = true
			_struct.target = "ally"
			_struct.num = 1
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
			_struct.num = 1
			break

		case "Breath":  // Mercury: heal one for charged all
			_struct.healing = QueryDice(caster, "all", "charge")
			_struct.target = "ally"
			_struct.num = 1
			break

		case "Fizz":    // Mercury: heal one for half max HP
			_struct.healingratio = 0.5
			_struct.target = "ally"
			break

		// ── PP recovery ─────────────────────────────────────────────────

		case "Ember":   // Mars: all players recover PP = charged Mars
			var _pp = QueryDice(caster, "mars", "charge")
			for (var _i = 0; _i < array_length(global.players); _i++) {
				var _p = global.players[_i]
				if _p.hp > 0 { _p.pp = min(_p.pp + _pp, _p.ppmax) }
			}
			InjectLog("All adepts restored " + string(_pp) + " PP")
			PushMenu(objMenuGrid,{read_only: true, corner: "topright"})
			
			MakeTurnDelay(120,NextTurn)
			exit
			break

		case "Aroma":   // Venus: all players recover PP = charged elemental
			var _pp = QueryDice(caster, "elemental", "charge")
			for (var _i = 0; _i < array_length(global.players); _i++) {
				var _p = global.players[_i]
				if _p.hp > 0 { _p.pp = min(_p.pp + _pp, _p.ppmax) }
			}
			InjectLog("All adepts restored " + string(_pp) + " PP")
			PushMenu(objMenuGrid,{read_only: true, corner: "topright"})
			
			MakeTurnDelay(120,NextTurn)
			exit
			break

		// ── Stat tokens ─────────────────────────────────────────────────

		case "Forge":   // Mars: +2 ATK to all
			for (var _i = 0; _i < array_length(global.players); _i++) {
				if global.players[_i].hp > 0 { global.players[_i].atkmod += 2 }
			}
			caster.atkmod_fresh = true
			InjectLog(djinn.name + " boosted ATK +2 for all")
			PopAll()
			MakeTurnDelay(60,NextTurn)
			exit
			break

		case "Iron":    // Venus: +3 DEF to all
			for (var _i = 0; _i < array_length(global.players); _i++) {
				if global.players[_i].hp > 0 { global.players[_i].defmod += 3 }
			}
			caster.defmod_fresh = true
			InjectLog("The party's defenses are bolstered!")
			PopAll()
			MakeTurnDelay(60,NextTurn)
			exit
			break

		case "Corona":  // Mars: +1 DEF to all
		case "Breeze":  // Jupiter: +1 DEF to all
			for (var _i = 0; _i < array_length(global.players); _i++) {
				if global.players[_i].hp > 0 { global.players[_i].defmod += 2 }
			}
			caster.defmod_fresh = true
			InjectLog(djinn.name + " boosted DEF +2 for all")
			
			PushMenu(objMenuGrid,{read_only: true, corner: "topright"})
			MakeTurnDelay(120,NextTurn)
			exit
			break

		// ── Pure status infliction (no damage) ──────────────────────────

		case "Luff":    // Jupiter: psyseal 1 enemy
			_struct.statuses = {inflict_psyseal: true}
			_struct.anim = [{ type: "wind", element: "jupiter", fires_hit: true, sfx: InflictStatus, hit_delay: 20, hold: 30 }]
			break

		case "Fog":     // Mercury: delude 1 enemy
			_struct.statuses = {inflict_delude: true}
			_struct.anim = [{ type: "cloud", element: "mercury", fires_hit: true, sfx: InflictStatus, hit_delay: 40, spawn: 20 }]
			break

		case "Rime":    // Mercury: psyseal 1 enemy
			_struct.statuses = {inflict_psyseal: true}
			_struct.anim = [{ type: "burst", element: "mercury", fires_hit: true, sfx: InflictStatus, count: 12, max_speed: 2, max_scale: 1, duration: 20 }]
			break

		case "Waft":    // Jupiter: sleep 3 enemies
			_struct.statuses = {inflict_sleep: true}
			_struct.num = 3
			_struct.anim = [{ type: "cloud", element: "jupiter", fires_hit: true, sfx: InflictStatus, hit_delay: 50, spawn: 25 }]
			break

		// ── Gust: weapon attack, then d6 — on 5/6 a second weapon attack ─
		case "Gust":

			if irandom(5) >= 4 {
				// Second attack (no unleash)
				array_push(global.attackQueue, WeaponAttack(true,false), WeaponAttack(false,false))
				InjectLog("Gust grants a second attack!")
				
				ProcessAttackQueue()
				exit
			}else{
				WeaponAttack(true,true)
				
			
				exit
			}

			break

		case "Mud": // reduces enemy move roll index by 1
			AddPassive("_mud",3,Venus875,"Mud",{},playerID)
			InjectLog("Enemies moves restricted!")
			
			PopAll()
			MakeTurnDelay(60,NextTurn)
			
			exit
			break
			
		case "Vine": // skips all enemy attempt targeting
			AddPassive("_vine",3,Venus875,"Vine",{},playerID)
			InjectLog("Enemies got all tangled up!")
			PopAll()
			MakeTurnDelay(60,NextTurn)
			exit
			break
		case "Mold":
			// Target's neighbours each hit it with a random attack (as if deluded)
			_struct.dam = 0
			_struct.mold = true
			_struct.anim = [{ type: "burst", element: "venus", fires_hit: true, sfx: Explosion1, count: 10, max_speed: 1.5, max_scale: 1, duration: 15 }]
			break
		case "Flower":
			var _flower_dice = BuildDiceArray(global.players[playerID], "venus")
			var _flower_max  = min(4, array_length(global.players), array_length(_flower_dice))
			PushMenu(objDicePicker, {
				dice:          _flower_dice,
				max_select:    _flower_max,
				confirm_label: "Assign",
				title:         "Pick " + string(_flower_max) + " dice",
				on_confirm:    method({}, function(sel) {
					for (var _i = 0; _i < array_length(sel); _i++) {
						var _s = variable_clone(global.AggressionSchema)
						_s.source = "djinni"; _s.healing = sel[_i].pip
						_s.num = 1; _s.dmgtype = "venus"; _s.target = "ally"
						array_push(global.attackQueue, _s)
					}
					PopMenu()
					
					ProcessAttackQueue()
				}),
			})
			exit
			break
		case "Shade":
			AddPassive("damage_half",1,Mercury865,"Shade",{},playerID)
			InjectLog("The party is surrounded by a barrier")
			
			PopAll()
			MakeTurnDelay(60,NextTurn)
			exit
			break
		case "Granite":
			AddPassive("damage_half",1,Venus875,"Granite",{},playerID)
			InjectLog("The party is surrounded by a barrier")
			
			PopAll()
			MakeTurnDelay(60,NextTurn)
			exit
			break
		case "Flash":
			AddPassive("damage_cap_1",1,Mars863,"Flash",{},playerID)
			InjectLog("The party is surrounded by a barrier")
			PopAll()
			MakeTurnDelay(60,NextTurn)
			exit
			break
		case "Ground":
			AddPassive("skip_enemies", 1, Venus875, "Ground", {}, playerID)
			InjectLog("The enemies are unable to move!")
			PopAll()
			MakeTurnDelay(60,NextTurn)
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
			PushMenu(objMenuGrid,{read_only: true, corner: "topright"})
			
			MakeTurnDelay(120,NextTurn)
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
			_struct.anim = [{ type: "burst", element: "venus", fires_hit: true, sfx: Explosion1, count: 20, max_speed: 2, max_scale: 2, duration: 25, shake: 3, shake_duration: 10 }]
			break
		case "Steel":
			var heal = WeaponAttack(true,false).unleash.dam_bonus
			if WeaponAttack(true,false).unleash.double_atk{heal *= 2}
			_struct.onConfirm.heal_hp_flat = heal
			_struct.onConfirm.active = true
			_struct.anim = [{ type: "burst", element: "venus", fires_hit: true, sfx: Explosion1, count: 15, max_speed: 2, max_scale: 1.5, duration: 20, shake: 2, shake_duration: 8 }]
			break
		case "Meld":
			// Pick another adept's weapon, attack with caster's dice
			var _meld_caster = global.players[playerIndex]
			var _meld_original = _meld_caster.weapon
			var _meld_items = []
			for (var _mp = 0; _mp < array_length(global.players); _mp++) {
				var _mwep = global.itemcardlist[global.players[_mp].weapon]
				_meld_caster.weapon = global.players[_mp].weapon
				var _mpreview = WeaponAttack(true, false)
				array_push(_meld_items, { name: _mwep.name, detail: "Damage: " + string(_mpreview.dam), data: { weapon_id: global.players[_mp].weapon } })
			}
			_meld_caster.weapon = _meld_original
			PopMenu()
			PushMenu(objMenuCarousel, {
				items:         _meld_items,
				confirm_label: "Attack",
				on_confirm:    method({ _mc: _meld_caster, _mo: _meld_original }, function(i, item) {
					_mc.weapon = item.data.weapon_id
					WeaponAttack(true, true)
					_mc.weapon = _mo
				}),
			})
			exit
			break
		case "Petra":
			PushMenu(objMenuSlider, {
				minim: 1, maxim: 20, value: 1,
				confirm_label: "Restrict",
				label: function(v) { return "Restrict enemy move #" + string(v) },
				on_confirm: method({ pid: playerID }, function(v) {
					AddPassive("reroll_move", 3, Venus875, "Petra", { number: v }, pid)
					InjectLog("Petra restricts the enemies options!")
					PopAll()
					MakeTurnDelay(60,NextTurn)
				}),
			})
			exit
			break
		case "Dew":
			_struct.revive = true
			_struct.healing = 9999
			_struct.target = "ally"
			break
		case "Steam":
			AddPassive("_element", 3, Mercury865,"Steam",{},playerID)
			InjectLog("The party gains additional dice")
			PopAll()
			MakeTurnDelay(60,NextTurn)
			exit
			break
		case "Gel":
			_struct.dam = WeaponAttack(true,false).dam + WeaponAttack(true,false).unleash.dam_bonus
			_struct.unleash = WeaponAttack(true,false).unleash
			_struct.dmgtype = "mercury"
			_struct.anim = [{ type: "burst", element: "mercury", fires_hit: true, sfx: Explosion1, count: 20, max_speed: 2, max_scale: 2, duration: 25, shake: 3, shake_duration: 10 }]
			break
		case "Serac":
			_struct.dam = WeaponAttack(false,false).dam
			_struct.unleash = WeaponAttack(true,false).unleash
			if irandom(5) == 0{
				_struct.dam = 9999
			}
			_struct.anim = [{ type: "pillar", element: "mercury", fires_hit: true, sfx: BigRockHit, hold: 25, shake: 4, shake_duration: 15 }]
			break
		case "Eddy":
			var _djinnsel=[]
			for (var i = 0; i < array_length(global.players); ++i) {
			    for (var j = 0; j < array_length(global.players[i].djinn); ++j) {
				    if global.djinnlist[global.players[i].djinn[j]].spent == false and global.djinnlist[global.players[i].djinn[j]].ready == false{
						array_push(_djinnsel,global.players[i].djinn[j])
					}
				}
			}
			array_shuffle(_djinnsel)
			if array_length(_djinnsel) > 0 {
				global.djinnlist[_djinnsel[0]].spent = true
				global.djinnlist[_djinnsel[0]].ready = false
				InjectLog(global.djinnlist[_djinnsel[0]].name + " recovers!")
			
			}else{
			
				InjectLog("Nothing happened...")
			
			}
			PopAll()
			MakeTurnDelay(60,NextTurn)
			exit
			break
		case "Kindle":
			AddPassive("_melee", 3, Mars863,"Kindle",{},playerID)
			InjectLog("The party gains additional dice")
			PopAll()
			MakeTurnDelay(60,NextTurn)
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
			_struct.anim = [{ type: "fire", element: "mars", fires_hit: true, sfx: FireSound, hit_delay: 40, rate: 4, width: 0.5, life: 40, life_var: 20, hold: 60, linger: 30, shake: 4, shake_duration: 15,
				sub: [{ type: "flash", at: 1, hold: 20, element: "mars" }] }]
			break
		case "Reflux":
			caster.reflect = true
			InjectLog(caster.name + " is ready to strike back!")
			PopAll()
			MakeTurnDelay(60,NextTurn)
			exit
			break
		case "Fugue": // Mars: 1 damage x All Charge hits, random target each, inflict Psy Seal
			_struct.dam      = 1
			_struct.repeater = QueryDice(caster, "all", "charge")
			_struct.num      = 1
			_struct.unleash  = { scatter: true, scatter_any: true }
			_struct.statuses = { inflict_psyseal: true }
			_struct.anim = [{ type: "burst", element: "mars", fires_hit: true, sfx: Explosion1, count: 15, max_speed: 3, max_scale: 1.5, duration: 20, shake: 2, shake_duration: 8 }]
			break
		case "Coal":
			// Grant partial reroll to ALL players, expires after 1 round
			for (var _ri = 0; _ri < 4; _ri++) {
				if global.players[_ri].hp > 0 {
					array_push(global.players[_ri].rerolls, {mode: "partial", uses: -1, source: "Coal", expires: 1})
				}
			}
			InjectLog("Everyone can reroll their dice!")
			PushMenu(objMenuGrid,{read_only: true, corner: "topright"})
			MakeTurnDelay(120,NextTurn)
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
			_struct.anim = [{ type: "fire", element: "mars", fires_hit: true, sfx: FireSound, hit_delay: 30, rate: 3, width: 0.4, life: 35, life_var: 15, hold: 45, linger: 20, shake: 3, shake_duration: 10 }]
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
			PushMenu(objMenuGrid,{read_only: true, corner: "topright"})
			MakeTurnDelay(120,NextTurn)
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
			_struct.anim = [{ type: "wind", element: "jupiter", fires_hit: true, sfx: MoveSpellSound, hit_delay: 25, hold: 40, shake: 3, shake_duration: 12 }]
			break
		case "Gasp":
			_struct.num = 12
			_struct.statuses = {inflict_haunt: 2}
			_struct.anim = [{ type: "cloud", element: "jupiter", fires_hit: true, sfx: MagicSound, hit_delay: 50, spawn: 25 }]
			break
		case "Lull":
			global.playersActed = 0
			global.turn = (global.firstPlayer + 3) mod 4
			InjectLog(caster.name + " calls for a ceasefire!")
			MakeTurnDelay(60,NextTurn)
			exit
			break
		case "Gale":
			if irandom(1) == 0{
				_struct.dam = 9999
			}
			_struct.anim = [{ type: "wind", element: "jupiter", fires_hit: true, sfx: MoveSpellSound, hit_delay: 30, hold: 50, shake: 4, shake_duration: 15 }]
			break
			
		default:
			show_debug_message("UnleashDjinn: '" + djinn.name + "' has no implementation yet")
			InjectLog(djinn.name + " has no effect yet")
			MakeTurnDelay(60,NextTurn)
			break
			
	}
	// Djinn Echo passive: expand single-target djinn to 3
	if (_struct.num == 1 && CheckPassive("_DjinnEcho") != undefined) {
		_struct.num = 3
	}

	
	SelectTargets(_struct)
}
