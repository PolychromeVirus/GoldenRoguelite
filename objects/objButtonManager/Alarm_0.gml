var _top = (array_length(global.menu_stack) > 0)
         ? global.menu_stack[array_length(global.menu_stack) - 1]
         : noone

if global.turnPhase != "player" and !MenuExists() {
    // Enemy/boss phase — no buttons should exist
    DeleteButtons()
    exit
}

if _top != noone and instance_exists(_top) {
    if variable_instance_exists(_top, "_build_buttons") {
        _top._build_buttons()
    }
} else if !global.pause {
    CreateOptions()
}


