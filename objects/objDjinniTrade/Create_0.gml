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

_confirm = method(id, function() {
    var _source    = global.players[sourcePlayer]
    var _target    = global.players[selected]
    var _djinnName = global.djinnlist[sourceDjinn].name

    if targetSlot < array_length(_target.djinn) {
        var _targetDjinnID   = _target.djinn[targetSlot]
        var _targetDjinnName = global.djinnlist[_targetDjinnID].name
        _source.djinn[sourceSlot] = _targetDjinnID
        _target.djinn[targetSlot] = sourceDjinn
        InjectLog(_source.name + " traded " + _djinnName + " for " + _target.name + "'s " + _targetDjinnName + "!")
    } else {
        array_delete(_source.djinn, sourceSlot, 1)
        array_push(_target.djinn, sourceDjinn)
        InjectLog(_source.name + " gave " + _djinnName + " to " + _target.name + "!")
    }

    CreateDicePool()

    if global.inCombat {
        PopAll()
    } else {
        PopMenu() // trade screen only; return to carousel
    }
})

clickable = false
