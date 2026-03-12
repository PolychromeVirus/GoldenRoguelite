// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function hideButtons(){
	if global.spawning == false{
		instance_deactivate_region(0,280,1024,616-280,true,false)
		global.spawning = true
	}else{
		instance_activate_region(0,280,1024,616-280,true,false)
	}
}