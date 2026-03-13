// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function ClearAllTokens(character,poi = false){
	if poi{
		character.poison = false
		character.venom = false
	}
	character.stun = 0
	character.sleep = false
	character.psyseal = false
	character.delude = false
	character.atkmod = 0
	character.defmod = 0
	character.atkmod_fresh = false
	character.defmod_fresh = false
	character.rootTokens = 0
	character.regen = 0
	character.delayed = false
	character.delaydata = {}
}