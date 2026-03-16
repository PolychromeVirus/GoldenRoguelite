// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/BUTTON10005277377 for more information
function CreateOptions(){
	if room == CharacterSelect {
		global.option_buttons = []
		var _begin = instance_create_layer(4,BOTTOMROW,layer_get_id("Instances"),objBegin)
		array_push(global.option_buttons, _begin)
		if file_exists("Save.txt") {
			var _load = instance_create_layer(32,BOTTOMROW,layer_get_id("Instances"),objLoadGame)
			array_push(global.option_buttons, _load)
		}
		if !instance_exists(objLibrary) {
			instance_create_depth(200,BOTTOMROW,0,objLibrary)
		}
		if instance_number(objOptionCursor) < 1 {
			instance_create_depth(0, 0, -1, objOptionCursor)
		}
		return
	}
	if global.inCombat{
		global.option_buttons = []
		array_push(global.option_buttons, instance_create_depth(BUTTON1,BOTTOMROW,0,objAttack))
		array_push(global.option_buttons, instance_create_depth(BUTTON2,BOTTOMROW,0,objItem))
		array_push(global.option_buttons, instance_create_depth(BUTTON3,BOTTOMROW,0,objPsynergy))
		if array_length(global.players[global.turn].djinn) > 0 {
			array_push(global.option_buttons, instance_create_depth(BUTTON4,BOTTOMROW,0,objDjinni))
		}
		if array_length(global.knownSummons) > 0{
			array_push(global.option_buttons, instance_create_depth(BUTTON5,BOTTOMROW,0,objSummon))
		}
		if array_length(global.players[global.turn].rerolls) > 0 {
			array_push(global.option_buttons, instance_create_depth(BUTTONRIGHT2,BOTTOMROW,0,objReroll))
		}
		if instance_number(objOptionCursor) < 1 {
			instance_create_depth(0, 0, -1, objOptionCursor)
		}
	}else if !global.inCombat and !global.inTown{
		DeleteButtons()
		instance_destroy(objMonster)
		instance_destroy(objChallenge)
		global.option_buttons = []
		array_push(global.option_buttons, instance_create_depth(BUTTON1,BOTTOMROW,0,objItem))
		array_push(global.option_buttons, instance_create_depth(BUTTON2,BOTTOMROW,0,objPsynergy))
		if array_length(global.players[global.turn].djinn) > 0 {
			array_push(global.option_buttons, instance_create_depth(BUTTON3,BOTTOMROW,0,objDjinni))
		}

		var _btn_objs = [objFaceButton1,objFaceButton2,objFaceButton3,objFaceButton4]
		for (var _p = 0; _p < array_length(global.players); _p++) {
			var _spr = { image: global.players[_p].portrait, charid: _p, hovertext: "Switch to " + global.players[_p].name }
			instance_create_depth(PORTRAIT1 + (_p * 63), PORTRAITROW, 0, _btn_objs[_p], _spr)
		}

		// Count completed challenges
		var _completed_count = 0
		for (var _ci = 0; _ci < array_length(global.floorChallenges); _ci++) {
			if (global.floorChallenges[_ci].completed) _completed_count++
		}

		// Continue button appears once enough challenges are done
		if (_completed_count >= global.floorRequired) {
			array_push(global.option_buttons, instance_create_depth(BUTTONRIGHT2, BOTTOMROW, 0, objContinue))
		}

		// Town button only available before any challenge is completed
		if (_completed_count == 0 && array_length(global.dungeonlist) > global.dungeon) {
			var _dun = global.dungeonlist[global.dungeon]
			var _has_unvisited_town = false
			for (var _ti = 0; _ti < array_length(_dun.towns); _ti++) {
				var _town_ref = _dun.towns[_ti]
				for (var _tj = 0; _tj < array_length(global.townlist); _tj++) {
					var _town = global.townlist[_tj]
					if ((_town.alias == _town_ref || _town.name == _town_ref) && !array_contains(global.townVisited, _town.name)) {
						_has_unvisited_town = true
						break
					}
				}
				if (_has_unvisited_town) { break }
			}
			if (_has_unvisited_town) {
				array_push(global.option_buttons, instance_create_depth(BUTTONRIGHT2, BOTTOMROW, 0, objTownButton))
			}
		}

		if instance_number(objOptionCursor) < 1 {
			instance_create_depth(0, 0, -1, objOptionCursor)
		}

		// Spawn challenge buttons in the monster area
		global.challenge_buttons = []
		if (array_length(global.floorChallenges) > 0) {
			var _num = array_length(global.floorChallenges)
			var _drawpad = 10
			var _left = _drawpad
			var _right = room_width - _drawpad
			var _split = (_right - _left) / (_num + 1)
			var _drawy = 72
			for (var _ci = 0; _ci < _num; _ci++) {
				var _cx = _drawpad + _split * (_ci + 1) - sprite_get_width(Battle) / 2
				var _cy = _drawy - sprite_get_height(Battle) / 2
				array_push(global.challenge_buttons, instance_create_depth(_cx, _cy, 0, objChallenge, { challenge_index: _ci }))
			}
		}
	}else if global.inTown{
		DeleteButtons()
		global.option_buttons = []
		array_push(global.option_buttons, instance_create_depth(BUTTON1,BOTTOMROW,0,objShopButton))
		array_push(global.option_buttons, instance_create_depth(BUTTON2,BOTTOMROW,0,objItem))
		array_push(global.option_buttons, instance_create_depth(BUTTON3,BOTTOMROW,0,objPsynergy))
		array_push(global.option_buttons, instance_create_depth(BUTTON4,BOTTOMROW,0,objDjinni))
		array_push(global.option_buttons, instance_create_depth(BUTTONRIGHT2,BOTTOMROW,0,objReturn))
		var _btn_objs = [objFaceButton1,objFaceButton2,objFaceButton3,objFaceButton4]
		for (var _p = 0; _p < array_length(global.players); _p++) {
			var _spr = { image: global.players[_p].portrait, charid: _p, hovertext: "Switch to " + global.players[_p].name }
			instance_create_depth(PORTRAIT1 + (_p * 63), PORTRAITROW, 0, _btn_objs[_p], _spr)
		}
		if instance_number(objOptionCursor) < 1 {
			instance_create_depth(0, 0, -1, objOptionCursor)
		}

	}
}
