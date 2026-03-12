//spells = []

//for (var i = 0; i<array_length(global.players[global.turn].spells); i++){
//	for (var j = 0; j<array_length(global.psynergylist); j++){
//		if global.psynergylist[j].name == global.players[global.turn].spells[i]{
//			array_push(spells, global.psynergylist[j])
//		}
//	}
//}

instance_create_depth(sprite_width,sprite_height/2,0,objQuarterMenu)

DeleteButtons()

instance_create_depth(BUTTON2,BOTTOMROW,0,objCancel)

var sprite = {image: yes,text:"Cast"}
instance_create_depth(BUTTON1,BOTTOMROW,0,objConfirm,sprite)

var sprite = {image:Save_Game,text:"Info"}
instance_create_depth(BUTTONRIGHT2,BOTTOMROW,0,objButton2,sprite)

clickable = false
alarm_set(0,1)