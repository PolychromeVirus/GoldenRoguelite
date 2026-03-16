if array_length(global.menu_stack) > 0 { exit }

DestroyAllBut(objStatDisplay)

if instance_number(objStatDisplay) > 0{
	instance_destroy(objStatDisplay)
	CreateOptions()
}else{
	DeleteButtons()
	instance_create_depth(0,0,0,objStatDisplay)
}