// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function DestroyAllBut(obj = -1){
	var objarr = [objInsightDisplay, objDjinniTrade, objPuzzlePrompt,objChallenge,objTownPicker,objTownShop,objAssignMenu,objStatDisplay,objPsynergyMenu,objDjinniMenu,objSummonMenu,objPsynergyLibrary,objItemMenu,objCharMenu,objCharTarget,objMonsterTarget,objMonsterStat,objHalfMenu,objSummonSpellPicker,objCharonPicker,objMolochPicker,objSummonDraft, objSwapPrompt, objForcePicker, objSpellPrompt, objResonatePicker, objEchoPicker, objMeldPicker, objRerollPicker]
	if obj != -1 {array_delete(objarr,array_get_index(objarr,obj),1)}
	
	for (var i = 0; i < array_length(objarr); i++){
		instance_destroy(objarr[i])
	}
}