if global.players[global.turn].name == "Kraden"{
		var _gui_x = 237 + global.turn * 400
		var _gui_y = 165
		global.players[global.turn].pp = min(global.players[global.turn].pp + WeaponAttack(true,false).dam, global.players[global.turn].ppmax)
		instance_create_depth(0,0,-200,objDamageNumber,
            {
                amount: WeaponAttack(true,false).dam,
                world_x: _gui_x,
                world_y: _gui_y,
                col: global.c_important,
				gui_mode: true
            })
			NextTurn()


}else{
	WeaponAttack()
}