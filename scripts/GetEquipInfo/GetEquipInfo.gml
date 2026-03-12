// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
/// @desc Lookup script for armor While Equipped: effects
/// @param {string} inf the plaintext .name info from the item's definition struct
/// @param {struct} player the player it is equipped to, important for a couple of items
/// @returns {struct} struct containing values to be merged into a player struct
function GetEquipInfo(inf, player = global.players[global.turn]){
	
	
	
	var item = variable_clone(player)
	item.onAttack = []
	item.onDraw = []
	item.onRoll = []
	
	switch inf{
		case "Thunder Crown":
			item.ppinc += 2
			break
		case "Psychic Circlet":
			item.ppinc += 1
			break
		case "Bronze Shield":
			item.def += 1
			break
		case "War Ring":
		//handled on its own
			break
		case "Earth Shield":
			item.vres= 2
			item.jres= 2
			break
		case "Dragon Shield":
			item.mares= 2
			item.meres= 2
			break
		case "Adept Ring":
			array_push(item.onAttack, {ppheal: 2, target: "ally"})
			break
		case "Healing Ring":
			array_push(item.onAttack, {healing: 3, target: "ally"})
			break
		case "Unicorn Ring":
			array_push(item.onAttack, {removepoison: true, target: "ally"})
			break
		case "Lucky Cap":
			array_push(item.onRoll, 1)
			break
		case "Lure Cap":
			item.provoke = true
			break
		case "Cleric's Ring":
			//handled on curse check ( cancels curse roll to skip turn, player still cursed )
			break
		case "Fairy Ring":
			//Handled by Dice rolling
			break
		case "Guardian Ring":
			//Handled by Dice Rolling
			break
		case "Herbed Shirt":
			//handled on poison tick (cures poison after tick)
			break
		case "Dragon Robe":
			item.ppdiscount += 1
			break
		case "Silk Robe":
			//handled in attempt roll
			break
		case "Fear Helm":
			item.def += 3
			break
		case "Soul Ring":
			//handled in death script
			break
		case "Stardust Ring":
			array_push(item.onAttack, {inflict_psyseal: true, condition: "two6" })
			break
		case "Spirit Ring":
			array_push(item.onAttack, {range: 4, healing: 6, target:"ally", condition: "two6" })
			break
		case "Iron Shield":
			if item.defmod > 0{ item.def += 2 }else{ item.def += 1 }
			break
		case "Mirrored Shield":
			item.reflect += player.def + player.defmod 
			break
		case "Adept's Clothes":
			item.ppmax += 5
			break
		case "Storm Gear":
			item.vres+= 2
			item.jres+= 2
			break
		case "Water Jacket":
			item.mares += 2
			item.meres += 2
			break	
		// Psynergy-granting items — use grants_spell with the spell base name
		case "Cloak Ball":
			item.grants_spell = "Cloak"
			break
		case "Halt Gem":
			item.grants_spell = "Halt"
			break
		case "Catch Beads":
			item.grants_spell = "Catch"
			break
		case "Orb of Force":
			item.grants_spell = "Force"
			break
		case "Douse Drop":
			item.grants_spell = "Douse"
			break
		default:
			show_debug_message(inf + " Unimplemented")
			break
	}
	
	
	
	return item
}