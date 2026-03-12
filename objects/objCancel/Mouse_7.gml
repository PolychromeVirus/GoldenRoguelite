if instance_number(objChar1) < 1 {global.pause = false}

if clickable{
	global.pendingPPCost = 0
	global.textdisplay = ""
	DestroyAllBut()
	CreateOptions()
	ClearOptions()
}