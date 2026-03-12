// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function FindSummonID(spelltarget){
	for (var i = 0; i<array_length(global.summonlist); i++){
		if global.summonlist[i].name == spelltarget{
			return i
		}
	}
	return 0
}