//spells = []

//for (var i = 0; i<array_length(global.players[global.turn].spells); i++){
//	for (var j = 0; j<array_length(global.psynergylist); j++){
//		if global.psynergylist[j].name == global.players[global.turn].spells[i]{
//			array_push(spells, global.psynergylist[j])
//		}
//	}
//}

var button1 = 132
var button2 = 160

if instance_number(objCancel) > 0{
	instance_destroy(objCancel)	
}
if instance_number(objConfirm) > 0{
	instance_destroy(objConfirm)	
}

instance_create_depth(button1,92,0,objConfirm)
instance_create_depth(button2,92,0,objCancel)