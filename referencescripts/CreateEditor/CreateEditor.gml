// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function CreateEditor(){
	
	instance_deactivate_region(0,280,1024,336,true,false)
	instance_create_depth(0,0,0,objSpawnMenu)
	instance_create_depth(5,5,0,objEditEnd)
	global.mousemode = "spawn"
	global.drawLog = false
	
	
	
}