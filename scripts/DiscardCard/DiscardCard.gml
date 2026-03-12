function DiscardCard(){
	if (array_length(global.deck) > 0) {
		var _silent = global.deck[0]
		array_delete(global.deck, 0, 1)
		array_push(global.discard, _silent)
	}
}