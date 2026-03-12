// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function GetSummary(mon){
	var moves = GetMoves(mon.ID)

	ClearLog(global.summlog)

	var trapdamage = 0

	SummLog("----------")
	SummLog(mon.enemyName + ": " + mon.element)
	if mon.boss{
		SummLog({word: "BOSS", col: global.c_mars})
	}

	var damagestring = ""

	if mon.atk != 0{
		if mon.atk > 0{damagestring += "+" + string(mon.atk) + " ATK;"}
		else{damagestring += string(mon.atk) + " ATK;"}
	}
	if mon.def != 0{
		if mon.def > 0{damagestring += "+" + string(mon.def) + " DEF;"}
		else{damagestring += string(mon.def) + " DEF;"}
	}
	if mon.atk != 0 or mon.def != 0{SummLog(damagestring)}

	if mon.poi or mon.stun or mon.sleep or mon.psy or mon.del {
		var tokenstring = "| "
		if mon.poi{tokenstring += "Poisoned | "}
		if mon.stun{tokenstring += "Stunned ("+ string(mon.stun) +") | "}
		if mon.sleep{tokenstring += "Asleep | "}
		if mon.psy{tokenstring += "Psynergy Sealed | "}
		if mon.del{tokenstring += "Deluded | "}
		SummLog(tokenstring)
	}else{SummLog("")}
	if mon.monsterHealth > 0{
		var temphealth = round((mon.monsterHealth/mon.maxHealth)*10)
		var hpstring = ""
		for (var m = 0; m < temphealth; m+=1) {
		    hpstring = hpstring + "|"
		}
		for (var n = temphealth; n < 10; n+=1) {
		    hpstring = hpstring + "-"
		}
	
		SummLog(string(mon.monsterHealth) + "/"+ string(mon.maxHealth) + " HP [" + hpstring + "]")
	}else if mon.monsterHealth == 0{
		SummLog("DEAD")
	}else{
		SummLog("FLED")	
	}

	SummLog("")
	SummLog("Targeting: 1d" + string(array_length(moves)))
	SummLog("")

	var moveArray = array_unique(moves)

	for (var i=0; i < array_length(moveArray); i+= 1){
		var count = 0
		for (var j=0; j < array_length(moves); j+= 1){
			if moves[j] == moveArray[i]{
				count+=1
			}
		}
		var damage = 0
		for (var l = 0; l<5; l+=1){
			damage+=GetReal(global.moveIDs[# 3+l, moveArray[i]])
		}
		
		var chance = (count/array_length(moves))*100
		var range = GetReal(global.moveIDs[# 8, moveArray[i]])
		var rangetext
		if range == 0{
			rangetext = "self"
		}else if range > 0{
			rangetext = range
		}else if range == -3{
			rangetext = "allies"
		}else if range == -24{
			rangetext = "enemy party"
		}else{
			rangetext = "range missing"
		}
	
		var tokentext = ""
	
		if global.moveIDs[# 9, moveArray[i]] != ""{
			var tokentype = global.moveIDs[# 9, moveArray[i]]
			var amt = global.moveIDs[# 14, moveArray[i]]
			switch (tokentype){
				case "poi":
					tokentext += "Poison"
					break
				case "defu":
					tokentext += "DEF +" + amt
					break
				case "defd":
					tokentext += "DEF -" + amt
					break
				case "sleep":
					tokentext += "Sleep"
					break
				case "stun":
					tokentext += "Stun"
					break
				case "psy":
					tokentext += "Seal Psynergy"
					break
				case "atkd":
					tokentext += "ATK -" + amt
					break
				case "atku":
					tokentext += "ATK +" + amt
					break
				case "bre":
					tokentext += "Reset Stats"
					break
				case "ven":
					tokentext += "Venom"
					break
				case "stun+":
					tokentext += "Stun"
					break
				case "lose":
					tokentext += "Steal Turn"
					break
				case "djinn":
					tokentext += "Reset Djinn"
					break
				default:
					tokentext = "effect"
			}
		
		
		}
	
		var healtext = ""
	
		if global.moveIDs[# 11, moveArray[i]] != ""{
			healtext = "Heal"
		}
		var totdamage = 0
		if damage != 0{totdamage = damage+global.damagecurse+trapdamage+mon.atk}else{totdamage = damage}
		var totstring = string(totdamage)
		if global.moveIDs[# 12, moveArray[i]] == "TRUE"{
			totstring += "/" + string((totdamage)*2)
		}
		var psynergy = {word: "", col: global.c_jupiter}
		if GetReal(global.moveIDs[# 10, moveArray[i]]){ psynergy = {word: "-P- ",col: global.c_jupiter}}
		if totdamage != 0 {
			if tokentext != "" {tokentext = " + " + tokentext}
			if healtext != "" {healtext = " + Heal self"}
			SummLog([psynergy, {word: string(global.moveIDs[# 1,moveArray[i]]) + " - " + totstring + " to " + rangetext + tokentext + healtext + " - (" + string(chance) + "%)", col: c_white}])
		}else if totdamage == 0 and healtext != ""{
			if tokentext != "" {tokentext = " + " + tokentext}
			SummLog([psynergy,{word: string(global.moveIDs[# 1,moveArray[i]]) + " - " + healtext + " " + rangetext + tokentext + " - (" + string(chance) + "%)",col: c_white}])
		}else{
			if healtext != "" {healtext = " + " + healtext}
			SummLog( [psynergy, {word: string(global.moveIDs[# 1,moveArray[i]]) + " - " + tokentext + " (Targets " + rangetext + ")" + healtext + " - (" + string(chance) + "%)",col: c_white} ] )
		}
	}


	SummLog("")
	SummLog("Weakness: " +mon.weakness)
	SummLog("----------")
	while global.summlog[array_length(global.summlog)-1] == ""{
		SummLog("")
	}

	if global.summchoice == mon.slotnum and global.logchoice == "summ"{global.logchoice = "log"}else{global.logchoice = "summ"}
	global.summchoice = mon.slotnum

}