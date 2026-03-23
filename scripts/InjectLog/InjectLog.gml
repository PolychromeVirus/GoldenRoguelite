// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function InjectLog(in){
	show_debug_message(in)
	global.textdisplay = in
	with (objTextManager){
		alarm_set(0,120)
	}

	array_push(global.log, in)
	if array_length(global.log) > 200 { array_delete(global.log, 0, 1) }

	var _f = file_text_open_append("log.txt")
	file_text_write_string(_f, in + "\n")
	file_text_close(_f)
}