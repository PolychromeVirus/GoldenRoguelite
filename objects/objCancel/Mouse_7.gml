if instance_number(objChar1) < 1 {global.pause = false}

if clickable{
	global.pendingPPCost = 0
	global.textdisplay = ""
	audio_play_sound(MenuNegative,0,0)
	DestroyAllBut()
	CreateOptions()
	ClearOptions()
}