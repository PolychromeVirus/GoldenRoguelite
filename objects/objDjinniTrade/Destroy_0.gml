var _idx = array_find_index(global.menu_stack, method({id: id}, function(v) { return v == id }))
if _idx >= 0 { array_delete(global.menu_stack, _idx, 1) }