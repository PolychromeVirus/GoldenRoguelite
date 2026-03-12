//if global.turnPhase == "Player"{
	sprite_index = global.players[global.turn].portrait
	if sprite_index = -1{sprite_index = Armor_Shopkeeper}
	image_xscale = 32 / sprite_get_width(sprite_index);
	image_yscale = 32 / sprite_get_height(sprite_index);
//}else{
//	sprite_index = Shadow_Babi
//}