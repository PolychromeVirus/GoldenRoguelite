// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function isUsable(item){
	//var unusableItems = ["Orihalcon"]
	
	//if array_contains(unusableItems,item){
	//	return false	
	//}
	
	var itemtype = global.itemcardlist[item].type
	
	if itemtype != "Healing" and itemtype != "Battle"{
		if global.itemcardlist[item].name == "Lucky Medal" and global.inCombat{return true}
		return false
	}
	if itemtype == "Battle" and !global.inCombat{return false}
	return true
}