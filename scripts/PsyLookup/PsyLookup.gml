// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function PsyLookup(spellid){
	DestroyAllBut(objPsynergyLibrary)

	if instance_number(objPsynergyLibrary) > 0{
		instance_destroy(objPsynergyLibrary)
	}else{
		var tempstruct = {
			indicator: spellid
		}
		instance_create_depth(0,0,0,objPsynergyLibrary,tempstruct)
		global.pause = true
	}
}