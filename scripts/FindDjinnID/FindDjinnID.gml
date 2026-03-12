// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function FindDjinnID(searchtarget){
	for (var i = 0; i<array_length(global.djinnlist); i++){
		if global.djinnlist[i].name == searchtarget{
			return i
		}
	}
	return -1
}