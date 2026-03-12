if instance_position(mouse_x,mouse_y,objConfirm)and clickable{

	if global.psynergylist[global.players[global.turn].spells[selected]].cost <= global.players[global.turn].pp{
		
		ClearOptions()
		CastSpell(global.players[global.turn].spells[selected],global.turn)
	}else{InjectLog("Not enough PP to cast this!")}

}
var _clicked = instance_position(mouse_x,mouse_y,objButton2)
if _clicked != noone and _clicked.object_index == objButton2 and clickable{
	ClearOptions()
	PsyLookup(global.players[global.turn].spells[selected])	
}