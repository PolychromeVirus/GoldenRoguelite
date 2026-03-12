if instance_exists(objStatDisplay) { objStatDisplay.viewPlayer = global.turn }

DestroyAllBut(objItemMenu)

if instance_number(objItemMenu) < 1{
	ClearOptions()
	instance_create_depth(0,0,0,objItemMenu)
	global.pause = true
}else{
	ClearOptions()
	instance_activate_region(0,0,room_width,120,true)
	global.pause = false
	DestroyAllBut()
}