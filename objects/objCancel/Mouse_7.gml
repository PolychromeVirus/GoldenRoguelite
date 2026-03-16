if clickable {
    global.pendingPPCost = 0
    if instance_exists(objMonsterTarget) {
        CANCELSOUND
        global.textdisplay = ""
        var _committed = variable_instance_exists(objMonsterTarget, "committed") and objMonsterTarget.committed
        global.attackQueue = []
        instance_destroy(objMonsterTarget)
        if _committed {
            // Mid-sequence (attack queue, Charon, etc.) — turn is over, can't undo
            while array_length(global.menu_stack) > 0 { PopMenu() }
            instance_create_depth(0, 0, 0, TurnDelay, { wait: 30, on_complete: NextTurn })
            exit
        }
        // Destroy_0 restores stack visibility and rebuilds buttons
    } else if PopMenu() {
        CANCELSOUND
    } else {
        CANCELSOUND
        global.textdisplay = ""
        DestroyAllBut()
        CreateOptions()
    }
}