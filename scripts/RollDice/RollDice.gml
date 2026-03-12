// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function RollDice(character){
	var melee = []
	var venus = []
	var mars = []
	var jupiter = []
	var mercury = []
	
	var _misc = 0
	var _die = 0
	if character.name == "Ouranos"{_misc = 1}
	
	for (var i = 0; i < character.melee; i++){
		_die = irandom(5)+1
		if _die == 5{_die += _misc}
		array_push(melee,_die)
	}
	for (var i = 0; i < character.venus; i++){
		_die = irandom(5)+1
		if _die == 5{_die += _misc}
		array_push(venus,_die)
	}
	for (var i = 0; i < character.mars; i++){
		_die = irandom(5)+1
		if _die == 5{_die += _misc}
		array_push(mars,_die)
	}
	for (var i = 0; i < character.jupiter; i++){
		_die = irandom(5)+1
		if _die == 5{_die += _misc}
		array_push(jupiter,_die)
	}
	for (var i = 0; i < character.mercury; i++){
		_die = irandom(5)+1
		if _die == 5{_die += _misc}
		array_push(mercury,_die)
	}
	if character.name == "Jenna"{mars[array_length(mars)-1] = 0}
	if character.name == "Himi"{venus[array_length(venus)-1] = 0}
	if character.name == "Kai"{mercury[array_length(mercury)-1] = 0}
	if character.name == "Sean"{melee[array_length(melee)-1] = 0}
	
	
	
	var dicepool = [variable_clone(melee),variable_clone(venus),variable_clone(mars),variable_clone(jupiter),variable_clone(mercury)]
	return dicepool
}