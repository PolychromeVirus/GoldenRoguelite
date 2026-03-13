// Central pause state manager — derive global.pause from what menus exist
if instance_exists(objStatDisplay)
	or isCombatMenu()
	or (instance_exists(objCharTarget) and (!variable_instance_exists(objCharTarget, "confirmed") or !objCharTarget.confirmed))
	or instance_exists(objCharMenu)
	or instance_exists(objDjinnDraft)
	or instance_exists(objSummonDraft)
	or instance_exists(objPsynergyDraft)
	or instance_exists(objPostBattle)
	or instance_exists(objCharMenu)
	or instance_exists(objPsynergyLibrary)
	or instance_exists(objMonsterStat)
	or instance_exists(objAssignMenu)
	or instance_exists(objDjinniTrade)
	or instance_exists(objRerollPicker)
	or instance_exists(objTownPicker)
	or instance_exists(objTownShop)
	or instance_exists(objChoiceDraw)
	or instance_exists(objInsightDisplay)
{
	global.pause = true
} else {
	global.pause = false
}

var _bg_layer = layer_background_get_id(layer_get_id("Background"))

if room != CharacterSelect{
	if !global.inTown and !global.inCombat and !layer_background_get_sprite(global.genbackground){
	
		layer_background_sprite(_bg_layer, global.genbackground)
	}
}