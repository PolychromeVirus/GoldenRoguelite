if !array_contains(global.menu_stack, id) { exit }
if !visible {exit}

var _len = array_length(entries)
if _len == 0 { exit }

draw_sprite_ext(TestMenu, 0, 0, 0, 6, 6, 0, c_white, 1)

draw_set_font(GoldenSun)

var _entry  = entries[index]
var _name   = variable_struct_exists(_entry, "name") ? _entry.name : ""
var _offset = 4
var _drawx  = 50
var _drawy  = 50

// Name with left/right arrows + counter
var _header = "<- " + _name + " ->"
draw_set_color(c_black)
draw_text(_drawx + _offset, _drawy + _offset, _header)
draw_set_color(c_white)
draw_text(_drawx, _drawy, _header)

var _counter    = string(index + 1) + "/" + string(_len)
var _counter_w  = string_width(_counter)
draw_set_color(c_black)
draw_text(1536 - _drawx - _counter_w + _offset, _drawy + _offset, _counter)
draw_set_color(c_white)
draw_text(1536 - _drawx - _counter_w, _drawy, _counter)

// Entry-specific content drawn by caller
draw_entry(_entry, index)
