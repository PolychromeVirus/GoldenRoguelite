// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function InjectLog(in){
	show_debug_message(in)
	global.textdisplay = in
	with (objTextManager){
		alarm_set(0,120)
	}
}