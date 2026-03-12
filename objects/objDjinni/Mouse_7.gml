if instance_exists(objStatDisplay) { objStatDisplay.viewPlayer = global.turn }

DestroyAllBut(objDjinniMenu)

if instance_number(objDjinniMenu) < 1{
	ClearOptions()
	instance_create_depth(0,0,0,objDjinniMenu)
	global.pause = true
}else{
	global.pause = false
	ClearOptions()
	DestroyAllBut()
}