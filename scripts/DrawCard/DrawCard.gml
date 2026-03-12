// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function DrawCard(player, choice = false){
	if (choice) {
		array_push(global.choiceDrawQueue, { player: player })
		return ["", false]
	}
	var top = global.deck[0]
	var _name = global.itemcardlist[top].name
	if array_length(player.inventory) < 5 and !global.itemcardlist[top].onDraw{
		array_push(player.inventory,global.deck[0])
		InjectLog(player.name + " drew " + _name)
		array_delete(global.deck,0,1)
	}else if global.itemcardlist[top].onDraw{
		// Queue onDraw effects for post-battle resolution or manual ProcessPostBattleQueue call
		array_push(global.postBattleQueue, {type: "onDraw", item: top, player: player})
		InjectLog(player.name + " drew " + _name)
		array_delete(global.deck,0,1)
	}else{
		// Inventory full
		array_delete(global.deck,0,1)
		if global.itemcardlist[top].type == "Special"{
			// Special cards shuffle back in and retry
			array_push(global.deck, top)
			global.deck = array_shuffle(global.deck)
			return DrawCard(player)
		}else{
			array_push(global.discard, top)
			InjectLog(player.name + " drew " + _name + " but their inventory was full!")
			return [_name, true]
		}
	}
	// Silent discard to grow shop inventory
	

	return [_name, false]
}
