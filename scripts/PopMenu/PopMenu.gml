function PopMenu(){

	if array_length(global.menu_stack) > 0{
		var _tar = global.menu_stack[array_length(global.menu_stack)-1]

		array_delete(global.menu_stack,array_length(global.menu_stack)-1,1)
		instance_destroy(_tar)
		global.kbd_tooltip = ""
		global.using_kbd   = false
		return true
	}else{
	
		show_debug_message("PopMenu called while queue was empty")
		return false
	}
}

function PopAll(){
	var _length = array_length(global.menu_stack)
	for (var i = 0; i < _length; ++i) {
	    instance_destroy(global.menu_stack[0])
		array_delete(global.menu_stack,0,1)
	}
	
}