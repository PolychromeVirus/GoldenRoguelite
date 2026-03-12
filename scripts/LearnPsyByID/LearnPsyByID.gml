// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function LearnPsyByID(psyID,playerID){
	 var existcheck = false
	 var stageslearned = 0
	
	for (var j = 0; j < array_length(global.players[playerID].spells); j++){
		var currentspell = global.players[playerID].spells[j]
		if global.psynergylist[currentspell].base == global.psynergylist[psyID].base{stageslearned++}
	}
	
	if stageslearned == global.psynergylist[psyID].maxstage{existcheck = true}

	var learnstage = stageslearned + 1
	 
	if !existcheck{array_push(global.players[playerID].spells,FindPsyID(global.psynergylist[psyID].base,learnstage))}
	 
	array_sort(global.players[0].spells,true)
	array_sort(global.players[1].spells,true)
	array_sort(global.players[2].spells,true)
	array_sort(global.players[3].spells,true)
}