var _top = (array_length(global.menu_stack) > 0)
         ? global.menu_stack[array_length(global.menu_stack) - 1]
         : noone

if _top != _prev_top {
    _prev_top = _top
    DeleteButtons()
    if global.turnPhase == "player" {
        alarm[0] = 1
    }
}
