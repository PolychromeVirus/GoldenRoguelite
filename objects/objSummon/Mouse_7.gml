if instance_exists(objStatDisplay) { objStatDisplay.viewPlayer = global.turn }

DestroyAllBut(objSummonMenu)

if instance_number(objSummonMenu) < 1{
	ClearOptions()
	instance_create_depth(0,0,0,objSummonMenu)
	global.pause = true
}else{
	global.pause = false
	ClearOptions()
	DestroyAllBut()
}