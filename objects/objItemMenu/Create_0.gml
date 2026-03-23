mode = 0 // 0 = inventory, 1 = equipment
btn_selected = 0
bottom_buttons = []
lastmode = -1
others = []
otherslast = []
kbd_mode = false
_prev_mx = mouse_x
_prev_my = mouse_y

DeleteButtons()

clickable = false
alarm_set(0,1)

_build_buttons = method(id, function() {
    lastmode = -1  // force Step_0 to rebuild buttons next step
})

_do_action = method(id, function(btn_inst) {
    if !instance_exists(btn_inst) { exit }
    var _oi = btn_inst.object_index
    var _player = global.players[global.turn]

    // Cancel button — delegate to objCancel's own handler
    if _oi == objCancel {
        with (btn_inst) { event_perform(ev_mouse, ev_left_release) }
        exit
    }

    if mode == 1 {
        // === EQUIPMENT MODE ===
        if _oi == objButton2 { // Unequip
            if selected == 0 {
                InjectLog("You must always have a weapon equipped!")
            } else {
                var _armorIdx  = selected - 1
                var _armorItem = _player.armor[_armorIdx]
                var _item      = global.itemcardlist[_armorItem]
                if (_item.cursed == "TRUE" or _item.cursed == true) {
                    InjectLog("This item is cursed and cannot be removed!")
                } else if array_length(_player.inventory) >= 5 {
                    InjectLog("Inventory is full!")
                } else {
                    array_delete(_player.armor, _armorIdx, 1)
                    array_push(_player.inventory, _armorItem)
                    CreateDicePool()
                    if !global.inCombat { _player.dicepool = RollDice(_player) }
                    selected = clamp(selected, 0, array_length(_player.armor))
                }
            }
        }
    } else {
        // === INVENTORY MODE ===
        var _inv = _player.inventory
        if array_length(_inv) < 1 { exit }
        if selected >= array_length(_inv) { selected = array_length(_inv) - 1 }
        var _selItem = _inv[selected]

        if _oi == objConfirm { // Use
            if global.itemcardlist[_selItem].type == "Healing"
            or global.itemcardlist[_selItem].type == "Battle"
            or global.itemcardlist[_selItem].name == "Lucky Medal" {
                ClearOptions()
                DeleteButtons()
                OnUse(_selItem, selected, _player)
            }
        }

        if _oi == objButton2 { // Equip
            if isEquippable(_selItem) {
                if global.itemcardlist[_selItem].type != "Armor" {
                    var _oldWep = string(_player.weapon)
                    _player.weapon = _selItem
                    array_delete(_player.inventory, selected, 1)
                    array_push(_player.inventory, _oldWep)
                    CreateDicePool()
                    _player.dicepool = RollDice(_player)
                    if global.inCombat { PopMenu(); NextTurn(); exit }
                } else {
                    var _itemSlot    = global.itemcardlist[_selItem].slot
                    var _conflictIdx = -1
                    for (var _i = 0; _i < array_length(_player.armor); _i++) {
                        if global.itemcardlist[_player.armor[_i]].slot == _itemSlot {
                            _conflictIdx = _i; break
                        }
                    }
                    if _conflictIdx >= 0 {
                        PushMenu(objMenuDialog, {
                            text:    "Replace " + global.itemcardlist[_player.armor[_conflictIdx]].name + "?",
                            subtext: "Equip " + global.itemcardlist[_selItem].name,
                            buttons: [
                                {
                                    label: "Swap",
                                    on_click: method({ pl: _player, ni: _selItem, ai: _conflictIdx, sl: selected }, function() {
                                        var _old = pl.armor[ai]
                                        array_delete(pl.armor, ai, 1)
                                        array_push(pl.inventory, _old)
                                        array_delete(pl.inventory, sl, 1)
                                        array_push(pl.armor, ni)
                                        CreateDicePool()
                                        if global.inCombat { global.players[global.turn].dicepool = RollDice(global.players[global.turn]); PopMenu(); PopMenu(); NextTurn() }
                                        else { PopMenu() }
                                    }),
                                },
                                { label: "Cancel", sprite: no, on_click: function() { PopMenu() } },
                            ],
                        })
                    } else {
                        if array_length(_player.armor) < 4 {
                            array_push(_player.armor, _selItem)
                            array_delete(_player.inventory, selected, 1)
                            CreateDicePool()
                            _player.dicepool = RollDice(_player)
                            if global.inCombat { PopMenu(); NextTurn(); exit }
                        } else {
                            InjectLog("No free armor slot!")
                        }
                    }
                }
            }
        }

        if _oi == objButton3 { // Discard / Sell
            var _type = global.itemcardlist[_selItem].type
            var _name = global.itemcardlist[_selItem].name
            if _type != "Healing" and _type != "Battle" {
                if global.inTown and _name == "Orihalcon" { global.gold += 50 }
                else if global.inTown {
                    var _eoleo = false
                    for (var _e = 0; _e < array_length(global.players); _e++) {
                        if global.players[_e].name == "Eoleo" { _eoleo = true }
                    }
                    global.gold += _eoleo ? 5 : 2
                }
            }
            if array_length(_player.inventory) > 0 { array_delete(_player.inventory, selected, 1) }
        }

        if _oi == objButton4 { // Give
            var _struct = variable_clone(global.AggressionSchema)
            _struct.trade  = true
            _struct.target = "ally"
            _struct.itemid = _selItem
            _struct.slot   = selected
            PushMenu(objMenuGrid, _BuildCharTargetConfig(_struct))
        }
    }
})