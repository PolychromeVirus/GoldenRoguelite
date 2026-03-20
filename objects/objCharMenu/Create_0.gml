//spells = []

//for (var i = 0; i<array_length(global.players[global.turn].spells); i++){
//	for (var j = 0; j<array_length(global.psynergylist); j++){
//		if global.psynergylist[j].name == global.players[global.turn].spells[i]{
//			array_push(spells, global.psynergylist[j])
//		}
//	}
//}

instance_create_depth(sprite_width,0,0,objHalfMenu)
instance_create_depth(92, 124,0,objCancel)
instance_create_depth(36, 124, 0, objConfirm)
starter_selected = 0

// Hide the static char select screen buttons while the menu is open
if room == CharacterSelect {
    with (objCharSelect) { visible = false }
    with (objBegin)      { visible = false }
    with (objLoadGame)   { visible = false }
    with (objLibrary)    { visible = false }
}