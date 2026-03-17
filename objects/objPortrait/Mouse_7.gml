var _stack_len = array_length(global.menu_stack)
if _stack_len > 0 {
    var _top = global.menu_stack[_stack_len - 1]
    if instance_exists(_top) and _top.object_index == objStatDisplay {
        PopMenu()
    }
    exit
}
PushMenu(objStatDisplay, {})
