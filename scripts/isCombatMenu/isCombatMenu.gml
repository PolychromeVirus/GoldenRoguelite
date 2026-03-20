// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function isCombatMenu(){
	if global.inCombat and array_length(global.menu_stack) > 0 { return true }
	if instance_number(objItemMenu) > 0{return true}
	if instance_number(objCharonPicker) > 0{return true}
	return false
}