// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function InjectLog(text){
	var str = ""
	var struc = [{word: "",col: c_white}]
	if is_array(text){
		for (var j = 0; j < array_length(text); j+= 1){
			if variable_struct_exists(text[j],"word"){
				str += text[j].word
			}
			if !variable_struct_exists(text[j], "col"){
				text[j].col = c_white
			}
		}
	struc = text
	}
	else
	{
		struc = [{word: text, col: c_white}]
	}
	draw_set_halign(fa_left)
	global.prevtext = global.textdisplay;
	global.textdisplay = str;
	
	for (var i = array_length(global.log)-1; i > 0; i-= 1){
		global.log[i] = global.log[i-1]
	}
	global.log[0] = struc
	array_push(global.textqueue, str)
	var file = file_text_open_append(string(global.logpath))
	file_text_write_string(file, str)
	file_text_writeln(file)
	file_text_close(file)
}