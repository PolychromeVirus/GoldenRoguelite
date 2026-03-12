if selected > array_length(global.players[global.turn].spells)-1{
	selected = array_length(global.players[global.turn].spells)-1
}
if selected < 0{
	selected = 0
}

if array_length(global.players[global.turn].spells) < 1{instance_destroy(objQuarterMenu)}else{

	if instance_number(objQuarterMenu) < 1{
		instance_create_depth(sprite_width,sprite_height/2,0,objQuarterMenu)
	}

}