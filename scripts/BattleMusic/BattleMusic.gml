function BattleMusic(boss = false){
	
	var regsongs = []
	var bosssongs = []
	regsongs = audio_group_get_assets(BattleThemes)
	bosssongs = audio_group_get_assets(BossThemes)
	var _choice = irandom(array_length(boss ? bosssongs : regsongs)-1)
	
	audio_stop_all()
	audio_play_sound(boss ? DeathSoundBig : DeathSoundMedium,0,0)
	var delaysound = boss ? bosssongs[_choice] : regsongs[_choice]
	
	instance_create_depth(0,0,0,TurnDelay,{wait:30,delaysound: delaysound,on_complete: function(){audio_play_sound(delaysound,1,1)}})
}