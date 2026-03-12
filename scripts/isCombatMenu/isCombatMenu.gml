// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function isCombatMenu(){
	if instance_number(objPsynergyMenu) > 0{return true}
	if instance_number(objDjinniMenu) > 0{return true}
	if instance_number(objItemMenu) > 0{return true}
	if instance_number(objSummonMenu) > 0{return true}
	if instance_number(objSummonSpellPicker) > 0{return true}
	if instance_number(objCharonPicker) > 0{return true}
	if instance_number(objMolochPicker) > 0{return true}
	return false
}