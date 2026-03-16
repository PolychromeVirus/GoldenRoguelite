var _top = array_length(global.menu_stack) > 0 ? global.menu_stack[array_length(global.menu_stack)-1] : noone
if _top != id { exit }

if InputPressed(INPUT_UP) {
    value--
    if value < minim { value = maxim }
}
if InputPressed(INPUT_DOWN) {
    value++
    if value > maxim { value = minim }
}
