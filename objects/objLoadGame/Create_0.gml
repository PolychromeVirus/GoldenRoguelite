if !file_exists("Save.txt") { instance_destroy(); exit }
var _f = file_text_open_read("Save.txt")
var _info = file_text_read_string(_f)
file_text_close(_f)
_save = json_parse(_info)

var _floor = is_array(_save.floor) ? _save.dungeonFloor : _save.floor
hovertext = global.dungeonlist[_save.dungeon].name + " Floor "+ string(_floor mod 9)

breath_t   = 0
btn_scale  = 1.0
is_pressed = false
clickable  = false
alarm_set(0, 1)