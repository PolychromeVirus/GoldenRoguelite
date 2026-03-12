// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function FindItemID(searchtarget){
	for (var i = 0; i<array_length(global.itemcardlist); i++){
		if global.itemcardlist[i].name == searchtarget{
			return i
		}
	}
	return -1
}