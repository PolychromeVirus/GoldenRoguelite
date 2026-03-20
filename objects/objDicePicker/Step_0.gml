var _top = array_length(global.menu_stack) > 0 ? global.menu_stack[array_length(global.menu_stack)-1] : noone
if _top != id { exit }

var _len = array_length(dice)
if _len == 0 { exit }

if InputPressed(INPUT_LEFT) or InputPressed(INPUT_UP) {
    kbd_selected--
    if kbd_selected < 0 { kbd_selected = _len - 1 }
}
if InputPressed(INPUT_RIGHT) or InputPressed(INPUT_DOWN) {
    kbd_selected++
    if kbd_selected >= _len { kbd_selected = 0 }
}
kbd_selected = clamp(kbd_selected, 0, _len - 1)

// Single-select: confirm on INPUT_CONFIRM
if max_select == 1 and InputPressed(INPUT_CONFIRM) {
    on_confirm([dice[kbd_selected]])
}
