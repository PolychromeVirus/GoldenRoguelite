function PopMenu(){
	
	if array_length(global.menu_stack) > 0{
		var _tar = global.menu_stack[array_length(global.menu_stack)-1]
	
		array_delete(global.menu_stack,array_length(global.menu_stack)-1,1)
		instance_destroy(_tar)
		return true
	}else{
	
		show_debug_message("PopMenu called while queue was empty")
		return false
	}
}