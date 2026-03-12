//spells = []

//for (var i = 0; i<array_length(global.players[global.turn].spells); i++){
//	for (var j = 0; j<array_length(global.psynergylist); j++){
//		if global.psynergylist[j].name == global.players[global.turn].spells[i]{
//			array_push(spells, global.psynergylist[j])
//		}
//	}
//}

var button1 = 36
var button2 = 64

monsters = []
var count = instance_number(objMonster)
for (var i = 0; i < count; i++) {
	var inst = instance_find(objMonster, i)
	array_push(monsters, inst)
}

instance_create_depth(button1,124,0,objConfirm)
instance_create_depth(button2,124,0,objCancel)

alarm_set(0,1)