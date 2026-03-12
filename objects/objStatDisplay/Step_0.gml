content = global.players[viewPlayer].name + " - " + global.players[viewPlayer].class + 
"\n\nATK: " + string(global.players[viewPlayer].atk + global.players[viewPlayer].atkmod) + "\n"
+ "DEF: " + string(global.players[viewPlayer].def + global.players[viewPlayer].defmod) + "\n\nPsynergy Learned:\n"


if array_length(global.players[viewPlayer].spells) <= 7{
	for (var i = 0; i < array_length(global.players[viewPlayer].spells); i++){
		content += global.psynergylist[global.players[viewPlayer].spells[i]].name + "\n"
	}
}else{
	for (i = 0; i < 7; i++){
		content += global.psynergylist[global.players[viewPlayer].spells[i]].name + "\n"
	}
	content += "..."
}


shorttrue = ""
longtrue = ""
axetrue = ""
macetrue = ""
stafftrue = ""

if(global.players[viewPlayer].equipshort){shorttrue = "Able"}else{shorttrue = "Unable"}
if(global.players[viewPlayer].equiplong){longtrue = "Able"}else{longtrue = "Unable"}
if(global.players[viewPlayer].equipaxe){axetrue = "Able"}else{axetrue = "Unable"}
if(global.players[viewPlayer].equipmace){macetrue = "Able"}else{macetrue = "Unable"}
if(global.players[viewPlayer].equipstaff){stafftrue = "Able"}else{stafftrue = "Unable"}

venusmod = string(max(1, floor(global.players[viewPlayer].venus / 2))) + "|" + string(global.players[viewPlayer].vres)
marsmod = string(max(1, floor(global.players[viewPlayer].mars / 2))) + "|" + string(global.players[viewPlayer].mares)
jupitermod = string(max(1, floor(global.players[viewPlayer].jupiter / 2))) + "|" + string(global.players[viewPlayer].jres)
mercurymod = string(max(1, floor(global.players[viewPlayer].mercury / 2))) + "|" + string(global.players[viewPlayer].meres)

var cursedtext = ""

if global.itemcardlist[global.players[viewPlayer].weapon].cursed == "TRUE"{cursedtext = " (Cursed)"}

equips = "\n\nWeapon:\n" + global.itemcardlist[global.players[viewPlayer].weapon].name + cursedtext + "\n\nEquipment:\n"

for (var j = 0; j < array_length(global.players[viewPlayer].armor); j++){
	equips += global.itemcardlist[global.players[viewPlayer].armor[j]].name + "\n"
}

if array_length(global.players[viewPlayer].armor) == 0{equips += "None\n"}