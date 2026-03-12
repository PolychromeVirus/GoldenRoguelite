// Click anywhere to dismiss (skip the frame it was created to avoid instant dismiss)
if !_dismiss_ready {
	if !mouse_check_button(mb_left) { _dismiss_ready = true }
} else if mouse_check_button_pressed(mb_left) {
	instance_destroy()
	CreateOptions()
	exit
}

//content = name + " - " + class + "\n\nATK: " + string(atk) + "\n"
//+ "DEF: " + string(def) + "\n\nPsynergy Learned:\n"


//if array_length(spells) <= 7{
//	for (var i = 0; i < array_length(spells); i++){
//		content += global.psynergylist[spells[i]].name + "\n"
//	}
//}else{
//	for (i = 0; i < 7; i++){
//		content += global.psynergylist[spells[i]].name + "\n"
//	}
//	content += "..."
//}


//shorttrue = ""
//longtrue = ""
//axetrue = ""
//macetrue = ""
//stafftrue = ""

//if(equipshort){shorttrue = "Able"}else{shorttrue = "Unable"}
//if(equiplong){longtrue = "Able"}else{longtrue = "Unable"}
//if(equipaxe){axetrue = "Able"}else{axetrue = "Unable"}
//if(equipmace){macetrue = "Able"}else{macetrue = "Unable"}
//if(equipstaff){stafftrue = "Able"}else{stafftrue = "Unable"}

//var cursedtext = ""

//if global.itemcardlist[weapon].cursed == "TRUE"{cursedtext = " (Cursed)"}

//equips = "\n\nWeapon:\n" + global.itemcardlist[weapon].name + cursedtext + "\n\nEquipment:\n"

//for (var j = 0; j < array_length(armor); j++){
//	equips += global.itemcardlist[armor[j]].name + "\n"
//}

//if array_length(armor) == 0{equips += "None\n"}