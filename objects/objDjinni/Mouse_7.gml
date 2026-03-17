if array_length(global.menu_stack) > 0 { exit }

ClearOptions()

var _player = global.players[global.turn]
var _djinn   = _player.djinn
var _items   = []

for (var i = 0; i < array_length(_djinn); i++) {
    var _d      = global.djinnlist[_djinn[i]]
    var _detail = ""
    if global.inCombat and array_length(_player.dicepool) > 0 {
        var _prev = CalcPreview("djinni", _djinn[i], _player)
        if _prev.description != "" and _prev.description != "?" { _detail = _prev.description }
    }
    var _col = c_white
    if !_d.ready {
        _col = _d.spent ? c_red : c_grey
    }
    array_push(_items, {
        name:    _d.name,
        element: _d.element,
        detail:  _detail,
        desc:    _d.text,
        color:   _col,
        data:    { djinn_index: _djinn[i] },
    })
}

var _turn     = global.turn
var _inCombat = global.inCombat
PushMenu(objMenuCarousel, {
    items:         _items,
    description:   "quarter",
    confirm_label:  _inCombat ? "Unleash" : "Swap",
    confirm_sprite: _inCombat ? yes : Switch,
    filter: method({ djinn: _djinn, inCombat: _inCombat }, function(i) {
        var _d = global.djinnlist[djinn[i]]
        if inCombat { return !_d.ready and !_d.spent }
        return false
    }),
    on_confirm: method({ turn: _turn, djinn: _djinn, inCombat: _inCombat }, function(i, item) {
        if inCombat {
            var _id     = item.data.djinn_index
            var _djinni = global.djinnlist[_id]
            CONFIRMSOUND
            if _djinni.ready {
                UnleashDjinn(_id, turn)
                global.djinnlist[_id].spent = true
                InjectLog("Unleashes " + _djinni.name + "!")
            } else if _djinni.spent {
                UnleashDjinn(_id, turn)
                InjectLog(_djinni.name + " is set!")
            }
        } else {
            var _id = item.data.djinn_index
            PushMenu(objDjinniTrade, { sourceDjinn: _id, sourcePlayer: turn, sourceSlot: i })
        }
    }),
})
