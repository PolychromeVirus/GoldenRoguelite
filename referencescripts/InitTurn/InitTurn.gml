function InitTurn(isBossTurn){
	if global.logchoice != "battle"{
		global.logchoice = "log"
	}

	var troop = global.troop
	var choice = 0
	var target = 0


	InjectLog("-----------")
	BattleLog("-----------")

	if global.mud == true{InjectLog("Mud is reducing attack rolls!")}

	var statdecay = false
	var statdecayblock = false
	if isBossTurn{
		for (var i=0; i<array_length(troop); i+=1){
			if troop[i].def != 0 and global.enemyIDs[# 3, troop[i].ID] == "TRUE"{
				if troop[i].def > 0 {troop[i].def -= 1}
				else if troop[i].def < 0 {troop[i].def += 1}
				statdecay = true
			}
		}
	}else{
		for (var i=0; i<array_length(troop); i+=1){
			if troop[i].def != 0{
				if troop[i].def > 0 {troop[i].def -= 1}
				else if troop[i].def < 0 {troop[i].def += 1}
				statdecay = true
			}
		}
	}
	
	
	

	if statdecay == true{InjectLog("Enemy DEF decayed!")}

	for (var i=0; i<array_length(troop); i+=1){
		//InjectLog("");
		var act = true
		var battlestring = ""
		var damagestring = ""
		if isBossTurn and global.enemyIDs[# 3, troop[i].ID] == "FALSE"{act = false}
		if troop[i].monsterHealth <= 0{act = false}
		if troop[i].miss == true and act == true{
			act = false
			if troop[i].monsterHealth > 0{InjectLog(troop[i].enemyName + " is skipped!"); BattleLog(troop[i].enemyName + " doesn't act.")}
			troop[i].miss = false
		}
		if troop[i].stun > 0 and act == true{
			var rand = random(1)
			if rand < 0.5{act = false
				InjectLog(troop[i].enemyName + " is stunned!"); BattleLog(troop[i].enemyName + " doesn't act.")}
			troop[i].stun -= 1
		}
		if troop[i].sleep == 1 and act == true{
			var rand = random(1)
			if rand < 0.5{act = false
				InjectLog(troop[i].enemyName + " is asleep!"); BattleLog(troop[i].enemyName + " doesn't act.")}
				else{troop[i].sleep = 0
					InjectLog(troop[i].enemyName + " woke up!")}
		
		}
		if troop[i].sleep == 2 and act == true{
			var rand = random(1)
			act = false
			InjectLog(troop[i].enemyName + " is sleeping deeply!"); BattleLog(troop[i].enemyName + " doesn't act.")
			troop[i].sleep = 1
		}
		if troop[i].del == true and act == true{
			var rand = random(1)
			if rand < 0.33{
				act = false
				var confusestring = troop[i].enemyName + " is confused! "
			
				var confuse = []
			
				for (var j=0; j<ds_grid_height(global.moveIDs); j+=1){
					if global.moveIDs[# 0, j] == troop[i].enemyName{
							for (var k=0; k<global.moveIDs[# 2, j]; k+=1){
								array_push(confuse,j)
							}
			
					}	
				}
	
				choice = floor(random(array_length(confuse)))
				if choice == array_length(confuse){
					choice -= 1
				}
			
				var move = confuse[choice]
			
				var dam1=0, dam2=0, dam3=0, dam4=0, dam5=0
			
				if global.moveIDs[# 3, move] != "" and real(global.moveIDs[# 3, move]) > 0{
					dam1 = real(global.moveIDs[# 3, move])
				}
				if global.moveIDs[# 4, move] != "" and real(global.moveIDs[# 4, move]) > 0{
					dam2 = real(global.moveIDs[# 4, move])
				}
				if global.moveIDs[# 5, move] != "" and real(global.moveIDs[# 5, move]) > 0{
					dam3 = real(global.moveIDs[# 5, move])
				}
				if global.moveIDs[# 6, move] != "" and real(global.moveIDs[# 6, move]) > 0{
					dam4 = real(global.moveIDs[# 6, move])
				}
				if global.moveIDs[# 7, move] != "" and real(global.moveIDs[# 7, move]) > 0{
					dam5 = real(global.moveIDs[# 7, move])
				}
				var totdam = dam1 + dam2 + dam3+dam4+dam5
				rand = random(1)
				var trapdamage = 0
				totdam += global.damagecurse+trapdamage+troop[i].atk
				if rand < 0.5{
					if i > 0{
						InjectLog(confusestring + string(totdam) + " to the enemy on their left!"); BattleLog(confusestring + string(totdam))
					}else{InjectLog(confusestring); BattleLog(confusestring);}
				}else{
					if i < array_length(troop)-1{
						InjectLog(confusestring + string(totdam) + " to the enemy on their right!")
					}else{InjectLog(confusestring); BattleLog(confusestring + string(totdam))}
				}
			}else{
		
				//rand = random(1)
				//if rand > 0.5{
				//	troop[i].del = false
				//	BattleLog(troop[i].enemyName + " snapped out of its delusion!")
				//}
		
			}
		
		}
	
	
		if act{
			var trapdamage = 0
		
			battlestring += troop[i].enemyName
	
			var attacks = []
	
			for (var j=0; j<ds_grid_height(global.moveIDs); j+=1){
				//var select = true;
				//if global.moveIDs[# 10, j] == "TRUE" and troop[i].psy == true{select = false}
				if global.moveIDs[# 0, j] == troop[i].enemyName{
					for (var k=0; k<global.moveIDs[# 2, j]; k+=1){
						array_push(attacks,j)
					}
			
				}
			}
			var actualroll = 0
			var select = false
			while select == false{
				select = true
				choice = floor(random(array_length(attacks)))
				actualroll = choice + 1
				if choice == array_length(attacks){
					select = false
				}
				if global.mud == true and choice != 0{
					choice -= 1
				}
				if global.moveIDs[# 10, attacks[choice]] == "TRUE" and troop[i].psy == true{select = false}
			}
		
			var move = attacks[choice]
			var mudtext = ""
			if global.mud = true{mudtext = "(" + string(actualroll) + ") "}
		
			var vdam=0,madam=0,jdam=0,medam=0,dam=0
			
			if global.moveIDs[# 13, move] == "TRUE"{
				var pierce = true
			}else{var pierce = false}
			
			var attack = global.moveIDs[# 1, move]
			if global.moveIDs[# 3, move] != ""{
				vdam = real(global.moveIDs[# 3, move])
			}
			if global.moveIDs[# 4, move] != ""{
				madam = real(global.moveIDs[# 4, move])
			}
			if global.moveIDs[# 5, move] != ""{
				jdam = real(global.moveIDs[# 5, move])
			}
			if global.moveIDs[# 6, move] != ""{
				medam = real(global.moveIDs[# 6, move])
			}
			if global.moveIDs[# 7, move] != ""{
				dam = real(global.moveIDs[# 7, move])
			}
			var range = global.moveIDs[# 8, move]
			var token = global.moveIDs[# 9, move]
			var psy = global.moveIDs[# 10, move]
			var heal = global.moveIDs[# 11, move]
			var double = global.moveIDs[# 12, move]
			var totdam = 0
			if vdam > 0{ totdam += vdam}
			if madam > 0{ totdam += madam}
			if jdam > 0{ totdam += jdam}
			if medam > 0{ totdam += medam}
			if dam > 0{ totdam += dam}
			if attack == "Flee"{
				battlestring = troop[i].enemyName + " attempts to flee... "
				var fleechance = random(1)
				if fleechance > 0.66{
					battlestring += "And succeeds!"
					troop[i].monsterHealth = -1
					troop[i].sprite_index = sprFled
			
				}else{
					battlestring += "And fails!"
				}
			}else if attack == "Mystic Call"{
				var dead = troop[i].slotnum
				for (var d=0; d<array_length(troop)-1; d+=1){
					if troop[d].monsterHealth == 0{dead = troop[d].slotnum - 1}
				}
				if dead != troop[i].slotnum{
					battlestring = troop[i].enemyName + " calls an orb to replace " + troop[dead].enemyName + "!"
					var deadshort = "Replaces " + troop[dead].enemyName
				}else{
					battlestring = troop[i].enemyName + " has no one to call!"
					var deadshort = "Mystic Call fizzles."
				}
			}else{
				if psy == "TRUE" and troop[i].psy == false{
					battlestring = battlestring + " casts " + mudtext + string(choice+1) + ": " + attack + "! "
				}
				else{
					battlestring = battlestring + " uses " + mudtext + string(choice+1) + ": " + attack + "! "
				}
			
				//}else if psy == "TRUE" and troop[i].psy = true{
				//	battlestring = battlestring + " attempts to cast " + attack + " but it fizzles... "
				//	totdam = 0
				//	token = ""
				//}
				totdam += global.damagecurse+trapdamage+troop[i].atk
				if double == "TRUE"{
		
					var chance = random(1)
				
					if chance >= 0.5{
					
						totdam *= 2
					}
				}
			
				//BattleLog(battlestring);
				//battlestring = "     ";

				var damagestring = ""
	
				if vdam > 0{
					damagestring = damagestring + string(totdam) + " Venus damage to "
				}
				if madam > 0{
					damagestring = damagestring + string(totdam) + " Mars damage to "
				}
				if jdam > 0{
					damagestring = damagestring + string(totdam) + " Jupiter damage to "
				}
				if medam > 0{
					damagestring = damagestring + string(totdam) + " Mercury damage to to "
				}
				if dam > 0{
					damagestring = damagestring + string(totdam) + " damage to "
				}
				if dam < 0{
					//damagestring += " + " + string(abs(dam)) + " self damage "
					if abs(dam+global.damagecurse+trapdamage) > troop[i].monsterHealth{
						troop[i].monsterHealth = 0
						troop[i].sprite_index = sprDeath
						InjectLog(troop[i].enemyName + " dies!")
					}else{
						troop[i].monsterHealth -= abs(dam+global.damagecurse+trapdamage)
					}
				}
				if (vdam + madam + jdam + medam + dam) == 0{
					damagestring += "Targets "
				}
	
				var target = floor(random(4)+1)
				if target == 5{
					target -= 1
				}
				if vdam + madam + jdam + medam + dam >= 0{
					switch range{
						case 1:
						damagestring = damagestring + "player " + string(target)
						break
						case 3:
						var targets = []
						for (var t=1;t<5;t+=1){
							if t != target{
								array_push(targets, t)
							}
						}
						damagestring = damagestring + "players " + string(targets[0]) + ", " + string(targets[1]) + ", and " + string(targets[2])
		
						break
						case 4:
						damagestring += "all players "
						break
						case 0:
						damagestring = damagestring + "itself"
						break
						case -24:
						damagestring = damagestring + "its party"
						break
						case -3:
						damagestring = damagestring + "its allies"
						break
						case -1:
						if global.moveIDs[# 15, move] < array_length(troop) - 1{
							damagestring = damagestring + troop[global.moveIDs[# 15, move]].enemyName
						}else{
							damagestring = damagestring + "no one"
						}
						break
					}
				}
				if dam < 0{damagestring += "and damages itself"}
				if global.moveIDs[# 13, attacks[choice]] == "TRUE" {damagestring += ", piercing DEF"
					if token != "" {damagestring += ","}}
				
				var amt = real(global.moveIDs[# 14, move])
				
				switch token{
					case "poi":
						damagestring += " and attempts to poison them"
						break
					case "ven":
						damagestring += " and attempts to inflict them with venom"
						break
					case "defu":
						damagestring += " and creates " + string(amt) + " defense up token(s)"
						if abs(real(range)) > 3{
							for (var r = 0; r < array_length(troop); r+=1) {
								troop[r].def+=amt
								statdecayblock = true
							}
						}else if abs(real(range)) == 0{
							troop[i].def+=amt
							statdecayblock = true
						}else{
							for (var r = 0; r < array_length(troop); r+=1) {
								if troop[r].slotnum != troop[i].slotnum {
									troop[r].def+=amt
									statdecayblock = true
								}
							}
						}
						break
					case "defd":
						damagestring += " and creates " + string(amt) + " defense down token(s)"
						break
					case "atku":
						damagestring += " and creates " + string(amt) + " attack up token(s)"
						if abs(real(range)) > 1{
							for (var r = 0; r < array_length(troop); r+=1) {
								troop[r].atk+=amt
								statdecayblock = true
							}
						}else{troop[i].atk+=amt
							statdecayblock = true}
						break
					case "atkd":
						damagestring += " and creates " + string(amt) + " attack down token(s)"
						break
					case "sleep":
						damagestring += " and attempts to put them to sleep"
						break
					case "sleep+":
						damagestring += " and puts them to sleep"
						break
					case "stun":
						damagestring += " and attempts to stun them"
						break
					case "stun+":
						damagestring += " and stuns them"
						break
					case "psy":
						damagestring += " and attempts to seal their psynergy"
						break
					case "psy+":
						damagestring += " and seals their psynergy"
						break
					case "bre":
						damagestring += " and removes all buffs on them"
						break
					case "lose":
						damagestring += " and makes them lose their next turn"
						break
					case "djinn":
						damagestring += " and resets their djinn"
						break
					case "djinn+":
						damagestring += " and resets all their djinn"
						break
				}
				if heal != ""{
					damagestring += " and heals "
					var temp = 0
					if heal == "dam"{
						temp = totdam
					}else{
						temp = real(heal)
					}
					if temp > (troop[i].maxHealth - troop[i].monsterHealth){
						//troop[i].monsterHealth = troop[i].maxHealth
					}else{
						//troop[i].monsterHealth += temp
					}
					damagestring += string(temp)
				}
		
			}
			if string_length(damagestring + battlestring) > 59{
				InjectLog(battlestring)
				InjectLog("     " + damagestring + "!")
			}else{
				InjectLog(battlestring + damagestring + "!")
			}
			
			var battleend = ""
			var duplicate = false
			var infix = " // "
			
			if vdam > 0{battleend += "Venus";duplicate = true}
			if madam > 0 and !duplicate{battleend += "Mars";duplicate = true}else if madam > 0 and duplicate{battleend += ", Mars"}
			if jdam > 0 and !duplicate{battleend += "Jupiter";duplicate = true}else if jdam > 0 and duplicate{battleend += ", Jupiter"}
			if medam > 0 and !duplicate{battleend += "Mercury"}else if medam > 0 and duplicate{battleend += ", Mercury"}
			
			if battleend == "" and totdam > 0{battleend += "Normal"}else if battleend == "" and totdam == 0{battleend += ""}
			
			if heal != "" {battleend += infix + "Heal " + heal}
			
			switch token{
					case "poi":
						battleend += infix + "Poison Attempt"
						break
					case "ven":
						battleend += infix + "Venom Attempt"
						break
					case "defu":
						battleend += infix + "+" + string(amt) + " DEF"
						break
					case "defd":
						battleend += infix + "-" + string(amt) + " DEF"
						break
					case "atku":
						battleend += infix + "+" + string(amt) + " ATK"
						break
					case "atkd":
						battleend += infix + "-" + string(amt) + " ATK"
						break
					case "sleep":
						battleend += infix + "Sleep Attempt"
						break
					case "sleep+":
						battleend += infix + "Sleep"
						break
					case "stun":
						battleend += infix + "Stun Attempt"
						break
					case "stun+":
						battleend += infix + "Stun"
						break
					case "psy":
						battleend += infix + "Psy Seal Attempt"
						break
					case "psy+":
						battleend += infix + "Psy Seal"
						break
					case "bre":
						battleend += infix + "ATK/DEF set to 0"
						break
					case "lose":
						battleend += infix + "Lose Turn"
						break
					case "djinn":
						battleend += infix + "Djinn Recovery"
						break
					case "djinn+":
						battleend += infix + "All Djinn Recovery"
						break
				}
				
				if pierce{battleend += " PIERCE"}
				
				var battledam = ""
				var battletarget1 = string(target)
				var battletarget2 = "2"
				var battletarget3 = "3"
				
				if target == 1 and range == 1{battletarget1 = " 1"}
				if range == 3{
					battletarget1 = string(targets[0]);
					battletarget2 = string(targets[1]);
					battletarget3 = string(targets[2]);
					}
				if battletarget1 == "1"{battletarget1 = " 1"}
				if battletarget2 == "1"{battletarget2 = " 1"}
				if battletarget3 == "1"{battletarget3 = " 1"}
				if totdam > 0 {battledam = string(totdam) + " "}else{infix = ""}
				
				if attack != "Flee" and attack != "Mystic Call"{
					if range == 1{BattleLog("Target " + battletarget1 + "          " + infix + battledam + battleend)}
					else if range == 3{BattleLog("Target " + battletarget1 + "  " + battletarget2 + "  " + battletarget3 + infix + battledam + battleend)}
					else if range == 4{BattleLog("Target All     " + infix + battledam + battleend)}
					else if range == 0{BattleLog(string(troop[i].slotnum) + ": " + troop[i].enemyName + battleend)}
					else if range == -24{BattleLog("Enemy Party" + battleend)}
					else if range == -3{BattleLog("Enemy's Allies" + battleend)}
					else if range == -1{BattleLog(troop[global.moveIDs[# 15, move]].enemyName + battleend)}
				}else{
					if attack == "Flee"{
						if troop[i].sprite_index == sprFled{BattleLog(troop[i].enemyName + " fled.")}else{
							BattleLog(troop[i].enemyName + " attempted to flee.")
						}
					}else if attack == "Mystic Call"{
						BattleLog(deadshort)
					}
				}
		
		
		}
		if troop[i].poi == true and troop[i].monsterHealth > 0{
			//troop[i].monsterHealth -= 1
			InjectLog("     " + troop[i].enemyName + " took damage from poison")
			if troop[i].monsterHealth == 0{troop[i].sprite_index = sprDeath}
		}
	}

	statdecay = false

	for (var i=0; i<array_length(troop); i+=1){
		if troop[i].atk != 0 and statdecayblock == false{
			if troop[i].atk > 0 {troop[i].atk -= 1}
			else if troop[i].atk < 0 {troop[i].atk += 1}
			statdecay = true
		}
	}

	if statdecay == true and statdecayblock == false{InjectLog("Enemy ATK decayed!")}
}