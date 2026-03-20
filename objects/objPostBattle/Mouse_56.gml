// Clean up leftover monster instances before drafts/options
with (objMonster) { instance_destroy() }
global.inCombat = false
audio_stop_all()
audio_play_sound(global.genBGM, 1, true)
ProcessPostBattleQueue()
instance_destroy()
