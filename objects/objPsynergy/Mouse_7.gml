if instance_exists(objStatDisplay) { objStatDisplay.viewPlayer = global.turn }

DestroyAllBut(objPsynergyMenu)

if instance_number(objPsynergyMenu) < 1 and !global.players[global.turn].psyseal{
	ClearOptions()
	instance_create_depth(0,0,0,objPsynergyMenu)
	global.pause = true
}else{
	global.pause = false
	ClearOptions()
	DestroyAllBut()
}