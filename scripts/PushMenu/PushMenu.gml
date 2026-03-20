function PushMenu(type,config){
	var _depth = -(array_length(global.menu_stack) + 1)
	var _inst = instance_create_depth(0,0,_depth,type,config)
	array_push(global.menu_stack,_inst)
	
	return _inst
}