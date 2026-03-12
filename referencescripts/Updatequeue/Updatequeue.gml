// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function UpdateQueue(){

	for (var i = 0; i < array_length(global.textqueue)-1; i+= 1){
		global.textqueue[i] = global.textqueue[i+1]
	}
	array_delete(global.textqueue, array_length(global.textqueue)-1, 1)
	if array_length(global.textqueue) > 2{
		if string_pos("   ", global.textqueue[2]) != 0{
			UpdateQueue()
			return true
		}
	}
}