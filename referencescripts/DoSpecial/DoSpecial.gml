// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function DoSpecial(move, user){
	if move.name == "Mystic Call"{
		var revivecheck = true
		var index = 0
		var reviver = false
		while !revivecheck{
			if global.troop[index].monsterHealth == 0{
				revivecheck = true
				reviver = true
			}else{
				if index < array_length(global.troop) -1{
					index += 1
				}else{
					revivecheck = true
					reviver = false
				}
				
			}
		}
		
		if reviver{
			
			
			var ball = irandom(3) + 1
			var ballID = 0
			var ballname = ""
			var ballcolor = c_white
			
			switch ball{
				case 1:
					ballID = 11
					ballname = "Anger Ball"
					break
				case 2:
					ballID = 12
					ballname = "Guardian Ball"
					break
				case 3:
					ballID = 14
					ballname = "Refresh Ball"
					break
				case 4:
					ballID = 15
					ballname = "Thunder Ball"
					break
			}
			
			var mon = global.troop[index]
			
			mon.maxHealth = global.enemyIDs[# 2, ballID] * (global.healthcurse*10)
			mon.spHolder = global.enemyIDs[# 1, ballID]
			mon.enemyName = global.enemyIDs[# 0, ballID]
			mon.weakness = global.enemyIDs[# 6, ballID]
			mon.element = global.enemyIDs[# 7, ballID]
			mon.ID = ballID
			mon.sprite_index = asset_get_index(mon.spHolder)
	
			mon.monsterHealth = mon.maxHealth
			
			InjectLog([{word:"Star Magician calls on ",col: c_white}, {word: ballname, col: ballcolor}, {word: "!", col: c_white}])
			BattleLog("Slot " + string(global.troop[index].slotnum)	+ " // " + ballname +" appeared.")
			
			
			
		}else{
			InjectLog("Star Magician calls... But no one came!")
			BattleLog("Star Magician doesn't act.")
		}

	}
	
	if move.name == "Flee"{
		var fleechance = irandom(2)
		
		if fleechance == 0{
			InjectLog("Mimic runs away!")
			BattleLog("Mimic Flees.")
			
			mon.monsterHealth = -1
			mon.sprite_index = sprFled
			
		}else{
			InjectLog([{word: "Mimic attempts to flee...", col: c_white},{word: "But the party blocks the way!" ,col: global.c_important}])
			BattleLog("Mimic fails to flee.")
		}
	}
	
	
	
}