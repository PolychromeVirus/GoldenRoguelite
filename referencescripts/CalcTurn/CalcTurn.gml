// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function CalcTurn(isBossTurn){
	if global.logchoice != "battle"{
		global.logchoice = "log"
	}
	
	var troop = global.troop
	var choice = 0
	var target = 0
	var statdecay = false
	var statdecayblock = false
	var monsters = array_length(troop)
	
	InjectLog("-----------")
	BattleLog("-----------")
	
	//decay def
	if isBossTurn{
		//bosses only
		for (var i=0; i<monsters; i+=1){
			if troop[i].boss and troop[i].def != 0{
				statdecay = true
				if troop[i].def > 0{troop[i].def -= 1}else{troop[i].def += 1}
			}
		}
		
	}else{
		//decay all enemies
		for (var i=0; i<monsters; i+=1){
			if troop[i].def != 0{
				statdecay = true
				if troop[i].def > 0{troop[i].def -= 1}else{troop[i].def += 1}
			}
		}
	}
	
	if statdecay{InjectLog("Enemy DEF Decayed!")}
	
	//main logic loop
	for(var curr = 0; curr<monsters;curr+=1){
		var act = true
		var choicestr = [{word: "", col: c_white}]
		var damstr = [{word: "", col: c_white}]
		var mon = troop[curr]
		
		//normal enemy does not act if it is a boss turn
		if isBossTurn and !mon.boss{act = false}
		
		//skip turn if enemy is dead
		if mon.monsterHealth == 0{act = false}
		
		if mon.miss{
			if act == true{InjectLog([{word: mon.enemyName + " is skipped!", col: global.c_status}]);}
			act = false
			mon.miss = false
		}
		
		//check if it acts through stun
		if mon.stun != 0 and act{
			if irandom(1) == 0{act=false
				InjectLog([{word: mon.enemyName + " is stunned!", col: global.c_status}])
				mon.stun -= 1}else{mon.stun -= 1}
		}
		
		//check if a sleeping enemy wakes up
		if mon.sleep == 1 and act{
			if irandom(1) == 0{act=false
				InjectLog([{word: mon.enemyName + " is asleep!", col: global.c_status}])}else{
				InjectLog([{word: mon.enemyName + " woke up!", col: global.c_status}])
				BattleLog([{word: mon.enemyName + " woke", col: global.c_status}])
				mon.sleep -= 1}
		}else if mon.sleep == 2 and act{
			act = false
			InjectLog([{word: mon.enemyName + " is sleeping deeply", col: global.c_status}])
			mon.sleep -= 1
		}
		
		var confusemove = []
		var confusestring = [{word: "", col: c_white}]
		
		//check if deluded
		if mon.del and act{
			if irandom(2) == 0{
				act = false
				confusestring = [{word: mon.enemyName + " is confused!", col: global.c_status}]
				
				for (var j=0;j<ds_grid_height(global.moveIDs);j+= 1){
					if global.moveIDs[# 0,j] == mon.enemyName{array_push(confusemove,j)}
				}
				
				
				choice = irandom(array_length(confusemove)-1)
				
				var con = confusemove[choice]
				var dam1=GetReal(global.moveIDs[# 3, con])
				var dam2=GetReal(global.moveIDs[# 4, con])
				var dam3=GetReal(global.moveIDs[# 5, con])
				var dam4=GetReal(global.moveIDs[# 6, con])
				var dam5=GetReal(global.moveIDs[# 7, con])
				var totdam = dam1 + dam2 + dam3+dam4+dam5
				damstr = string(totdam + global.damagecurse+mon.atk)
				
				var battchoice = ""
				
				if irandom(1) == 0{
					if mon.slotnum != 1 and troop[curr-1].monsterHealth != 0{
						choicestr = [{word: " to the enemy on their left!", col: global.c_status}]
						battchoice = [{word: "Enemy " + string(mon.slotnum-1) + " // ", col: c_white}]
					}else{
						choicestr = []
						battchoice = []
					}
				}else{
					if mon.slotnum != monsters and troop[curr+1].monsterHealth != 0{
						choicestr = [{word: " to the enemy on their right!", col: global.c_status}]
						battchoice = [{word: "Enemy " + string(mon.slotnum+1) + " // ", col: c_white}]
					}else{
						choicestr = []
						battchoice = []
					}
				}
				
				
				
				//print message to log about who got hit with confusion damage
				if array_length(choicestr)>=1{
					InjectLog(array_concat([{word : mon.enemyName + " does "}],[{word : string(totdam) + " damage", col : global.c_status}],choicestr))
				}
				else{
					InjectLog(array_concat([{word : mon.enemyName, col : c_white}],[{word: " misses!", col: global.c_status}]))
				}
				
				if array_length(battchoice)>=1{
					BattleLog(array_concat(battchoice,[{word : string(totdam) + " Damage", col : global.c_status}]))
				}
				else{
					BattleLog(array_concat([{word: mon.enemyName, col: c_white}],[{word : " does nothing.", col : global.c_status}]))
				}
				
			}
		}
		
		
			if act{
		
				var attacks = []
				var movecount = 1
				for(var j=0;j<ds_grid_height(global.moveIDs);j+=1){
					if global.moveIDs[# 0, j] == mon.enemyName{
					
						for (var k=0; k<global.moveIDs[# 2, j]; k+=1){
							var attstruct = {
					
								ID : j,
								number : movecount,
								name: global.moveIDs[# 1, j],
								vdam : GetReal(global.moveIDs[# 3, j]),
								madam : GetReal(global.moveIDs[# 4, j]),
								jdam : GetReal(global.moveIDs[# 5, j]),
								medam : GetReal(global.moveIDs[# 6, j]),
								dam : GetReal(global.moveIDs[# 7, j]),
								range : GetReal(global.moveIDs[# 8, j]),
								token : global.moveIDs[# 9, j],
								psy : global.moveIDs[# 10, j] == "TRUE",
								heal : global.moveIDs[# 11, j],
								double : global.moveIDs[# 12, j] == "TRUE",
								pierce : global.moveIDs[# 13, j] == "TRUE",
								amt : global.moveIDs[# 14, j],
								targ : GetReal(global.moveIDs[# 15, j]),
								special : global.moveIDs[# 16, j] == "TRUE"
					
							}
							array_push(attacks,attstruct)
							movecount += 1
						}
					}
				}
		
				var move = attacks[irandom(array_length(attacks)-1)]
				var moveroll = move.number
				
				if global.mud{
					
					if moveroll > 0{
						move = attacks[moveroll-1]
					}else{
						move = attacks[0]
					}
				}
				
				//if global.debug {InjectLog([{word: string(mon.enemyName) + " " + string(moveroll) + " / " + string(move.number) + " " + string(move.name), col: global.c_debug}])}
				
				if !move.special{
				
					var total = 0
					
					var textuse = {word: "", col: c_white}
					var textelem = {word: "", col: c_white}

					if move.psy and !mon.psy{
						textuse = {word: "casts", col: global.c_psynergy}
					}else{
						textuse = {word: "uses", col: c_white}
					}
					var damcol = global.c_damage
					if move.dam > 0{total += move.dam;textelem={word: " Normal Damage", col: global.c_normal};damcol = global.c_normal}
					if move.vdam > 0{total += move.vdam;textelem={word: " Venus Damage", col: global.c_venus};damcol=global.c_venus}
					if move.madam > 0{total += move.madam;textelem={word: " Mars Damage", col: global.c_mars}damcol = global.c_mars}
					if move.jdam > 0{total += move.jdam;textelem={word: " Jupiter Damage", col: global.c_jupiter}damcol = global.c_jupiter}
					if move.medam > 0{total += move.medam;textelem={word: " Mercury Damage", col: global.c_mercury}damcol = global.c_mercury}
					
					
					if move.dam < 0{
						var selfdam = abs(move.dam+global.damagecurse)
						if selfdam > mon.monsterHealth{
							mon.monsterHealth = 0
							mon.sprite_index = sprDeath
							
						}else{
							mon.monsterHealth -= selfdam
						}
						
					}
					
					total += global.damagecurse + mon.atk
					if move.pierce{
						if irandom(1) == 0{
							total = total*2
						}
					}
					var texttarget = ""
					var targets = ["1","2","3","4"]
					target = irandom(3) + 1
					array_delete(targets,target-1,1)
					var textmin = ""
					switch move.range{
						
						case 1:
							texttarget = "Player " + string(target)
							textmin = "Target " + string(target)
							break
						case 3:
							texttarget = "Players " + targets[0] + ", " + targets[1] + ", and " + targets[2]
							textmin = "Target " + targets[0] + " " + targets[1] + " " + targets[2]
							break
						case 4:
							texttarget = "All Players"
							textmin = "All"
							break
						case 0:
							texttarget = "Itself"
							textmin = "Self"
							break
						case -24:
							texttarget = "Its party"
							textmin = "Enemy Party"
							break
						case -3:
							texttarget = "Its allies"
							textmin = "Allies"
							break
						case -1:
							if troop[move.targ].monsterHealth > 0{
								texttarget = troop[move.targ].enemyName + " "
								textmin = "Target " + troop[move.targ].enemyName
							}else{
								texttarget = "No one"
								textmin = texttarget
							}
							break

					}
					var textend = ""
					var altend = []
						
					if move.pierce{textend += ", piercing defense"}
						
					if move.dam < 0{textend += " and damages itself"}
					
					var targ = string(texttarget)
					
					switch move.token{
						case "poi":
							textend += " and attempts to poison them!"
							altend = [{word: "Poison ", col: global.c_status},{word: "attempt", col: c_white}]
							break
						case "ven":
							textend += " and attempts to inflict venom on them!"
							altend = [{word: "Venom ", col: global.c_status},{word: "attempt", col: c_white}]
							break
						case "stun":
							textend += " and attempts to stun them!"
							altend = [{word: "Stun ", col: global.c_status},{word: "attempt", col: c_white}]
							break
						case "sleep":
							textend += " and attempts to put them to sleep!"
							altend = [{word: "Sleep ", col: global.c_status},{word: "attempt", col: c_white}]
							break
						case "psy":
							textend += " and attempts to seal their psynergy!"
							altend = [{word: "Psy Seal ", col: global.c_status},{word: "attempt", col: c_white}]
							break
						case "poi+":
							textend += " and poisons them!"
							altend = [{word: "Inflict ", col: c_white},{word: "Poison", col: global.c_status}]
							break
						case "ven+":
							textend += " and inflicts them with venom!"
							altend = [{word: "Inflict ", col: c_white},{word: "Venom", col: global.c_status}]
							break
						case "stun+":
							textend += " and stuns them!"
							altend = [{word: "Inflict ", col: c_white},{word: "Stun", col: global.c_status}]
							break
						case "sleep+":
							textend += " and puts them to sleep!"
							altend = [{word: "Inflict ", col: c_white},{word: "Sleep", col: global.c_status}]
							break
						case "psy+":
							textend += " and seals their psynergy!"
							altend = [{word: "Seal Psynergy", col: global.c_status}]
							break
						case "djinn":
							textend += " and puts one of their djinn in recovery!"
							altend = [{word: "Exhausts a djinni", col: c_white}]
							break
						case "djinn+":
							textend += "  and puts all of their djinn in recovery!"
							altend = [{word: "Exhausts all djinn", col: c_white}]
							break
						case "lose":
							textend += "  and makes them lose a turn!"
							altend = [{word: "Removes a Turn", col: c_white}]
							break
						case "bre":
							textend += "  and resets all stat buffs!"
							altend = [{word: "Removes all ATK and DEF tokens", col: c_white}]
							break
						case "defu":
							textend += " and increases DEF by " + string(move.amt)
							if move.range = 0{targ = "its"}else{targ += "'s"}
							altend = [{word: "Increases DEF by " + string(move.amt), col: c_white}]
							if move.range == 0{
								mon.def += GetReal(move.amt)
								statdecayblock = true
							}else if move.range == -3{
								for (var v=0;v<monsters;v+=1){
									if troop[v].slotnum != mon.slotnum{
										troop[v].def += GetReal(move.amt)
										
									}
								}
								statdecayblock = true
							}else if move.range == -24{
								for (var v=0;v<monsters;v+=1){
									troop[v].def += GetReal(move.amt)
								}
								statdecayblock = true
							}
							break
						case "defd":
							textend += " and decreases DEF by " + string(move.amt)
							altend = [{word: "Decreases DEF by " + string(move.amt), col: c_white}]
							break
						case "atku":
							textend += " and increases ATK by " + string(move.amt)
							if move.range = 0{targ = "its"}else{targ += "'s"}
							altend = [{word: "Increases ATK by " + string(move.amt), col: c_white}]
							if move.range == 0{
								mon.atk += GetReal(move.amt)
								statdecayblock = true
							}else if move.range == -3{
								for (var v=0;v<monsters;v+=1){
									if troop[v].slotnum != mon.slotnum{
										troop[v].atk += 1
										
									}
								}
								statdecayblock = true
							}else if move.range == -24{
								for (var v=0;v<monsters;v+=1){
									troop[v].atk += 1
								}
								statdecayblock = true
							}
							break
						case "atkd":
							textend += " and decreases ATK by " + string(move.amt)
							altend = [{word: "Decreases ATK by " + string(move.amt), col: c_white}]
							break
					
					}
					if move.heal != ""{
						if move.heal == "dam"{
							textend += " and recovers the damage done!"
							altend = [{word: ", Recovers damage", col: c_white}]
						}else{
							textend += "Heals " + string(move.heal)
							altend= [{word: textend, col: c_white}]
							if move.range == 0{mon.monsterHealth += move.heal}
							else if move.range == -3{
								for(v=0;v<monsters;v++){
									if troop[v].slotnum != mon.slotnum{
										if troop[v].monsterHealth - troop[v].maxHealth {troop[v].monsterHealth = troop[v].maxHealth}else{troop[v].monsterHealth += move.heal}
									}
								}
							}
							else if move.range == -24{
								for(v=0;v<monsters;v++){
									var temphealth = troop[v].monsterHealth
									var tempmax = troop[v].maxHealth
									if tempmax - temphealth < move.heal{temphealth = tempmax}else{troop[v].monsterHealth += GetReal(move.heal)}
								}
							}else if move.range == -1{
								var tempmax = troop[move.targ].maxHealth
								var temphealth = troop[move.targ].monsterHealth
								if tempmax - temphealth < move.heal{temphealth = tempmax}else{troop[move.targ].monsterHealth += GetReal(move.heal)}
							}
						}
					}
					
					var totaltext = string(total)
					
					if total == 0{totaltext = ""}
					
					var spacer = {word: "", col: c_white}
					
					while string_width(textmin + spacer.word) < 150{
						spacer.word += " "
					}
					
					var piercetext = {word: "", col: c_white}
					if move.pierce{piercetext.word = " PIERCING "}
					
					BattleLog(array_concat([{word: textmin, col: c_white},spacer,{word: " // ", col: c_white},piercetext,{word: totaltext + " ", col: damcol},textelem],[{word: " ", col: c_white}],altend))
					
					var first = []
					var second = []
					if move.range < 1 and move.range != -1{texttarget = string_lower(texttarget)}
					first = [{word: mon.enemyName + " ", col: c_white},textuse,{word: " " + move.name + "! ", col: c_white}]
					
					
					
					if total > 0{
						if move.token == ""{
							textend += "!"
							}
						second = [{word: "Does ", col: c_white},{word: string(total),col: damcol},textelem,{word: " to ", col: c_white},{word: texttarget, col: global.c_target},{word: textend, col: c_white}]
					}
				
					if total == 0 and move.heal != ""{
						second = [{word: "Heals ", col: c_white},{word: texttarget + " ", col: global.c_target},{word: string(move.heal), col: global.c_heal},{word: "!", col: c_white}]
					}
					if total == 0 and move.token != ""{
						second = array_concat([{word: mon.enemyName + " targets " + string(texttarget), col: c_white}],[{word: textend, col: c_white}])
					}
					
					var tester = ""
					for(var d=0;d<array_length(first);d+=1){
						tester += first[d].word
					}
					for(var d=0;d<array_length(second);d+=1){
						tester += second[d].word
					}
					
					if string_length(tester) > 59{
						InjectLog(first)
						InjectLog(array_concat([{word: "     ", col: c_white}],second))
					}else{
						InjectLog(array_concat(first,second))
					}
					
					if mon.monsterHealth == 0{InjectLog([{word: mon.enemyName, col: c_white},{word: " is downed.",col: global.c_downed}])}
					
					
				}else{
					DoSpecial(move, mon)
				}
		
		}
		









	}
	

	
}