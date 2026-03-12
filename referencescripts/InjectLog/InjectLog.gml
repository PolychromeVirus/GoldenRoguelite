// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function InjectLogOLD(text){
	draw_set_halign(fa_left)
	global.prevtext = global.textdisplay;
	global.textdisplay = text;
	
	for (var i = array_length(global.log)-1; i > 0; i-= 1){
		global.log[i] = global.log[i-1]
	}
	global.log[0] = text
	array_push(global.textqueue, text)
	var file = file_text_open_append(string(global.logpath))
	file_text_write_string(file, text)
	file_text_writeln(file)
	file_text_close(file)
}