// Clean up targeter buttons
DeleteButtons()

// Restore menu stack visibility (and panes)
for (var _i = 0; _i < array_length(global.menu_stack); _i++) {
    var _inst = global.menu_stack[_i]
    if instance_exists(_inst) {
        _inst.visible = true
        if variable_instance_exists(_inst, "pane") and instance_exists(_inst.pane) {
            _inst.pane.visible = true
        }
    }
}

// Rebuild buttons for whatever is now on top (or return to base options)
var _stack_len = array_length(global.menu_stack)
if _stack_len > 0 {
    var _top = global.menu_stack[_stack_len - 1]
    if instance_exists(_top) and variable_instance_exists(_top, "_build_buttons") {
        _top._build_buttons()
    }
} else if (!variable_instance_exists(id, "committed") or !committed)
       and (!variable_instance_exists(id, "confirmed") or !confirmed) {
    // Only restore base options on a plain cancel with no active menu and no committed action
    CreateOptions()
}