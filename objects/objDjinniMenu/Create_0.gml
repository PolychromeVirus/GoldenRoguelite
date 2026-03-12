//spells = []

//for (var i = 0; i<array_length(global.players[global.turn].spells); i++){
//	for (var j = 0; j<array_length(global.psynergylist); j++){
//		if global.psynergylist[j].name == global.players[global.turn].spells[i]{
//			array_push(spells, global.psynergylist[j])
//		}
//	}
//}

DeleteButtons()

instance_create_depth(BUTTON2,BOTTOMROW,0,objCancel)

if !global.inCombat {
	var tradeSprite = {image: Switch,text:"Trade"}
	instance_create_depth(BUTTON1,BOTTOMROW,0,objButton2,tradeSprite)
}else{
	var sprite = {image: yes,text:"Unleash"}
	instance_create_depth(BUTTON1,BOTTOMROW,0,objConfirm,sprite)
}