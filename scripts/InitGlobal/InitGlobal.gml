// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function InitGlobal(){
	InitWeapons()
	InitArmor()
	InitItems()
	global.deck = []
	global.itemcardlist = array_concat(global.itemlist,global.weaponlist,global.armorlist)
	//for (var i=0; i< array_length(global.itemcardlist); i++){
	//	var uniq = (global.itemcardlist[i].num == "" || global.itemcardlist[i].num == undefined) ? 0 : real(global.itemcardlist[i].num)
	//	if uniq{
	//		for (var j=0; j< uniq; j++){
	//			array_push(global.deck, i)
	//		}
	//	}
	//}
	//global.deck = array_shuffle(global.deck)
	global.discard = []
	global.attackQueue = []

}