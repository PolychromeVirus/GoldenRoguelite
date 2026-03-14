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
			instance_create_depth(0,TARGETHEIGHT,0,objCharTarget,_struct)
			break
		case "Nut":
			_struct.healing = 6
			instance_create_depth(0,TARGETHEIGHT,0,objCharTarget,_struct)
			break
		case "Antidote":
			_struct.removepoison = true
			instance_create_depth(0,TARGETHEIGHT,0,objCharTarget,_struct)
			break
		case "Psy Crystal":
			_struct.ppheal = 3
			instance_create_depth(0,TARGETHEIGHT,0,objCharTarget,_struct)
			break
		case "Mist Potion":
			for (var i = 0;i<array_length(global.players);i++){
				global.players[i].hp = global.players[i].hpmax
			}
			array_push(global.discard,global.players[global.turn].inventory[slot])
			array_delete(global.players[global.turn].inventory,slot,1)
			global.pause = false
			
			NextTurn()
			CreateOptions()
			exit
			break
		case "Potion":
			_struct.healing = 20
			instance_create_depth(0,TARGETHEIGHT,0,objCharTarget,_struct)
			break
		case "Vial":
			_struct.healing = 10
			instance_create_depth(0,TARGETHEIGHT,0,objCharTarget,_struct)
			break
		case "Water of Life":
			_struct.revive = true
			_struct.healing = 9999
			instance_create_depth(0,TARGETHEIGHT,0,objCharTarget,_struct)
			break
		case "Oil Drop":
			array_push(global.discard, global.players[global.turn].inventory[slot])
			array_delete(global.players[global.turn].inventory, slot, 1)
			_struct.num = 12
			_struct.dam = QueryDice(player, "elemental", "charge") + 1
			_struct.dmgtype = "mars"
			SelectTargets(_struct)
			break
		case "Bramble Seed":
			array_push(global.discard, global.players[global.turn].inventory[slot])
			array_delete(global.players[global.turn].inventory, slot, 1)
			_struct.num = 12
			_struct.dam = QueryDice(player, "elemental", "charge") + 1
			_struct.dmgtype = "venus"
			SelectTargets(_struct)
			break
		case "Crystal Powder":
			array_push(global.discard, global.players[global.turn].inventory[slot])
			array_delete(global.players[global.turn].inventory, slot, 1)
			_struct.num = 12
			_struct.dam = QueryDice(player, "elemental", "charge") + 1
			_struct.dmgtype = "mercury"
			SelectTargets(_struct)
			break
		case "Weasel's Claw":
			array_push(global.discard, global.players[global.turn].inventory[slot])
			array_delete(global.players[global.turn].inventory, slot, 1)
			_struct.num = 12
			_struct.dam = QueryDice(player, "elemental", "charge") + 1
			_struct.dmgtype = "jupiter"
			SelectTargets(_struct)
			break
		case "Smoke Bomb":
			array_push(global.discard, global.players[global.turn].inventory[slot])
			array_delete(global.players[global.turn].inventory, slot, 1)
			_struct.num = 3
			_struct.statuses = {inflict_delude: true}
			SelectTargets(_struct)
			break
		case "Sleep Bomb":
			array_push(global.discard, global.players[global.turn].inventory[slot])
			array_delete(global.players[global.turn].inventory, slot, 1)
			_struct.num = 3
			_struct.statuses = {inflict_sleep: true}
			SelectTargets(_struct)
			break
		case "Lucky Medal":
			for (var i = 0;i<array_length(global.players);i++){
				global.players[i].extraTurns += 1
			}
			NextTurn()
			break
	}
}