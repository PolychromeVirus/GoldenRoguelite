// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function GetStatus(char){
	var statarray = []

		if char.poison {array_push(statarray,Poison)}
		if char.stun > 0 {array_push(statarray,Bolt)}
		if char.sleep {array_push(statarray,Sleep)}
		if char.psyseal {array_push(statarray,Psy_Seal)}
		if char.venom {array_push(statarray,Poison_Flow)}
		if variable_struct_exists(char, "delude") and char.delude {array_push(statarray,Delude)}
		
	return statarray
}