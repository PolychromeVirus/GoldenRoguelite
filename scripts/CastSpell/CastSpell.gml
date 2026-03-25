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
	struct.cast_name = caster.name + " casts " + spell.name + "!"
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
			if spell.stage == 2 {
				// Stage 2: one big bolt covers all targets simultaneously
				struct.anim = [{type: "sprite", element: "jupiter", spr: sprZap, blend: "add", hold: 20, fires_hit: true, sfx: ResoundingThunder, single_anim: true,
					sub: [
						{ type: "flash", at: 1, hold: 6, peak: 1, alpha: 0.5, shake: 8, shake_duration: 20 },
						{ type: "burst", at: "hit", at_foot: true, count: 60, trail: 0, max_speed: 5, max_scale: 1, shake: 3, shake_duration: 10, sfx: Explosion2 },
					]
				}]
			} else {
				struct.anim = [{type:"sprite", element:"jupiter", spr: sprZap, blend: "add", hold: 10, fires_hit: true, sfx: ResoundingThunder,
					stagger_damage: spell.stage == 3, stagger: 20,
					sub: [
						{ type: "flash", at: 1, hold: 6, peak: 1, alpha: 0.3 + spell.stage * 0.1, shake: 4 + spell.stage * 2, shake_duration: 20 },
						{ type: "burst", at: "hit", at_foot: true, rate: 1, trail: 0, count: 10 + spell.stage * 15, max_speed: 5, max_scale: 1 + spell.stage, shake: 1 + spell.stage, shake_duration: 10 },
					{ type: "sfx", sound: Explosion1, at: "hit" },
					]
				}]
			}
			break
		
		case "Flare":   // 5 / 10 / 15
		case "Ray":     // 3 / 8 / 12
			struct.dam = real(spell.damage)
			if spell.base == "Flare" {
				struct.anim = [{ type: "fire", element: "mars", fires_hit: true, sfx: FireSound, mode: "simultaneous", width: 0.5, life: 40, life_var: 20, scl_var: spell.stage, shake: spell.stage, shake_duration: 10, hold: 40 * spell.stage,
					sub: [
						{ type: "flash", at: 1, hold: 40 + spell.stage * 10, element: "mars" },
						{ type: "fire", at: 1, count: 8 + spell.stage * 4, element: "mars" },
					] }]
			} else {
				struct.anim = [{ type: "ray", element: "jupiter", fires_hit: true, start_sfx_gain: 0.2, sfx_start: ResoundingThunder, sfx_barrage_interval: 15, sfx_barrage: ProjectileHit, barrage_flash: true, hit_delay: 40,
					bolts: 3 + spell.stage * 2, spread: 12 + spell.stage * 4, bolt_w: spell.stage * 2 - 1,
					hold: 120 + spell.stage * 15, linger: 40, flicker: 2, drizzle: 1, bolt_delay: 18,
					cloud_height: 16, cloud_scl: 4 + spell.stage, cloud_scl_var: 2,
					shake: spell.stage, shake_duration: 10 }]
			}
			break

		case "Douse":   // 3 / 8 / 12
			struct.dam = real(spell.damage)
			struct.anim = [{ type: "drizzle", element: "mercury", fires_hit: true, sfx_barrage: ProjectileHit, sfx_barrage_interval: 20, barrage_flash: true, sfx_stop_start: true, hit_delay: 80, hold: 80 + spell.stage * 10, linger: 50,
				splash: true, splash_rate: 2, splash_life: 12, splash_scl: 1, splash_delay: 35,
				clouds: true, cloud_height: 30, cloud_scl: 4, cloud_scl_var: 2, cloud_alpha: 0.8 }]
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
			struct.anim = [{ type: "burst", element: "jupiter", fires_hit: true, sfx: Explosion1, windup: true, windup_duration: 30 * spell.stage,
				count: 25 + spell.stage * 15, max_speed: 3 + spell.stage, max_scale: spell.stage + 1,
				shake: 2 + spell.stage, shake_duration: 12 + spell.stage * 3 }]
			break

		case "Beam":
			// Stage 1: 1 per uncharged Mars + 2 per charged Mars
			// Stage 2+: 3 per charged Mars
			if spell.stage == 1 {
				struct.dam = QueryDice(caster, "mars", "uncharge") + (QueryDice(caster, "mars", "charge") * 2)
			} else {
				struct.dam = QueryDice(caster, "mars", "charge") * 3
			}
			
			var _core = 2 + spell.stage * 2     // stage 1: 8, stage 2: 12, stage 3: 16
			var _outer = _core + 6               // stage 1: 14, stage 2: 18, stage 3: 22
			struct.anim = [{ type: "pillar", element: "mars", mode: "stagger", stagger_damage: true, fires_hit: true, sfx: Explosion1, core_w: _core, outer_w: _outer, hold: 60, shake: 1 + spell.stage, shake_duration: 15,
				sub: { type: "burst", at: 20, count: 10 + struct.dam * 3, max_scale: spell.stage } }]
			
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
			struct.anim = [{ type: "burst", element: "mars", fires_hit: true, sfx: Explosion1, count: 20 + spell.stage * 20, windup: (spell.stage >= 2), shake: spell.stage * 2, shake_duration: 10 + spell.stage * 5,
				sub: (spell.stage >= 3) ? { type: "flash", at: "hit", hold: 10 } : undefined }]
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
			
			// Phase 1: quick flash + freeze all
			struct.anim = [{type:"flash", element:"mercury", 
				hold: 10, peak: 1, alpha: 0.9,
				freeze_target: true},
				{
					type: "wind",
					element:"mercury",
					rate: 4, amp: 12 + spell.stage * 4, osc_speed: 0.12 + spell.stage * 0.02,
					osc_y: 3 + spell.stage, spread_x: 6, spread_y: 3,
					life: 50 + spell.stage * 10, trail: 6, scl: 1, scl_var: spell.stage,
					hold: 10, linger: 40
					
				}]
			// Phase 2: frozen hold with random glints
			array_push(struct.anim,  {type: "flash", element: "mercury", 
				hold: 120 + spell.stage * 5, peak: 1, alpha: 0.0,
				glint: true, glint_interval: 6 + irandom(3)
			})
			// Phase 3: thin icy pillars — staggered per target
			var _core = 2 + spell.stage
			var _outer = _core + 3
			array_push(struct.anim, {type: "pillar", element: "mercury", fires_hit: true, sfx: WaveCrash, stagger_damage: true, unfreeze_target: true,
				core_w: _core, outer_w: _outer, hold: 30 + spell.stage * 5, fade: 0, linger: 20,
				stagger: 20, shake: 1 + spell.stage, shake_duration: 10
			})
			break

		case "Diamond Dust":
			// Stage 1: weapon attack as Mercury, half damage to neighbours
			// Stage 2 (Diamond Berg): weapon attack × 2, freeze → pillar shatter
			if spell.stage == 1 {struct.onConfirm.splash_ratio = 0.5
				struct.onConfirm.splash_element = "mercury"
				struct.onConfirm.splash_delay = 20}
			struct.dam = weapon_atk
			if spell.stage == 2 {
				struct.dam *= 2
				// Freeze target
				var _dd_core = 4
				var _dd_outer = 10
				struct.anim = [
					// Freeze target
					{ type: "flash", element: "mercury", hold: 8, peak: 1, alpha: 0.15,
					freeze_target: true },
					// Frozen hold with glints
					{ type: "flash", element: "mercury", hold: 60, peak: 1, alpha: 0.0,
					glint: true, glint_interval: 5 + irandom(3) },
					// Pillar shatter + burst
					{ type: "pillar", element: "mercury", fires_hit: true, sfx: WaveCrash, unfreeze_target: true,
					core_w: _dd_core, outer_w: _dd_outer, hold: 30, fade: 0, linger: 20,
					shake: 3, shake_duration: 12,
					sub: { type: "burst", at: "hit", count: 25, max_speed: 3, max_scale: 0, trail: 0 } }
				]
			}
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
			// Phase 1: mercury wind swirl, then freeze target
			struct.anim = [
				{ type: "wind", element: "mercury", overlap: true, rate: 3, amp: 10 + spell.stage * 3, osc_speed: 0.24 + spell.stage * 0.02,
				osc_y: 4 + spell.stage, spread_x: 4, spread_y: 6 + spell.stage * 3,
				life: 30 + spell.stage * 8, trail: 4, scl: 1, scl_var: spell.stage,
				hold: 10, linger: 10},
				{type: "flash", element: "mercury",alpha: 0, freeze_target: true, mode:"simultaneous", delay: 30},
				// Phase 2: frozen hold — white glint flashes on the frozen target
				{ type: "flash", element: "mercury", hold: 100 + spell.stage * 10, peak: 1, alpha: 0.0,
				glint: true, glint_interval: 10 },
				// Phase 3: shatter burst — unfreeze + damage (staggered per target)
				{ type: "burst", element: "mercury", fires_hit: true, sfx: WaveCrash, stagger_damage: true, unfreeze_target: true,
				count: 20 + spell.stage * 15, max_speed: 4 + spell.stage, max_scale: 1 + spell.stage,
				shake: 2 + spell.stage * 2, shake_duration: 12 + spell.stage * 3 }
			]
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
			var _struct = { fires_hit: true, sfx_barrage: ProjectileHit, sfx_barrage_interval: 20, barrage_flash: true, sfx_stop_start: true, hit_delay: 80, hold: 120, linger: 50, max_scale: 4, wiggle: 0.9, wiggle_spd: 0.1,
				splash: true, splash_rate: 2, splash_life: 12, splash_scl: 1, splash_delay: 35, drop_speed: 1, rate: 2, trail: 0,
				clouds: true, cloud_height: 30, cloud_scl: 4, cloud_scl_var: 2, cloud_alpha: 0.8,
				
			}
			if (struct.statuses[$ "inflict_defdown"] ?? 0) > 0 { StructMerge( _struct, { overlay_element: "venus", overlay_rate: 0.5 }) }
			_struct.type = "drizzle"
			_struct.element = "mercury"
			struct.anim = [_struct]
			
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
			
			struct.anim = [{ type: "meteor", element: "mars", fires_hit: true, sfx: FireSound,  power: struct.dam, no_burst: true, trail_life: 100, speed: 6, accel: 0.2, embers: false,
				impact_foot: true, fire: true, fire_rate: 3 + spell.stage * 2, fire_hold: 60 + spell.stage * 20,
				shake: 2 + spell.stage * 2, shake_duration: 15 + spell.stage * 5 }]
			
			break

		case "Gaia":
			// Stage 1: Venus affinity to 3
			// Stage 2 (Mother Gaia): Venus affinity * 2
			// Stage 3 (Grand Gaia): Mother Gaia doubled again per extra charged Jupiter
			struct.dam = QueryDice(caster, "venus", "affinity")
			if spell.stage == 2 { struct.dam *= 2 }
			if spell.stage == 2 and QueryDice(caster,"jupiter","charge"){struct.num = 6}
			if spell.stage == 3{ struct.dam *= power(2,QueryDice(caster,"jupiter","charge")) }
			
			var _shake = 2 + spell.stage * 2  // stage 1: 4, stage 2: 6, stage 3: 8
			var _open = 60
			struct.anim = [{ type: "fire", element: "venus", fires_hit: true, sfx_start: RumblingEarth, sfx_barrage: Damage2, sfx_barrage_interval:30, sfx_barrage_delay: _open, barrage_flash: true,
				rate: 0.5 + spell.stage * 0.5, hold: 120 + spell.stage * 30, hit_delay: 120 + spell.stage * 30,
				linger: 40 + spell.stage * 10, shake: _shake, shake_duration: 120 + spell.stage * 30,
				fissure: true, fissure_open: _open + 10, fissure_width: 1.2 + spell.stage * 0.2, }]
			
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
			var _ice_hold = 60 + spell.stage * 20
			struct.anim = [{ type: "drizzle", element: "mercury", fires_hit: true, sfx_barrage: ProjectileHit, sfx_barrage_interval: 10, barrage_flash: true, sfx_stop_start: true, hit_delay: _ice_hold + 30,
				rate: 1 + spell.stage * 4, hold: _ice_hold, linger: 60,
				grav: 0.02, scl: 1, scl_var: 0, life: 60 + spell.stage * 10, life_var: 20,
				splash: true, splash_rate: 1 + spell.stage * 2, splash_life: 8, splash_scl: 1, splash_delay: 30,
				clouds: true, cloud_height: 30, cloud_scl: 3 + spell.stage, cloud_scl_var: 2, cloud_alpha: 0.6 + spell.stage * 0.1,
				shake: spell.stage, shake_duration: 8 }]
			break

		case "Prism":
			// Stages 1+2: highest Mercury pip + Jupiter affinity → lose turn
			// Stage 3 (Freeze Prism): barrage of tiny meteors (1 dmg each, N hits)
			if spell.stage < 3 {
				struct.dam = QueryDice(caster, "mercury", "highest")
				var _jup = QueryDice(caster, "jupiter", "charge")
				if _jup > 0 {
					struct.statuses.inflict_lose_turn = _jup
				}
				var _prism_struct = { fires_hit: true, sfx: ProjectileHit, stagger_damage: true, power: 20 + spell.stage * 10,
					trail_life: 8, trail: 3, speed: 5, accel: 0.15, linger: 15, stagger: 8,
					shake: 2 + spell.stage, shake_duration: 10 + spell.stage * 3
				}
				if (struct.statuses[$ "inflict_lose_turn"] ?? 0) > 0 {
					_prism_struct.sub = { type: "flash", element: "jupiter", at: "hit", hold: 10 }
				}
				_prism_struct.type = "meteor"
				_prism_struct.element = "mercury"
				struct.anim = [_prism_struct]
			} else {
				struct.dam = 1
				var _hits = QueryDice(caster, "mercury", "highest") * 6
				struct.post_delay = 90
				struct.anim = [{ type: "meteor", element: "mercury", fires_hit: true, sfx_barrage: ProjectileHit, sfx_barrage_interval: 20, stagger_damage: true,
					barrage: _hits, power: 5, spread_x: 15,
					trail_life: 4, trail: 1, speed: 6, accel: 0.2, linger: 10, stagger: 20,
					count: 6, max_speed: 2, max_scale: 1,
					shake: 1, shake_duration: 5 }]
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
			var _qshake = 2 + spell.stage * 2
			var _shake_hold = 60 + spell.stage * 20
			struct.anim = [{ type: "fire", element: "venus", fires_hit: true, sfx_start: RumblingEarth, sfx: BigRockHit, sfx_stop_start: true, hit_delay: _shake_hold,
				rate: 2 + spell.stage, width: 0.8, life: 6, life_var: 4,
				scl: 1, scl_var: 0, grav: -0.01, trail: 0,
				hold: _shake_hold + 30, linger: 20,
				shake: _qshake, shake_duration: _shake_hold + 30,
				sub: [{ type: "burst", at: "hit", count: 10 + spell.stage * 6, max_speed: 2, max_scale: 1, trail: 0, at_foot: true }] }]
			break

		case "Ragnarok":
			// Stage 1: sum of all Venus pips
			// Stage 2 (Odyssey): ragnarok twice
			struct.dam = QueryDice(caster, "venus", "values")
			if spell.stage == 2 { struct.repeater=1}
			struct.anim = [{type:"sprite", element:"venus", mode:"sequence"  , spr: RagnarokSword, blend: "add", hold: 85,anim_loop:0, fires_hit: true, sfx: HugeExplosion,
				sub: [
					{ type: "flash", at: "hit", hold: 3, shake: 8, shake_duration: 35 },
					{ type: "flash", at: "hit", delay: 30, hold: 15 },
					{ type: "burst", at: "hit", delay: 40, at_foot: true, count: 120, max_scale: 4 },
				]
			}]
			if spell.stage == 2{ array_push(struct.anim, { anim_loop:1,type: "pillar", element: "venus", fires_hit: true, core_w: 2, outer_w: 1, hold: 30, sfx: HugeExplosion, sub:[
				{ type: "burst", at: "hit", at_foot: false, count: 120, max_scale: 4 }
				]} ) }
			break

		case "Slash":
			// Stage 1: weapon attack, Normal type, ignores DEF
			// Stage 2+ (Wind Slash / Sonic Slash): Jupiter type, ignores DEF
			// Stage 3: Wind Slash × 2
			struct.dam = weapon_atk
			if spell.stage == 1 { struct.dmgtype = "normal" }
			if spell.stage == 3 { struct.repeater = 1 }
			if spell.stage >= 2 and QueryDice(caster,"mercury","charge") >= 2{struct.slash= true;struct.pierce= true }
			else{struct.pierce= true}
			struct.anim = [{ type: "flash", element: spell.stage >= 2 ? "jupiter" : "none", fires_hit: true, sfx: MagicWeaponAttack, hold: 8, peak: 1, alpha: 1,
				shake: spell.stage, shake_duration: 8, anim_loop:0 }]
				
			if spell.stage == 3{ array_push(struct.anim, { type: "flash", element: "jupiter", fires_hit: true, sfx: MagicWeaponAttack, hold: 8, peak: 1, alpha: 1,
				shake: spell.stage, shake_duration: 8, anim_loop:1 }) }
				
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
			struct.anim = [{ type: "meteor", element: "venus", fires_hit: true, sfx: MagicWeaponAttack, stagger_damage: true, sfx_start: FallSound,
				speed: 3.5 + spell.stage * 0.5, power: 15 + spell.stage * 5,
				stagger: 10 + spell.stage * 3, linger: 20,
				trail_life: 8, trail: 3, accel: 0.06,
				no_burst: true, shake: 1 + spell.stage, shake_duration: 8,
				sub: [{ type: "burst", at: "hit", count: 8 + spell.stage * 3, max_speed: 2, max_scale: 1, trail: 0, at_foot: true }] }]
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
			// Spore cloud + tiny fire constant throughout, burst carries damage at end
			var _thorn_hold = 100 + spell.stage * 20
			struct.anim = [
				{ type: "cloud", element: "venus", persist: true, spawn: 30, count: 80 + spell.stage * 20, scl: 3 + spell.stage, scl_var: 2,
				cloud_hold: _thorn_hold, cloud_y: 85, alpha: 0.7 },
				// Fire overlaps cloud — tiny constant particles
				{ type: "fire", element: "venus", sfx_start: GrowthSound, overlap: true, mode: "simultaneous",
				rate: 1 + spell.stage * 0.5, life: 1.5, life_var: 0, width: 2, scl: 1, scl_var: 0, trail: 0,
				hold: _thorn_hold, linger: 0 },
				// Staggered bursts at the end carry damage
				{ type: "burst", element: "venus", fires_hit: true, sfx: Damage2, stagger_damage: true, at_foot: true, delay: 60,
				windup: false, count: 2 + spell.stage * 6, max_speed: 1.5, max_scale: 0, trail: 0, at_foot: true,
				stagger: 25, duration: 30 }
			]
			break

		case "Volcano":
			// 4/6/10 base + Mars affinity
			var base_flat = 4
			if spell.stage == 2 { base_flat = 6 }
			else if spell.stage == 3 { base_flat = 10 }
			struct.dam = base_flat + QueryDice(caster, "mars", "affinity")
			var _vcore = 12 + spell.stage * 8       // 20 / 28 / 36
			var _vouter = _vcore + 14 + spell.stage * 4 // 38 / 50 / 62
			var _ember_w = _vouter + 10 + spell.stage * 4  // embers wider than pillar
			struct.anim = [{ type: "pillar", element: "mars", fires_hit: true, sfx: (spell.stage >= 3) ? HugeExplosion : Explosion1, embers: true, fire_overlay: true, hit_delay: 15,
				core_w: _vcore, outer_w: _vouter, ember_w: _ember_w,
				fire_w: _vcore, fire_rate: 1 + spell.stage,
				ember_count: 3 + spell.stage * 2, ember_scl: spell.stage,
				ember_linger: 40,
				hold: 80 + spell.stage * 20, fade: 0, linger: 60,
				shake: 2 + spell.stage * 2, shake_duration: 15 + spell.stage * 5,
				sub: (spell.stage >= 2) ? { type: "burst", at: "hit", at_foot: true, count: 15 * spell.stage, max_scale: spell.stage } : undefined }]
			break

		case "Whirlwind":

			// Stages 1+2: charged Jupiter * 2
			// Stage 3 (Tempest): charged Jupiter * 2 + charged non-Jupiter * 1

			struct.dam = QueryDice(caster, "jupiter", "charge") * 2
			if spell.stage == 3{
				struct.dam += QueryDice(caster, "all", "charge") - QueryDice(caster, "jupiter", "charge")
			}
			struct.anim = [{ type: "wind", element: "jupiter", fires_hit: true, sfx: MagicSound, hit_delay: 40 + spell.stage * 10,
				rate: 2 + spell.stage * 2, amp: 12 + spell.stage * 4, osc_speed: 0.12 + spell.stage * 0.02,
				osc_y: 3 + spell.stage, spread_x: 6, spread_y: 8 + spell.stage * 4,
				life: 50 + spell.stage * 10, trail: 6, scl: 1, scl_var: spell.stage,
				hold: 80 + spell.stage * 20, linger: 40,
				shake: spell.stage, shake_duration: 10 }]
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
			var _pp_gain = QueryDice(caster, "all", "charge") + 1
			var _old_pp  = caster.pp
			caster.pp = min(caster.ppmax, caster.pp + _pp_gain)
			var _actual_gain = caster.pp - _old_pp
			if _actual_gain > 0 {
				var _ti    = global.turn
				var _colW  = (display_get_gui_width() - HUD_MARGIN - HUD_END_MARGIN) / array_length(global.players)
				var _num_x = HUD_MARGIN + _ti * _colW + HUD_PORTRAIT_OFFSET + HUD_PORTRAIT_SIZE / 2
				var _num_y = HUD_TOP_Y + HUD_PORTRAIT_OFFSET + HUD_PORTRAIT_SIZE / 2
				caster.heal_flash = 12
				instance_create_depth(0, 0, -200, objDamageNumber, {amount: _actual_gain, world_x: _num_x, world_y: _num_y, col: global.c_important, gui_mode: true})
			}
			PopAll()
			QueueAnim("flash", "none", noone, { fires_hit: false, hold: 40, peak: 3, alpha: 0.3 })
			PlayAnimation(function() {}, function() { MakeTurnDelay(30, NextTurn) })
			exit
			break


		// Complex effects, status infliction, token manipulation, etc.

		case "Backstab":
			struct.dam += weapon_atk
			struct.dam += 2
			struct.dmgtype = "jupiter"
			var _instakill = (irandom(9) == 0)
			if _instakill { struct.dam = 9999 }
			struct.anim = [{ type: "burst", element: "jupiter", fires_hit: true, sfx: MagicWeaponAttack, windup: false,
				count: _instakill ? 80 : 12, max_speed: _instakill ? 6 : 3, max_scale: _instakill ? 3 : 1,
				duration: 20, shake: _instakill ? 6 : 1, shake_duration: _instakill ? 25 : 8 }]
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
						label: "Range", sprite: Resonate, text: "Range", hovertext: "Range",
						on_click: method({ val: _res_value, cd: 1, idx: playerID, nm: caster.name, cost: _cost }, function() {
							AddPassive("_Resonate", cd, Resonate, "Resonate", { mode: "range", amount: val }, idx)
							InjectLog(nm + " casts Resonate! (+" + string(val) + " range)")
							global.players[idx].pp -= cost
							global.pendingPPCost = 0
							QueueAnim("flash", "venus", global.players[idx], { fires_hit: false })
							PlayAnimation(function() {}, function() {})
							PopMenu()
							NextTurn()
						})
					},
					{
						label: "Damage", sprite: Resonate, text: "Damage", hovertext: "Damage",
						on_click: method({ val: _res_value, cd: 1, idx: playerID, nm: caster.name, cost: _cost }, function() {
							AddPassive("_Resonate", cd, Resonate, "Resonate", { mode: "damage", amount: val }, idx)
							InjectLog(nm + " casts Resonate! (+" + string(val) + " damage)")
							global.players[idx].pp -= cost
							global.pendingPPCost = 0
							QueueAnim("flash", "venus", global.players[idx], { fires_hit: false })
							PlayAnimation(function() {}, function() {})
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
			QueueAnim("flash", "jupiter", caster, { fires_hit: false })
			PlayAnimation(function() {}, function() {})
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
				PushMenu(objMenuCarousel, {
					side: "right",
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
			struct.anim = [{ type: "meteor", element: "mars", fires_hit: true, sfx: HugeExplosion,  power: struct.dam * 3, shake: 3, shake_duration: 15 }]
		}else{
			caster.pp -= _cost
			global.pendingPPCost = 0
			caster.halfheal = true
			caster.hp = 1
			caster.planetary = {active: true, damage: QueryDice(caster,"all","values")}
			if caster.venus == caster.mars{caster.planetary.damage *= 2}
			if irandom(1){caster.planetary.element = "venus"}else{caster.planetary.element = "mars"}
			InjectLog(caster.name + " begins charging!")
			MakeTurnDelay(60,NextTurn)
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
				var _mars_pkt = variable_clone(struct)
				_mars_pkt.anim = [{ type: "pillar", element: "mars", fires_hit: true, sfx: BigRockHit, stagger_damage: true, stagger: 15,
					sub: [{ type: "burst", at: "hit", count: 10, max_speed: 2, max_scale: 1, trail: 0 }]
				}]
				array_push(global.attackQueue, _mars_pkt);
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
				var _jup_pkt = variable_clone(struct)
				_jup_pkt.anim = [{ type: "pillar", element: "jupiter", fires_hit: true, sfx: ResoundingThunder, stagger_damage: true, stagger: 15,
					sub: [{ type: "burst", at: "hit", count: 10, max_speed: 2, max_scale: 1, trail: 0 }]
				}]
				array_push(global.attackQueue, _jup_pkt);
				InjectLog(caster.name + " unleashes the power of Jupiter! (" + string(QueryDice(caster,"jupiter","charge")) + " Enemies!)")}
			if caster.mercury and QueryDice(caster,"mercury","charge") > 0 {
				var _merc_packet = variable_clone(global.AggressionSchema)
				_merc_packet.source  = "psynergy"
				_merc_packet.healing = QueryDice(caster, "mercury", "charge")
				_merc_packet.target  = "ally"
				_merc_packet.num     = 1
				array_push(global.attackQueue, _merc_packet)
				InjectLog(caster.name + " unleashes the power of Mercury! (+" + string(QueryDice(caster,"mercury","charge")) + " HP)")}
			
			
			
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
			struct.anim = [{ type: "burst", element: "jupiter", fires_hit: true, sfx: ResoundingThunder, windup: true, windup_duration: 6,
				count: 30 + struct.dam * 8, max_speed: 4 + struct.dam, max_scale: 3,
				stagger: 10, shake: 4 + struct.dam, shake_duration: 20 }]
		} else {
			var _plasma_num  = (spell.stage == 2) ? 5 : 3
			var _plasma_dice = BuildDiceArray(caster, "jupiter")
			var _plasma_max  = min(_plasma_num, instance_number(objMonster), array_length(_plasma_dice))
			var _plasma_stage = spell.stage
			PushMenu(objDicePicker, {
				dice:          _plasma_dice,
				max_select:    _plasma_max,
				confirm_label: "Assign",
				title:         "Pick " + string(_plasma_max) + " dice",
				on_confirm:    method({ _pstage: _plasma_stage }, function(sel) {
					for (var _i = 0; _i < array_length(sel); _i++) {
						var _pip = sel[_i].pip
						var _s = variable_clone(global.AggressionSchema)
						_s.source = "psynergy"; _s.dam = _pip
						_s.num = 1; _s.dmgtype = "jupiter"; _s.target = "enemy"
						_s.anim = [{ type: "burst", element: "jupiter", fires_hit: true, sfx: ResoundingThunder, windup: true, windup_duration: 6,
							count: 10 + _pip * 8, max_speed: 3 + _pip, max_scale: 1 + ceil(_pip / 2),
							stagger: 10, shake: 2 + _pip, shake_duration: 15
						}]
						array_push(global.attackQueue, _s)
					}
					PopAll()

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
					_s.source       = "psynergy"
					_s.dam          = _d
					_s.num          = 1
					_s.dmgtype      = "none"
					_s.target       = "enemy"
					_s.anim = [{ type: "burst", element: "none", windup: true, windup_duration: _d * 5,fires_hit: true, sfx: Explosion1 }]
					PopMenu()
					SelectTargets(_s)
				}),
			})
			exit
			break
		case "Dull":        // ATK down 3 on enemies
			struct.statuses.inflict_atkdown= 3
			struct.dam = 0
			struct.anim = [{ type: "flash", element: "jupiter", fires_hit: true, sfx: InflictStatus, hold: 30, peak: 3, alpha: 0.15,
				tint_target: c_red, tint_duration: 30,
				sub: [{ type: "burst", at: 1, count: 4, max_speed: 1.5, max_scale: 0, trail: 0, element: "jupiter" }] }]
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
			struct.anim = [{ type: "cloud", element: "jupiter", fires_hit: true, sfx: InflictStatus, hit_delay: 68, spawn: 30 }]
			break

		case "Sleep":       // inflict sleep on 3 opponents
			struct.dam = 0
			struct.statuses.inflict_sleep= true
			struct.anim = [{ type: "cloud", element: "jupiter", fires_hit: true, sfx: InflictStatus, hit_delay: 68, spawn: 30 }]
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
			struct.anim = [{ type: "burst", element: "mercury", count:4,windup: false }]
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
	
	SelectTargets(struct)
}









