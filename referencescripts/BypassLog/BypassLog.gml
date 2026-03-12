// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function BypassLog(text){
	draw_set_halign(fa_left)
	global.prevtext = global.textdisplay;
	global.textdisplay = text;
	
	for (var i = array_length(global.log)-1; i > 0; i-= 1){
		global.log[i] = global.log[i-1]
	}
}