// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function OnUse(item,slot,player = -1){
	
	var _struct = variable_clone(global.AggressionSchema)
	_struct.itemid = slot
	
	if global.itemcardlist[item].onDraw{
		switch global.itemcardlist[item].name{
			case "Psynergy Stone":
				player.pp = player.ppmax
				InjectLog(player.name + " touches the stone and fills to maximum PP!")
				show_debug_message("psynergy stone")
				break
			case "10 Coins":
				global.gold += 10
				show_debug_message("Gold Increased 10 (" + player.name + ")")
				break
			case "20 Coins":
				global.gold += 20
				show_debug_message("Gold Increased 20 (" + player.name + ")")
				break
			case "30 Coins":
			    show_debug_message("Gold Increased 30 (" + player.name + ")")
				global.gold += 30
				break
			case "Summon Tablet":
				SummonDraft()
				break
			case "Elemental Star":
				DjinnDraft()
				break
		}
		exit
	}
	switch global.itemcardlist[item].name{
		case "Herb":
			_struct.healing = 3
			PushMenu(objMenuGrid, _BuildCharTargetConfig(_struct))
			break
		case "Nut":
			_struct.healing = 6
			PushMenu(objMenuGrid, _BuildCharTargetConfig(_struct))
			break
		case "Antidote":
			_struct.removepoison = true
			PushMenu(objMenuGrid, _BuildCharTargetConfig(_struct))
			break
		case "Psy Crystal":
			_struct.ppheal = 3
			PushMenu(objMenuGrid, _BuildCharTargetConfig(_struct))
			break
		case "Mist Potion":
			for (var i = 0; i < array_length(global.players); i++) {
				global.players[i].hp = global.players[i].hpmax
			}
			array_push(global.discard, global.players[global.turn].inventory[slot])
			array_delete(global.players[global.turn].inventory, slot, 1)
			PushMenu(objMenuGrid, { read_only: true, corner: "bottomright" })
			instance_create_depth(0, 0, 0, TurnDelay, { wait: 60, on_complete: NextTurn })
			exit
			break
		case "Potion":
			_struct.healing = 20
			PushMenu(objMenuGrid, _BuildCharTargetConfig(_struct))
			break
		case "Vial":
			_struct.healing = 10
			PushMenu(objMenuGrid, _BuildCharTargetConfig(_struct))
			break
		case "Water of Life":
			_struct.revive = true
			_struct.healing = 9999
			PushMenu(objMenuGrid, _BuildCharTargetConfig(_struct))
			break
		case "Oil Drop":
			array_push(global.discard, global.players[global.turn].inventory[slot])
			array_delete(global.players[global.turn].inventory, slot, 1)
			_struct.num = 12
			_struct.dam = QueryDice(player, "elemental", "charge") + 1
			_struct.dmgtype = "mars"
			global.pendingAnim = [{ type: "fire", element: "mars", fires_hit: true, stagger_damage: true, hit_delay: 60,
				rate: 2, width: 0.5, life: 40, life_var: 20, hold: 60, linger: 30,
				stagger: 20, shake: 2, shake_duration: 10,
				sub: [{ type: "flash", at: 1, hold: 30, element: "mars" }]
			}]
			SelectTargets(_struct)
			break
		case "Bramble Seed":
			array_push(global.discard, global.players[global.turn].inventory[slot])
			array_delete(global.players[global.turn].inventory, slot, 1)
			_struct.num = 12
			_struct.dam = QueryDice(player, "elemental", "charge") + 1
			_struct.dmgtype = "venus"
			global.pendingAnim = [{ type: "burst", element: "venus", fires_hit: true, stagger_damage: true,
				windup: true, count: 20, max_speed: 2, max_scale: 1, trail: 0, at_foot: true,
				stagger: 20, duration: 30, shake: 2, shake_duration: 10
			}]
			SelectTargets(_struct)
			break
		case "Crystal Powder":
			array_push(global.discard, global.players[global.turn].inventory[slot])
			array_delete(global.players[global.turn].inventory, slot, 1)
			_struct.num = 12
			_struct.dam = QueryDice(player, "elemental", "charge") + 1
			_struct.dmgtype = "mercury"
			global.pendingAnim = [{ type: "drizzle", element: "mercury", fires_hit: true, stagger_damage: true, hit_delay: 60,
				hold: 60, linger: 40, stagger: 20,
				splash: true, splash_rate: 2, splash_life: 12, splash_scl: 1, splash_delay: 25,
				clouds: true, cloud_height: 30, cloud_scl: 4, cloud_scl_var: 2, cloud_alpha: 0.8
			}]
			SelectTargets(_struct)
			break
		case "Weasel's Claw":
			array_push(global.discard, global.players[global.turn].inventory[slot])
			array_delete(global.players[global.turn].inventory, slot, 1)
			_struct.num = 12
			_struct.dam = QueryDice(player, "elemental", "charge") + 1
			_struct.dmgtype = "jupiter"
			global.pendingAnim = [{ type: "wind", element: "jupiter", fires_hit: true, stagger_damage: true, hit_delay: 30,
				hold: 40, stagger: 20, shake: 2, shake_duration: 10
			}]
			SelectTargets(_struct)
			break
		case "Smoke Bomb":
			array_push(global.discard, global.players[global.turn].inventory[slot])
			array_delete(global.players[global.turn].inventory, slot, 1)
			_struct.num = 3
			_struct.statuses = {inflict_delude: true}
			global.pendingAnim = [{ type: "cloud", element: "none", fires_hit: true, hit_delay: 50, spawn: 20 }]
			SelectTargets(_struct)
			break
		case "Sleep Bomb":
			array_push(global.discard, global.players[global.turn].inventory[slot])
			array_delete(global.players[global.turn].inventory, slot, 1)
			_struct.num = 3
			_struct.statuses = {inflict_sleep: true}
			global.pendingAnim = [{ type: "cloud", element: "none", fires_hit: true, hit_delay: 50, spawn: 20 }]
			SelectTargets(_struct)
			break
		case "Lucky Medal":
			for (var i = 0; i < array_length(global.players); i++) {
				global.players[i].extraTurns += 1
			}
			array_push(global.discard, global.players[global.turn].inventory[slot])
			array_delete(global.players[global.turn].inventory, slot, 1)
			PushMenu(objMenuGrid, { read_only: true, corner: "bottomright" })
			instance_create_depth(0, 0, 0, TurnDelay, { wait: 60, on_complete: NextTurn })
			break
	}
}