var _top = array_length(global.menu_stack) > 0 ? global.menu_stack[array_length(global.menu_stack)-1] : noone
if _top != id { exit }

var _len = array_length(entries)
if _len == 0 { exit }

if InputPressed(INPUT_LEFT) {
    index--
    if index < 0 { index = _len - 1 }
}
if InputPressed(INPUT_RIGHT) {
    index++
    if index >= _len { index = 0 }
}
