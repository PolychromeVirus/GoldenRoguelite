// Game over countdown
if global.gameover {
    global.gameover_timer--
    if global.gameover_timer == 239 { audio_stop_all() }
    if global.gameover_timer == 180 {
        var _go_snd = audio_play_sound(_09_Game_Over__Variation_, 1, true)
        audio_sound_gain(_go_snd, 0.5, 0)
    }
    if global.gameover_timer <= 0 {
        global.gameover = false
        // Restore background color
        var _bg = layer_background_get_id(layer_get_id("Background"))
        layer_background_blend(_bg, c_white)
        room_goto(PostGame)
    }
    exit
}

global.pause = (array_length(global.menu_stack) > 0)

// Tick flash timers every step regardless of what's drawn
for (var _fi = 0; _fi < array_length(global.players); _fi++) {
    var _fp = global.players[_fi]
    if _fp.heal_flash > 0  { _fp.heal_flash-- }
    if _fp.flash_timer > 0 { _fp.flash_timer-- }
}


var _bg_layer = layer_background_get_id(layer_get_id("Background"))

if room != CharacterSelect and !global.gameover{
	if !global.inTown and !global.inCombat and !layer_background_get_sprite(global.genbackground){

		layer_background_sprite(_bg_layer, global.genbackground)
	}else if global.inTown{layer_background_sprite(_bg_layer, World_Map)}
}