function MenuExists(){
	for (var i = 0; i < array_length(global.menu_stack); ++i) {
	    if instance_exists(global.menu_stack[i]){ return true }
	}
	return false
}