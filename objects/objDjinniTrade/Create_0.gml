// Receive params from creation
sourceDjinn = sourceDjinn
sourcePlayer = sourcePlayer
sourceSlot = sourceSlot

// Find first player that isn't the source
selected = 0
for (var i = 0; i < array_length(global.players); i++) {
	if i != sourcePlayer { selected = i; break }
}

targetSlot = 0

_build_buttons = method(id, function() {
    var confirmSprite = {image: Switch, text: "Confirm"}
    instance_create_depth(BUTTON1, BOTTOMROW, 0, objConfirm, confirmSprite)
    instance_create_depth(BUTTON2, BOTTOMROW, 0, objCancel)
    clickable = true
})

clickable = false
