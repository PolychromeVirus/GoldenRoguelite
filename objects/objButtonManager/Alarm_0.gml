var _top = (array_length(global.menu_stack) > 0)
         ? global.menu_stack[array_length(global.menu_stack) - 1]
         : noone

if (global.turnPhase != "player" and !MenuExists()) or instance_exists(objEnemyPhaseController) {
    // Enemy/boss phase — no buttons should exist
    DeleteButtons()
    exit
}

if _top != noone and instance_exists(_top) {
    if variable_instance_exists(_top, "_build_buttons") {
        _top._build_buttons()
    }
	
	if variable_instance_exists(_top,"exclusive") and _top.exclusive{
	
		for (var i = 0; i < array_length(global.menu_stack)-1; ++i) {
			var _curr = global.menu_stack[i]
		    _curr.visible = false
			if variable_instance_exists(_curr,"pane") and instance_exists(_curr.pane){
				_curr.pane.visible = false
			}
		}
		global.menu_stack[array_length(global.menu_stack) - 1].visible = true
		if variable_instance_exists(global.menu_stack[array_length(global.menu_stack) - 1],"pane") and instance_exists(global.menu_stack[array_length(global.menu_stack) - 1].pane){
				global.menu_stack[array_length(global.menu_stack) - 1].pane.visible = true
			}
	
	}else{
	
		for (var i = 0; i < array_length(global.menu_stack); ++i) {
			var _curr = global.menu_stack[i]
		    _curr.visible = true
			if variable_instance_exists(_curr,"pane") and instance_exists(_curr.pane){
				_curr.pane.visible = true
			}
		}
	
	}
	
	
} else if !global.pause and !instance_exists(objMonsterTarget){
    CreateOptions()
}


