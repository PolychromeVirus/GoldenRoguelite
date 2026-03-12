// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function SummLog(text){
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
	
	for (var i = array_length(global.log)-1; i > 0; i-= 1){
		global.summlog[i] = global.summlog[i-1]
	}
	global.summlog[0] = struc
	
}