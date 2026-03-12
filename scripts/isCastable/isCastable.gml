// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function isCastable(spell,player){
	if spell.cost > player.pp {return false}
	// Out of combat: only utility spells are castable
	if !global.inCombat and (spell.mode != "overworld" and spell.mode != "both") { return false }
	if global.inCombat and (spell.mode != "battle" and spell.mode != "both"){return false}
	if spell.mode == "prompt"{return false}
	if array_contains(player.equip_spells, FindPsyID(spell.name,0)){ return true }
	switch spell.element{
		case "Venus":
			if player.venus == 0{return false}
			break
		case "Mars":
			if player.mars == 0{return false}
			break
		case "Jupiter":
			if player.jupiter == 0{return false}
			break
		case "Mercury":
			if player.mercury == 0{return false}
			break
	}
	return true
}