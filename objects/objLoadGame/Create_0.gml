if !file_exists("Save.txt") { instance_destroy(); exit }
var _f = file_text_open_read("Save.txt")
var _info = file_text_read_string(_f)
file_text_close(_f)
_save = json_parse(_info)

hovertext = global.dungeonlist[_save.dungeon].name + " Floor "+ string( _save.floor mod 9)