if !irandom(9) and array_length(global.postBattleQueue) == 0{

	var function conf(){
	
		LevelUp()
	
	}

	var _cast = FindSpellCaster("Reveal")
	
	if _cast != -1{
		instance_create_depth(0,0,0,objSpellPrompt,{on_confirm: conf,spell_name:"Reveal", caster_index: _cast, on_decline: function(){ ClearOptions();DeleteButtons();instance_destroy() }})
	}
}