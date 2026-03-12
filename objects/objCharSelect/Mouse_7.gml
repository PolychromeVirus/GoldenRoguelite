if global.pause == false{
	DeleteButtons()
	instance_create_layer(0,0,layer_get_id("Menus"),objCharMenu,variable_clone(selector))
	global.pause = true
}