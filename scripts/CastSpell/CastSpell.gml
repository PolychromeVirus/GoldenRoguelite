// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
/// @desc Find effects and values of a given spell
/// @param {any*} spellID Index of a spell in the global psynergy list
/// @param {any*} playerID index of a player in the global players list
function CastSpell(spellID, playerID) {
	var spell  = global.psynergylist[spellID]
	var caster = global.players[playerID]
	var _cost = spell.cost
	
		_cost = max(1, _cost - caster.ppdiscount)


	// PP deduction deferred to target confirmation for spells that go through SelectTargets/objCharTarget
	// Immediate-effect spells deduct PP inline below
	global.pendingPPCost = _cost
	global.pendingPPCaster = playerID

	var struct = variable_clone(global.AggressionSchema)
	struct.source = "psynergy"
	struct.num = real(spell.range)
	struct.dmgtype = string_lower(spell.element)
	
	
	// Pre-calculate weapon attack equivalent (used by Slash, Astral Blast, Diamond Dust)
	var weapon_type   = global.itemcardlist[caster.weapon].type
	var weapon_subset = (weapon_type == "Staff") ? "melee" : "all"
	var weapon_atk    = QueryDice(caster, weapon_subset, "charge") + caster.atk + caster.atkmod

	switch spell.base {

		// ── TIER 1: Flat damage ─────────────────────────────────────────────

		case "Bolt":    // 5 / 5 / 10
			struct.dam = real(spell.damage)
			struct.statuses.inflict_stun = true
			break
		
		case "Flare":   // 5 / 10 / 15
		case "Ray":     // 3 / 8 / 12
			struct.dam = real(spell.damage)
			break

		case "Douse":   // 3 / 8 / 12
			
			struct.dam = real(spell.damage)
			break

		// ── TIER 2: Dice-based damage (offensive) ───────────────────────────

		case "Astral Blast":
			// Stage 1: weapon attack damage + charged Jupiter
			// Stage 2 (Thunder Mine): sum of all Jupiter pip values
			if spell.stage == 1 {
				struct.dam = weapon_atk + QueryDice(caster, "jupiter", "charge")
			} else {
				struct.dam = QueryDice(caster, "jupiter", "values")
			}
			break

		case "Beam":
			// Stage 1: 1 per uncharged Mars + 2 per charged Mars
			// Stage 2+: 3 per charged Mars
			if spell.stage == 1 {
				struct.dam = QueryDice(caster, "mars", "uncharge") + (QueryDice(caster, "mars", "charge") * 2)
			} else {
				struct.dam = QueryDice(caster, "mars", "charge") * 3
			}
			break

		case "Blast":
			// All stages: charged_all damage
			struct.num = 0
			if caster.venus > 0{struct.num += 1}
			if caster.mars > 0{struct.num += 1}
			if caster.jupiter > 0{struct.num += 1}
			if caster.mercury > 0{struct.num += 1}
			struct.dam = QueryDice(caster, "all", "charge")
			if spell.stage == 2{struct.dam += struct.num * 2}
			
			if spell.stage == 3{
				struct.num = 3
				struct.dam = 0
				if caster.venus > 0{struct.dam += QueryDice(caster, "venus", "highest")}
				if caster.mars > 0{struct.dam += QueryDice(caster, "mars", "highest")}
				if caster.jupiter > 0{struct.dam += QueryDice(caster, "jupiter", "highest")}
				if caster.mercury > 0{struct.dam += QueryDice(caster, "mercury", "highest")}
			}
			
			break

		case "Cool":
			// Stage 1 (Cool): flat 2 to all
			// Stage 2 (Supercool): charged Mercury to all
			// Stage 3 (Megacool): charged all to all
			if spell.stage == 1 {
				struct.dam = 2
			} else if spell.stage == 2 {
				struct.dam = QueryDice(caster, "mercury", "charge")
			} else {
				struct.dam = QueryDice(caster, "all", "charge")
			}
			break

		case "Diamond Dust":
			// Stage 1: weapon attack as Mercury, half damage to neighbours
			// Stage 2 (Diamond Berg): weapon attack × 2
			if spell.stage == 1 {struct.onConfirm.splash_ratio = 0.5
				struct.onConfirm.splash_element = "mercury"}
			struct.dam = weapon_atk
			if spell.stage == 2 { struct.dam *= 2 }
			break

		case "Frost":

			// Stage 1: charged melee
			// Stage 2 (Tundra): charged Mercury * 2 + charged melee
			// Stage 3 (Glacier): charged Mercury * 3 + charged melee
			if spell.stage == 1 {
				struct.dam = QueryDice(caster, "melee", "charge")
			} else if spell.stage == 2 {
				struct.dam = QueryDice(caster, "mercury", "charge") * 2 + QueryDice(caster, "melee", "charge")
			} else {
				struct.dam = QueryDice(caster, "melee", "charge") + QueryDice(caster, "mercury", "charge") * 2
			}
			break

		case "Froth":
			// Stages 1+2: charged Mercury
			// Stage 3 (Froth Spiral): charged Mercury * 2
			if spell.stage < 3 {
				if QueryDice(caster, "venus", "charge") >= 2 { struct.statuses.inflict_defdown = 2 }
				struct.dam = QueryDice(caster, "mercury", "charge")
			} else {
				struct.dam = QueryDice(caster, "mercury", "charge") * 2
				var _froth_def = QueryDice(caster, "venus", "charge")
				if (_froth_def > 0) { struct.statuses.inflict_defdown = _froth_def }
			}
			break

		case "Fume":
			// Stage 1: flat 7
			// Stage 2 (Serpent Fume): sum of all Mars pips
			// Stage 3 (Dragon Fume): twice sum of all Mars pips
			if spell.stage == 1 {
				struct.dam = real(spell.damage)
			} else if spell.stage == 2 {
				struct.dam = QueryDice(caster, "mars", "values")
			} else {
				struct.dam = QueryDice(caster, "mars", "values") * 2
			}
			break

		case "Gaia":
			// Stage 1: Venus affinity to 3
			// Stage 2 (Mother Gaia): Venus affinity * 2
			// Stage 3 (Grand Gaia): Mother Gaia doubled again per extra charged Jupiter
			struct.dam = QueryDice(caster, "venus", "affinity")
			if spell.stage == 2 { struct.dam *= 2 }
			if spell.stage == 2 and QueryDice(caster,"jupiter","charge"){struct.num = 6}
			if spell.stage == 3{ struct.dam *= power(2,QueryDice(caster,"jupiter","charge")) }
			break

		case "Ice":
			// Stage 1: charged all * 1
			// Stage 2 (Ice Horn): charged Mercury * 2
			// Stage 3 (Ice Missile): charged all * 2
			if spell.stage == 1 {
				struct.dam = QueryDice(caster, "all", "charge")
			} else if spell.stage == 2 {
				struct.dam = QueryDice(caster, "mercury", "charge") * 2
			} else {
				struct.dam = QueryDice(caster, "all", "charge") * 2
			}
			break

		case "Prism":
			// Stages 1+2: highest Mercury pip + Jupiter affinity → lose turn
			// Stage 3 (Freeze Prism): top 2 Mercury pips
			if spell.stage < 3 {
				struct.dam = QueryDice(caster, "mercury", "highest")
				var _jup = QueryDice(caster, "jupiter", "charge")
				if _jup > 0 {
					struct.statuses.inflict_lose_turn = _jup
				}
			} else {
				struct.dam = 1
				struct.repeater = QueryDice(caster, "mercury", "highest") * 2
			}
			break

		case "Quake":
			// Stage 1: flat 3
			// Stage 2 (Earthquake): 3 + Venus affinity
			// Stage 3 (Quake Sphere): Venus affinity * 2 to 7
			if spell.stage == 1 {
				struct.dam = real(spell.damage)
			} else if spell.stage == 2 {
				struct.dam = 3 + QueryDice(caster, "venus", "affinity")
			} else {
				struct.num = 7
				struct.dam = QueryDice(caster, "venus", "affinity") * 2
			}
			break

		case "Ragnarok":
			// Stage 1: sum of all Venus pips
			// Stage 2 (Odyssey): ragnarok twice
			struct.dam = QueryDice(caster, "venus", "values")
			if spell.stage == 2 { struct.repeater=2}
			break

		case "Slash":
			// Stage 1: weapon attack, Normal type, ignores DEF
			// Stage 2+ (Wind Slash / Sonic Slash): Jupiter type, ignores DEF
			// Stage 3: Wind Slash × 2
			struct.dam = weapon_atk
			if spell.stage == 1 { struct.dmgtype = "normal" }
			if spell.stage == 3 { struct.dam *= 2 }
			if spell.stage >= 2 and QueryDice(caster,"mercury","charge") >= 2{struct.slash= true;struct.pierce= true }
			else{struct.pierce= true}
			break

		case "Spire":
			// Stage 1: charged all
			// Stage 2 (Clay Spire): charged Venus * 2
			// Stage 3 (Stone Spire): charged all * 2
			if spell.stage == 1 {
				struct.dam = QueryDice(caster, "all", "charge")
			} else if spell.stage == 2 {
				struct.dam = QueryDice(caster, "venus", "charge") * 2
			} else {
				struct.dam = QueryDice(caster, "all", "charge") * 2
			}
			break

		case "Thorn":
			// Stage 1: flat 2 to all
			// Stage 2 (Briar): charged Venus to all
			// Stage 3 (Nettle): charged all to all
			if spell.stage == 1 {
				struct.dam = 2
			} else if spell.stage == 2 {
				struct.dam = QueryDice(caster, "venus", "charge")
			} else {
				struct.dam = QueryDice(caster, "all", "charge")
			}
			break

		case "Volcano":
			// 4/6/10 base + Mars affinity
			var base_flat = 4
			if spell.stage == 2 { base_flat = 6 }
			else if spell.stage == 3 { base_flat = 10 }
			struct.dam = base_flat + QueryDice(caster, "mars", "affinity")
			break

		case "Whirlwind":
			
			// Stages 1+2: charged Jupiter * 2
			// Stage 3 (Tempest): charged Jupiter * 2 + charged non-Jupiter * 1
			
			struct.dam = QueryDice(caster, "jupiter", "charge") * 2
			if spell.stage == 3{
				struct.dam += QueryDice(caster, "all", "charge") - QueryDice(caster, "jupiter", "charge")
			}
			
			break

		// ── TIER 2: Dice-based healing ──────────────────────────────────────

		case "Aura":
			// Stage 1 (Aura): heal all for lowest Mars pip
			// Stage 2 (Healing Aura): lowest + highest Mars
			// Stage 3 (Cool Aura): (lowest + highest) * 2
			caster.pp -= _cost
			global.pendingPPCost = 0
			var aura_heal = QueryDice(caster, "mars", "lowest")
			if spell.stage >= 2 { aura_heal += QueryDice(caster, "mars", "highest") }
			if spell.stage == 3 { aura_heal *= 2 }
			
			struct.num = 4
			struct.healing = aura_heal
			struct.target = "ally"
			break

		case "Cure":
			// Heal caster + one selected ally
			// Stage 1: highest Venus pip
			// Stage 2 (Cure Well): top 2 Venus pips
			// Stage 3 (Potent Cure): top 2 Venus pips * 2
			var cure_heal = 0
			if spell.stage == 1      { cure_heal = QueryDice(caster, "venus", "highest") }
			else if spell.stage == 2 { cure_heal = QueryDice(caster, "venus", "top2") }
			else                     { cure_heal = QueryDice(caster, "venus", "top2") * 2 }
			struct.healing     = cure_heal
			struct.caster_heal = cure_heal   // applied on confirm, not eagerly
			struct.target = "ally"
			break

		case "Ply":
			// Heal one selected ally
			// Stage 1: highest Mercury pip
			// Stage 2 (Ply Well): top 2 Mercury pips
			// Stage 3 (Pure Ply): top 2 Mercury pips * 2
			var ply_heal = 0
			if spell.stage == 1      { ply_heal = QueryDice(caster, "mercury", "highest"); var _regen = 3; var _regheal = 3 }
			else if spell.stage == 2 { ply_heal = QueryDice(caster, "mercury", "affinity"); var _regen = 3; var _regheal = QueryDice(caster, "mercury", "affinity") }
			else                     { ply_heal = 9999; var _regen = 3; var _regheal = QueryDice(caster, "mercury", "affinity") }
			struct.healing = ply_heal
			struct.regen = _regen
			struct.regheal = _regheal
			struct.target = "ally"
			break

		case "Wish":
			// Stage 1 (Wish): heal all for highest Mercury
			// Stage 2 (Wish Well): highest Mercury + Mercury affinity
			// Stage 3 (Pure Wish): charged all * 2 + Mercury affinity
			caster.pp -= _cost
			global.pendingPPCost = 0
			var wish_heal = QueryDice(caster, "mercury", "highest")
			if spell.stage == 2 { wish_heal += QueryDice(caster, "mercury", "affinity") }
			if spell.stage == 3 { wish_heal = QueryDice(caster, "all", "charge") * 2 + QueryDice(caster, "mercury", "affinity") }
			struct.healing = wish_heal
			struct.num = 4
			struct.target = "ally"


			break

		case "Psy Drain":
			// Recover PP equal to charged die count + 1 (the +1 offsets the unavoidable min cost of 1)
			caster.pp -= _cost
			global.pendingPPCost = 0
			caster.pp = caster.pp + QueryDice(caster, "all", "charge") + 1
			if caster.pp >= caster.ppmax{caster.pp = caster.ppmax}
			NextTurn()
			exit
			break

		
		// Complex effects, status infliction, token manipulation, etc.

		case "Backstab":
			struct.dam += weapon_atk
			struct.dam += 2
			struct.dmgtype = "jupiter"
			if irandom(9) == 0{struct.dam = 9999}
			break// weapon attack + 2 Jupiter + d10 instakill
			
		case "Aegis":       // DEF up tokens per charged Venus die
			var aegis = QueryDice(caster,"venus","charge")
			struct.defup = aegis
			struct.atkup = aegis * -1
			struct.aegiscurse = (spell.stage == 1)
			if (spell.stage >= 2 && aegis == QueryDice(caster, "venus", "affinity")) { struct.atkup = 0 }
			struct.target = "ally"
			break
			
		case "Resonate":    // buff future spells until next turn
			var _venus_charge = QueryDice(caster, "venus", "charge")
			var _res_value = (spell.stage >= 2) ? _venus_charge : floor(_venus_charge / 2)
			if (_res_value < 1) { _res_value = 1 }
				PushMenu(objMenuDialog, {
				text:    "Resonate: Boost Range or Damage?",
				subtext: "(Value: +" + string(_res_value) + ")",
				buttons: [
					{
						label: "Range", sprite: Resonate,
						on_click: method({ val: _res_value, cd: 1, idx: playerID, nm: caster.name, cost: _cost }, function() {
							AddPassive("_Resonate", cd, Resonate, "Resonate", { mode: "range", amount: val }, idx)
							InjectLog(nm + " casts Resonate! (+" + string(val) + " range)")
							global.players[idx].pp -= cost
							global.pendingPPCost = 0
							PopMenu()
							NextTurn()
						})
					},
					{
						label: "Damage", sprite: Resonate,
						on_click: method({ val: _res_value, cd: 1, idx: playerID, nm: caster.name, cost: _cost }, function() {
							AddPassive("_Resonate", cd, Resonate, "Resonate", { mode: "damage", amount: val }, idx)
							InjectLog(nm + " casts Resonate! (+" + string(val) + " damage)")
							global.players[idx].pp -= cost
							global.pendingPPCost = 0
							PopMenu()
							NextTurn()
						})
					},
				],
			})
			exit
			break
		case "Root":        // DoT heal token
			if spell.stage == 1{var _root_amt = 3}else{var _root_amt = 6}// Stage 1 (Root): 3 root tokens on one ally
			// Stage 2 (Deep Root): 6 root tokens on one ally
			struct.rootTokens = _root_amt
			struct.target = "ally"
			break
			
		case "Revive":      // revive downed ally at end of round TODO: delay mechanic
			struct.target = "ally"
			struct.delayed = true
			struct.delaydata = {}
			struct.delaydata.healing = QueryDice(caster,"venus","affinity") * 2
			struct.delaydata.revive = true
			struct.revive = true
			break
		case "Djinn Echo":  // expand djinn target count
			AddPassive("_DjinnEcho", spell.stage + 1, Djinn_Echo, "Djinn Echo", {}, playerID)
			caster.pp -= _cost
			global.pendingPPCost = 0
			if (spell.stage >= 2) {
				// Stage 2+: unleash any djinn from any party member
				var _echo_items = []
				for (var _ep = 0; _ep < array_length(global.players); _ep++) {
					for (var _ed = 0; _ed < array_length(global.players[_ep].djinn); _ed++) {
						var _eid = global.players[_ep].djinn[_ed]
						var _edj = global.djinnlist[_eid]
						array_push(_echo_items, { name: _edj.name, detail: global.players[_ep].name, data: { djinnID: _eid, ownerIndex: _ep } })
					}
				}
				PopMenu()
				PushMenu(objMenuCarousel, {
					items:         _echo_items,
					confirm_label: "Unleash",
					filter:        method({ _ei: _echo_items }, function(i) { return !global.djinnlist[_ei[i].data.djinnID].ready and !global.djinnlist[_ei[i].data.djinnID].spent }),
					on_confirm:    method({ _pid: playerID }, function(i, item) {
						UnleashDjinn(item.data.djinnID, _pid)
					}),
				})
			} else {
				NextTurn()
			}
			exit
			break
		case "Planet Diver": // conditional Mars/Venus pip comparison
		if spell.stage == 1{
			if caster.venus and caster.mars{
				var tempdam =  QueryDice(caster,"venus","highest")
				tempdam += QueryDice(caster,"mars","highest")
				struct.dam += tempdam*2
			}else{struct.dam += QueryDice(caster,"elemental","top2")}
		}else{
			caster.pp -= _cost
			global.pendingPPCost = 0
			caster.halfheal = true
			caster.hp = 1
			caster.planetary = {active: true, damage: QueryDice(caster,"all","values")}
			if caster.venus == caster.mars{caster.planetary.damage *= 2}
			if irandom(1){caster.planetary.element = "venus"}else{caster.planetary.element = "mars"}
			InjectLog(caster.name + " begins charging!")
			NextTurn()
			exit
		}
			break
		case "Miracle":     // multi-element conditional effects
			global.attackQueue = []
			
		
			if caster.venus and QueryDice(caster,"venus","charge") > 0 {
				caster.defmod += QueryDice(caster,"venus","charge");
				InjectLog(caster.name + " Unleashes the power of Venus! (+" + string(QueryDice(caster,"venus","charge")) + " DEF)")}
			if caster.mars and QueryDice(caster,"mars","charge") > 0{
				struct.dam = QueryDice(caster,"mars","charge")
				struct.num = 3
				struct.dmgtype = "mars"
				array_push(global.attackQueue,variable_clone(struct));
				InjectLog(caster.name + " unleashes the power of Mars! (" + string(QueryDice(caster,"mars","charge")) + " Damage!)")}
			var select = irandom(4)
			switch select{
				case 0:
					struct.statuses.inflict_poison = true
					break
				case 1:
					struct.statuses.inflict_sleep = true
					break
				case 2:
					struct.statuses.inflict_stun = true
					break
				case 3:
					struct.statuses.inflict_delude = true
					break
				case 4: 
					struct.statuses.inflict_psyseal = true
					break
			}
			if caster.jupiter and QueryDice(caster,"jupiter","charge") > 0 {
				struct.dam = 0
				struct.num = QueryDice(caster,"jupiter","charge")
				struct.dmgtype = "jupiter"
				array_push(global.attackQueue,variable_clone(struct));
				InjectLog(caster.name + " unleashes the power of Jupiter! (" + string(QueryDice(caster,"jupiter","charge")) + " Enemies!)")}
			if caster.mercury and QueryDice(caster,"mercury","charge") > 0 {
				var _merc_packet = variable_clone(global.AggressionSchema)
				_merc_packet.source  = "psynergy"
				_merc_packet.healing = QueryDice(caster, "mercury", "charge")
				_merc_packet.target  = "ally"
				_merc_packet.num     = 1
				array_push(global.attackQueue, _merc_packet)
				InjectLog(caster.name + " unleashes the power of Mercury! (+" + string(QueryDice(caster,"mercury","charge")) + " HP)")}
			DestroyAllBut()
			ClearOptions()
			DeleteButtons()
			ProcessAttackQueue()
			exit
			break
		case "Plasma":      // pick N jupiter dice, each targets one enemy
		// Stages 1+2: player assigns individual Jupiter dice to individual targets
		// Stage 3 (Spark Plasma): highest Jupiter pip, scatters to random neighbors once per charged Jupiter die
		if spell.stage >= 3 {
			struct.dam           = QueryDice(caster, "jupiter", "highest")
			struct.repeater      = QueryDice(caster, "jupiter", "charge")
			struct.num           = 1
			struct.unleash       = { scatter: true, scatter_any: true }
		} else {
			var _plasma_num  = (spell.stage == 2) ? 5 : 3
			var _plasma_dice = BuildDiceArray(caster, "jupiter")
			var _plasma_max  = min(_plasma_num, instance_number(objMonster), array_length(_plasma_dice))
			PushMenu(objDicePicker, {
				dice:          _plasma_dice,
				max_select:    _plasma_max,
				confirm_label: "Assign",
				title:         "Pick " + string(_plasma_max) + " dice",
				on_confirm:    method({}, function(sel) {
					for (var _i = 0; _i < array_length(sel); _i++) {
						var _s = variable_clone(global.AggressionSchema)
						_s.source = "psynergy"; _s.dam = sel[_i].pip
						_s.num = 1; _s.dmgtype = "jupiter"; _s.target = "enemy"
						array_push(global.attackQueue, _s)
					}
					PopMenu()
					ClearOptions()
					ProcessAttackQueue()
				}),
			})
			exit
		}
		break
		case "Force":       // variable PP cost, user-selected elemental subset
			
			var _force_caster   = caster
			var _force_cost_per = _cost
			var _force_pips     = []
			for (var _fp = POOL_VENUS; _fp <= POOL_MERCURY; _fp++) {
				var _fd = _force_caster.dicepool[_fp]
				for (var _fi = 0; _fi < array_length(_fd); _fi++) { array_push(_force_pips, _fd[_fi]) }
			}
			array_sort(_force_pips, false)
			var _force_max  = min(array_length(_force_pips), floor(caster.pp / _force_cost_per))
			if _force_max <= 0 {
				InjectLog("Not enough PP for Force!")
				global.pendingPPCost = 0
				instance_create_depth(0, 0, 0, TurnDelay, {wait: 30})
				exit
				break
			}
			PushMenu(objMenuSlider, {
				minim:         1,
				maxim:         _force_max,
				value:         1,
				confirm_label: "Cast",
				label:   method({ cp: _force_cost_per, mx: _force_max }, function(v) {
					return "Dice to use: " + string(v) + " / " + string(mx) + "   PP cost: " + string(v * cp)
				}),
				preview: method({ pips: _force_pips }, function(v) {
					var _d = 0
					for (var _i = 0; _i < v; _i++) { _d += pips[_i] }
					return "Damage: " + string(_d)
				}),
				on_confirm: method({ pips: _force_pips, cp: _force_cost_per, pid: playerID }, function(v) {
					var _d = 0
					for (var _i = 0; _i < v; _i++) { _d += pips[_i] }
					global.pendingPPCost = v * cp
					var _s = variable_clone(global.AggressionSchema)
					_s.source  = "psynergy"
					_s.dam     = _d
					_s.num     = 1
					_s.dmgtype = "none"
					_s.target  = "enemy"
					PopMenu()
					SelectTargets(_s)
				}),
			})
			exit
			break
		case "Dull":        // ATK down 3 on enemies
			struct.statuses.inflict_atkdown= 3 
			struct.dam = 0
			break

		case "Ward":        // DEF up tokens on allies
			// Stage 1 (Ward): +3 DEF to one ally
			// Stage 2 (Resist): +3 DEF to all allies
			if (spell.stage >= 2) {
				caster.pp -= _cost
				global.pendingPPCost = 0
				for (var _wa = 0; _wa < array_length(global.players); _wa++) {
					if (global.players[_wa].hp > 0) {
						global.players[_wa].defmod += 3
					global.players[_wa].defmod_fresh = true
					}
				}
				InjectLog("All allies gain 3 DEF!")
				NextTurn()
				exit
				break
			}
			// Stage 1: target one ally
			struct.target = "ally"
			struct.defup = 3
			break

		case "Impact":      // ATK up tokens on allies
			// Stage 1 (Impact): +3 ATK to one ally
			// Stage 2 (High Impact): +3 ATK to all allies
			if (spell.stage >= 2) {
				caster.pp -= _cost
				global.pendingPPCost = 0
				for (var _ia = 0; _ia < array_length(global.players); _ia++) {
					if (global.players[_ia].hp > 0) {
						global.players[_ia].atkmod += 3
					global.players[_ia].atkmod_fresh = true
					}
				}
				InjectLog("All allies gain 3 ATK!")
				NextTurn()
				exit
				break
			}
			// Stage 1: target one ally
			struct.target = "ally"
			struct.atkup = 3
			break
		case "Halt":        // auto-prompted at boss phase start, not castable from menu
			InjectLog(spell.name + " activates automatically at the start of boss fights.")
			global.pendingPPCost = 0
			exit
			break
		case "Delude":      // inflict delusion on 3 opponents
			struct.dam = 0
			struct.statuses.inflict_delude= true
			break

		case "Sleep":       // inflict sleep on 3 opponents
			struct.dam = 0
			struct.statuses.inflict_sleep= true 
			break

		case "Burn Off":    // clear ATK/DEF tokens from allies
			// Stage 1 (Burn Off): one ally
			// Stage 2 (Burn Away): all allies
			if (spell.stage >= 2) {
				caster.pp -= _cost
				global.pendingPPCost = 0
				for (var _ba = 0; _ba < array_length(global.players); _ba++) {
					if (global.players[_ba].hp > 0) {
						global.players[_ba].atkmod = 0
						global.players[_ba].defmod = 0
					}
				}
				InjectLog("All stat changes cleared from party!")
				NextTurn()
				exit
				break
			}
			// Stage 1: target one ally
			struct.target = "ally"
			struct.removebuffs = true
			break
		case "Break":       // remove stat changes from enemy
			struct.statuses.inflict_clearstats= true
			struct.dam = 0
			break
		case "Restore":     // cure status conditions
			struct.removepoison = true
			struct.removebad = true
			if (spell.stage >= 2) {
				caster.pp -= _cost
				global.pendingPPCost = 0
				for (var _rs = 0; _rs < array_length(global.players); _rs++) {
					global.players[_rs].poison = false
					global.players[_rs].stun = 0
					global.players[_rs].sleep = false
					global.players[_rs].psyseal = false
					global.players[_rs].venom = false
				}
				InjectLog("All allies are cured!")
				NextTurn()
				exit
			}
			struct.target = "ally"
			break
		case "Catch":       // auto-prompted on combat victory, not castable from menu
			InjectLog(spell.name + " activates automatically after winning combat.")
			global.pendingPPCost = 0
			exit
			break
		case "Cloak":       // shield ally until next turn
			if global.inCombat {
				struct.cloak = true
				struct.target = "ally"
			}
			break
		case "Move":        // TODO: shuffle current puzzle
			if (!global.inCombat) {
				caster.pp -= _cost
				global.pendingPPCost = 0
				OnMove()
				exit
			}
			break
		case "Reveal":      // reveal extra cards on draw
			//cannot be cast
			break
		case "Retreat":     // reset floor to beginning
			if (!global.inCombat) {
				caster.pp -= _cost
				global.pendingPPCost = 0
				// Mark all challenges as incomplete
				for (var _ri = 0; _ri < array_length(global.floorChallenges); _ri++) {
					global.floorChallenges[_ri].completed = false
				}
				global.onFloor = false
				InjectLog(caster.name + " casts " + spell.name + "! The floor resets.")
				CreateOptions()
				exit
			}
			break
		case "Scoop":       // character skill (Felix)
			var _draw = DrawCard(caster)
			InjectLog("Felix roots around in the dirt for an item.")
			if _draw[1]{
				InjectLog("But he couldn't fit the " + _draw[0] + " in his pockets...")
			}else{ InjectLog("and found a " + _draw[0] + "!")}
			exit
			break
		case "Insight":     // character skill (Amiti)
		if (!global.inCombat) {
				caster.pp -= _cost
				global.pendingPPCost = 0
				DestroyAllBut()
				instance_create_depth(0,0,0,objInsightDisplay)
			}
			exit
			break
		default:
			show_debug_message("CastSpell: '" + spell.name + "' has no implementation yet")
			return
	}

	// Zodiac Wand unleash: when casting a spell that targets 3 enemies, inflict Delusion
	var _weapon_name = global.itemcardlist[caster.weapon].name
	if _weapon_name == "Zodiac Wand" and struct.num == 3 and struct.target == "enemy"{
		struct.statuses.inflict_delude = true
		InjectLog(caster.name + " unleashes Shining Star!")
	}

	// Resonate passive: boost multi-target spells
	if (struct.num > 1) {
		var _res = CheckPassive("_Resonate")
		if (_res != undefined) {
			if (_res.data.mode == "range") {
				struct.num += _res.data.amount
			} else if (_res.data.mode == "damage") {
				struct.dam += _res.data.amount
			}
		}
	}
	
	if struct.dam != 0 {struct.dam += (caster.atk + caster.atkmod) * caster.matk_ratio}
	if caster.name == "Lyza" and struct.dam == 0{struct.dam += caster.jupiter}
	
	// Offensive spell dispatch — dam is fully calculated above
	DeleteButtons()
	SelectTargets(struct)
}









