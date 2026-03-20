if clickable {
    global.pendingPPCost = 0
    if instance_exists(objMonsterTarget) {
        CANCELSOUND
        global.textdisplay = ""
        var _committed = variable_instance_exists(objMonsterTarget, "committed") and objMonsterTarget.committed
        global.attackQueue = []
        
        if _committed {
            // Mid-sequence (attack queue, Charon, etc.) — turn is over, can't undo
            PopAll()
            MakeTurnDelay(30,NextTurn)
            exit
        }
		if variable_instance_exists( global.menu_stack[array_length(global.menu_stack)-1], "on_cancel"){
			
			global.menu_stack[array_length(global.menu_stack)-1].on_cancel()
			
			}
		if PopMenu(){CANCELSOUND}
        // Destroy_0 restores stack visibility and rebuilds buttons
    } else{
	
		if array_length(global.menu_stack) > 0{
		
			if variable_instance_exists( global.menu_stack[array_length(global.menu_stack)-1], "on_cancel"){
			
			global.menu_stack[array_length(global.menu_stack)-1].on_cancel()
			
			}
		
		}
		
		if PopMenu() {CANCELSOUND}
		
    }
}