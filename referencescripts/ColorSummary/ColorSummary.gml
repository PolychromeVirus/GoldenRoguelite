// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function ColorSummary(mon){
	var moves = GetMoves(mon.ID)
	
	ClearLog(global.summlog)
	var elcolor = c_white
	var weacolor = c_white
	
	if mon.element == "Venus"{
		elcolor = global.c_venus
	}
	if mon.element == "Mars"{
		elcolor = global.c_mars
	}
	if mon.element == "Jupiter"{
		elcolor = global.c_jupiter
	}
	if mon.element == "Mercury"{
		elcolor = global.c_mercury
	}
	if mon.weakness == "Venus"{
		weacolor = global.c_venus
	}
	if mon.weakness == "Mars"{
		weacolor = global.c_mars
	}
	if mon.weakness == "Jupiter"{
		weacolor = global.c_jupiter
	}
	if mon.weakness == "Mercury"{
		weacolor = global.c_mercury
	}
	
	
	SummLog("----------")
	if mon.boss{SummLog([{word: "BOSS ", col: global.c_mars}, {word: "| " + mon.enemyName, col: c_white}])}else{SummLog([{word: mon.enemyName, col: c_white}])}
	
	if mon.monsterHealth > 0{
		var barsize = 10
		
		if mon.maxHealth > 10{barsize = 20}
		if mon.maxHealth > 20{barsize = 30}
		if mon.maxHealth >= 60{barsize = 50}
		if mon.maxHealth >= 150{barsize = 70}
		if mon.maxHealth >= 250{barsize = 100}
		
		var temphealth = round((mon.monsterHealth/mon.maxHealth)*barsize)
		var healthcolor = c_lime
		var HPstring = []
		var barslices = barsize/10
		if temphealth <= barslices*7{healthcolor = c_yellow}
		if temphealth <= barslices*5{healthcolor = c_orange}
		if temphealth <=barslices*2{healthcolor = c_red}
			
		for(var i=0;i<temphealth;i++){
			array_push(HPstring, {word:"|", col: healthcolor})
		}
		for(var j=0;j<barsize-temphealth;j++){
			array_push(HPstring, {word:" ", col: c_white})
		}
			
		SummLog(array_concat([{word: "[", col: c_white}],HPstring,[{word: "]", col: c_white}]))
	}else if mon.monsterHealth == 0{
		SummLog(array_concat([{word: "[", col: c_white}],[{word: "DEAD", col: global.c_downed}],[{word: "]", col: c_white}]))
	}else{SummLog(array_concat([{word: "[", col: c_white}],[{word: "FLED", col: global.c_downed}],[{word: "]", col: c_white}]))}
	
	SummLog([{word: "Res: ", col: c_white},{word: mon.element, col: elcolor},{word: "  |  Weak: ", col: c_white},{word: mon.weakness, col: weacolor}])
	
	if mon.atk != 0 or mon.def != 0{
		SummLog([{word: string(mon.atk) + " ATK", col: global.c_mars},{word: " | ", col: c_white},{word: string(mon.def) + " DEF", col: global.c_venus}])
	}
	
	var tokens = 0
	if mon.poi {tokens += 1}
	if mon.stun {tokens += 1}
	if mon.sleep {tokens += 1}
	if mon.del {tokens += 1}
	if mon.psy {tokens += 1}
	
	if tokens{
		var tokentext = []
		if mon.poi{array_push(tokentext,{word: "Poisoned", col: global.c_status});tokens-=1}
		if mon.poi and tokens{array_push(tokentext, {word: " | ", col: c_white})}
		if mon.stun{array_push(tokentext,{word: "Stunned (" + string(min(3,mon.stun)) + ")", col: global.c_status});tokens-=1}
		if mon.stun and tokens{array_push(tokentext, {word: " | ", col: c_white})}
		if mon.sleep{array_push(tokentext,{word: "Asleep", col: global.c_status});tokens-=1}
		if mon.sleep and tokens{array_push(tokentext, {word: " | ", col: c_white})}
		if mon.del{array_push(tokentext,{word: "Deluded", col: global.c_status});tokens-=1}
		if mon.del and tokens{array_push(tokentext, {word: " | ", col: c_white})}
		if mon.psy{array_push(tokentext,{word: "Sealed", col: global.c_status});tokens-=1}
		
		if mon.stun > 3 or mon.sleep > 1{
			array_push(tokentext, {word: " (LOCKED)", col: global.c_jupiter})
		}
		
		SummLog(tokentext)
		
	}

	
	var longest = 0	
	var moveArray = array_unique(moves)
	
	for (var k=0;k<array_length(moveArray);k++){
		if string_width(global.moveIDs[# 1,moveArray[k]]) > longest{
			longest = string_width(global.moveIDs[# 1,moveArray[k]])
		}
	}
	
	SummLog("")
	SummLog("1d" + string(array_length(moves)) + ":")
	SummLog("")
	
	for (var m =0;m<array_length(moveArray);m++){

		var count = 0
		var name = global.moveIDs[# 1,moveArray[m]]
		for (var j=0; j < array_length(moves); j+= 1){
			if moves[j] == moveArray[m]{
				count+=1
			}
			
		}
		
		
		
		var chance = floor((count/array_length(moves))*100)
		
		var damage = 0
		var tempdam = 0
		var explode = false
		for(var l = 0;l<5;l++){
			tempdam = GetReal(global.moveIDs[# 3+l, moveArray[m]])
			if tempdam > 0{damage += tempdam}else if tempdam < 0{explode = true}
		}
		
		damage += mon.atk + global.damagecurse
		
		var range = GetReal(global.moveIDs[# 8, moveArray[m]])
		
		var rangetext = {}
		switch range{
			case 0:
				rangetext = {word: "Self", col: c_white}
				break
			case 1:
				rangetext = {word: "1 Player", col: c_white}
				break
			case 3:
				rangetext = {word: "3 Players", col: c_white}
				break
			case 4:
				rangetext = {word: "All Players", col: c_white}
				break
			case -1:
				rangetext = {word: global.troop[global.moveIDs[# 15, moveArray[m]]].enemyName, col: c_white}
				break
			case -3:
				rangetext = {word: "All Other Enemies", col: c_white}
				break
			case -24:
				rangetext = {word: "Enemy Party", col: c_white}
				break
			default:
				rangetext = {word: "Range Missing", col: c_white}
				break
		}
		var tokentext = {word: "", col: c_white}
		var stat = global.moveIDs[# 9, moveArray[m]]
		var amt = global.moveIDs[# 14, moveArray[m]]
		var status = false
		if stat != ""{
			switch stat{
				case "poi":
					tokentext = {word: "Attempt Poison", col: global.c_status}
					status = true					
					break
				case "stun":
					tokentext = {word: "Attempt Stun", col: global.c_status}
					status = true					
					break
				case "sleep":
					tokentext = {word: "Attempt Sleep", col: global.c_status}
					status = true					
					break
				case "del":
					tokentext = {word: "Attempt Delusion", col: global.c_status}
					status = true					
					break
				case "psy":
					tokentext = {word: "Attempt Psy Seal", col: global.c_status}
					status = true					
					break
				case "ven":
					tokentext = {word: "Attempt Venom", col: global.c_status}
					status = true					
					break
				case "poi+":
					tokentext = {word: "Inflict Poison", col: global.c_status}
					status = true					
					break
				case "stun+":
					tokentext = {word: "Inflict Stun", col: global.c_status}
					status = true					
					break
				case "sleep+":
					tokentext = {word: "Inflict Sleep", col: global.c_status}
					status = true					
					break
				case "del+":
					tokentext = {word: "Inflict Delusion", col: global.c_status}
					status = true					
					break
				case "psy+":
					tokentext = {word: "Inflict Psy Seal", col: global.c_status}
					status = true					
					break
				case "ven+":
					tokentext = {word: "Inflict Venom", col: global.c_status}
					status = true					
					break
				case "bre":
					tokentext = {word: "Reset Stats", col: c_white}
					status = true					
					break
				case "lose":
					tokentext = {word: "Lose Turn", col: global.c_status}
					status = true					
					break
				case "djinn":
					tokentext = {word: "Reset Djinni", col: global.c_status}
					status = true					
					break
				case "djinn+":
					tokentext = {word: "Reset Djinn", col: global.c_status}
					status = true					
					break
				case "defu":
					tokentext = {word: "DEF +" + amt, col: c_white}
					status = true					
					break
				case "defd":
					tokentext = {word: "DEF -" + amt, col: c_white}
					status = true					
					break
				case "atku":
					tokentext = {word: "ATK +" + amt, col: c_white}
					status = true					
					break
				case "atkd":
					tokentext = {word: "ATK -" + amt, col: c_white}
					status = true					
					break
			}
		}
		
		var eletext = {word: " Normal", col: global.c_normal}
		
		if global.moveIDs[# 3, moveArray[m]] != ""{eletext.word = " Venus";eletext.col = global.c_venus}
		if global.moveIDs[# 4, moveArray[m]] != ""{eletext.word = " Mars";eletext.col = global.c_mars}
		if global.moveIDs[# 5, moveArray[m]] != ""{eletext.word = " Jupiter";eletext.col = global.c_jupiter}
		if global.moveIDs[# 6, moveArray[m]] != ""{eletext.word = " Mercury";eletext.col = global.c_mercury}
		
		var healtext = ""
		var healval = GetReal(global.moveIDs[# 11, moveArray[m]])
		
		if  healval{
			healtext = "Heal " + string(healval)
		}else if global.moveIDs[# 11, moveArray[m]] == "dam"{
			healtext = "Heal Damage Done"
			healval = 1
		}
		
		var double = GetReal(global.moveIDs[# 12, moveArray[m]])
		var damstring = {word: string(damage), col: global.c_damage}
		if double{
			damstring.word += "/" + string(damage*2)
		}
		var pierce = GetReal(global.moveIDs[# 13, moveArray[m]])
		if pierce{
			damstring.word += " PIERCING"
		}
		var suffix = {word: "", col: c_white}
		if explode == true{
			suffix.word = " (Explodes)"
		}
		
		var psynergy = {word: "", col: global.c_jupiter}
		var special = false
		if GetReal(global.moveIDs[# 10, moveArray[m]]){psynergy.word = "-P- "}
		if GetReal(global.moveIDs[# 16, moveArray[m]]){special = true}
		var infix = {word: "", col: c_white}
		
		while string_width(psynergy.word) < 50{
			psynergy.word += " "
		}
		
		while string_width(name) < longest{
			name += " "
		}
		
		if !special{
			if damage > 0{
				if status{infix = {word: " + ", col: c_white}}
				if healval > 0{healtext = {word: "and " + healtext, col: c_white}}else{healtext = {word: "", col: c_white}}
				SummLog([psynergy,{word: name + " | ", col: c_white},damstring,eletext,{word: " to ", col: c_white},rangetext,{word:" ",col: c_white},infix,tokentext,healtext,{word: " - (" + string(chance) + "%)", col: c_white},suffix])
			}else if damage == 0 and healval > 0{
				if status{infix = {word: " + ", col: c_white}}
				SummLog([psynergy,{word: name + " | " + string(healval) + " Healing to ", col: c_white},rangetext,tokentext,{word: " - (" + string(chance) + "%)", col: c_white},suffix])
			}else{
				if status{infix = {word: " + ", col: c_white}}
				SummLog([psynergy,{word: name + " | ", col: c_white},rangetext,{word: " - ", },tokentext,{word: " - (" + string(chance) + "%)", col: c_white},suffix])
			}
		}else{
			if name == "Mystic Call"{SummLog([{word: name + " - Spawn a ball", col: c_white},{word: " - (" + string(chance) + "%)", col: c_white}])}
			if name == "Flee"{SummLog([{word: "Flee - Attempts to run", col: c_white},{word: " - (" + string(chance) + "%)", col: c_white}])}
		}
		
	}
	

	while global.summlog[array_length(global.summlog)-2] == ""{
		SummLog("")
	}
	SummLog("----------")
	if global.summchoice == mon.slotnum and global.logchoice == "summ"{global.logchoice = "log"}else{global.logchoice = "summ"}
	global.summchoice = mon.slotnum

}