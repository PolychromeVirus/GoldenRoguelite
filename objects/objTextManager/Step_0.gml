// Game over countdown
if global.gameover {
    global.gameover_timer--
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


var _bg_layer = layer_background_get_id(layer_get_id("Background"))

if room != CharacterSelect and !global.gameover{
	if !global.inTown and !global.inCombat and !layer_background_get_sprite(global.genbackground){

		layer_background_sprite(_bg_layer, global.genbackground)
	}else if global.inTown{layer_background_sprite(_bg_layer, World_Map)}
}