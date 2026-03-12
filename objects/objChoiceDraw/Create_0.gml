// Choice Draw: pick 1 of 3 cards from deck
choices = []
selected = 0
draw_player = global.choiceDrawQueue[0].player

// Pull 3 cards from deck (or fewer if deck is small)
var _count = min(3, array_length(global.deck))
for (var i = 0; i < _count; i++) {
	array_push(choices, global.deck[0])
	array_delete(global.deck, 0, 1)
}

instance_create_depth(sprite_width, 0, 0, objHalfMenu)
ClearOptions()

var sprite = { image: yes, text: "Select" }
instance_create_depth(36, 124, 0, objConfirm, sprite)
instance_create_depth(92, 124, 0, objCancel)
