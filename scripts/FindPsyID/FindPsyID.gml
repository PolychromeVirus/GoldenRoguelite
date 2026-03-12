// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function FindPsyID(spelltarget,stage){
	
	if spelltarget == "Random"{
		var _cand = []
		for (var i = 0; i<array_length(global.psynergylist); i++){
			if global.psynergylist[i].stage == 1 and global.psynergylist[i] != "Call Zombie"{
				array_push(_cand,i)
			}
		}

		return _cand[irandom(array_length(_cand)-1)]
		
	}
	
	for (var i = 0; i<array_length(global.psynergylist); i++){
		if global.psynergylist[i].name == spelltarget and stage == 0{
			return i
		}else if global.psynergylist[i].base == spelltarget and stage == global.psynergylist[i].stage{
			return i
		}
	}
	return -1
}