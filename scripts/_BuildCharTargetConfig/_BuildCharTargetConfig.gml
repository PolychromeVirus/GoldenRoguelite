/// @func _BuildCharTargetConfig(packet)
/// @desc Returns an objMenuGrid config that replicates objCharTarget behaviour for the given aggression packet.
function _BuildCharTargetConfig(packet) {
    return {
        corner: "bottomright",
        filter: method({p: packet}, function(i) {
            var _pl = global.players[i]
            if p.removepoison {
                var _has_any_bad = _pl.poison or _pl.venom
                if variable_struct_exists(p, "removebad") and p.removebad {
                    _has_any_bad = _has_any_bad or _pl.sleep or (_pl.stun > 0) or (_pl.psyseal > 0)
                }
                if !_has_any_bad { return true }
            }
            if p.healing > 0 and !p.revive and p.dmgtype != "mercury" {
                if _pl.hp == 0 { return true }
            }
            if p.healing > 0 and _pl.hp >= _pl.hpmax
                and !(variable_struct_exists(p, "regen") and p.regen > 0) { return true }
            if p.revive and _pl.hp != 0 { return true }
            if variable_struct_exists(p, "ppheal") and p.ppheal > 0
                and _pl.pp >= _pl.ppmax { return true }
            if variable_struct_exists(p, "trade") and p.trade
                and array_length(_pl.inventory) > 4 { return true }
            return false
        }),
        on_confirm: method({p: packet}, function(selected) {
            var caster = global.players[global.turn]
            var sel    = global.players[selected]
            var _grid  = instance_find(objMenuGrid, 0)
            var _gui_x = _grid.gridX + (selected mod 2) * _grid.cellW       + 64
            var _gui_y = _grid.gridY + (selected div 2) * _grid.cellStrideY + 64

            // Trade
            if variable_struct_exists(p, "trade") and p.trade and array_length(sel.inventory) < 5 {
                array_delete(global.players[global.turn].inventory, p.slot, 1)
                array_push(sel.inventory, p.itemid)
                InjectLog(global.itemcardlist[p.itemid].name + " transferred to " + sel.name)
                _FinishCharTarget(p)
                exit
            }

            var choice       = false
            var _heal_amount = p.healing
            if sel.halfheal and _heal_amount > 0 { _heal_amount = floor(_heal_amount / 2) }
            var _ratio_amount = 0
            if variable_struct_exists(p, "healingratio") and p.healingratio != 0 {
                _ratio_amount = sel.hpmax * p.healingratio
                if sel.halfheal and _ratio_amount > 0 { _ratio_amount = floor(_ratio_amount / 2); HEALSOUND }
            }

            if !variable_struct_exists(p, "delayed") or !p.delayed {
                // Healer bonus
                if _heal_amount > 0 and (caster.name == "Mia" or caster.name == "Rief") { _heal_amount += 1 }

                if p.revive and sel.hp <= 0 {
                    sel.hp = min(_heal_amount, sel.hpmax)
                    sel.heal_flash = 12
					HEALSOUND
                    instance_create_depth(0, 0, -200, objDamageNumber, {amount: sel.hp, world_x: _gui_x, world_y: _gui_y, col: global.c_important, gui_mode: true})
                    choice = true
                }

                if _heal_amount > 0 and sel.hp != sel.hpmax {
                    var _oldhp = variable_clone(sel.hp)
                    sel.hp = min(sel.hpmax, sel.hp + _heal_amount)
                    InjectLog(sel.name + " is healed " + string(_heal_amount) + " (" + string(_oldhp) + " to " + string(sel.hp) + ")")
                    sel.heal_flash = 12
                    instance_create_depth(0, 0, -200, objDamageNumber, {amount: sel.hp - _oldhp, world_x: _gui_x, world_y: _gui_y, col: global.c_important, gui_mode: true})
					HEALSOUND
                    choice = true
                }

                if _ratio_amount != 0 {
                    var _old_ratio_hp = variable_clone(sel.hp)
                    sel.hp = min(sel.hpmax, sel.hp + _ratio_amount)
                    if _ratio_amount > 0 {
                        sel.heal_flash = 12
						HEALSOUND
                        instance_create_depth(0, 0, -200, objDamageNumber, {amount: sel.hp - _old_ratio_hp, world_x: _gui_x, world_y: _gui_y, col: global.c_important, gui_mode: true})
                    }
                }

                if variable_struct_exists(p, "ppheal") and p.ppheal > 0 and sel.pp != sel.ppmax {
                    var _oldpp = variable_clone(sel.pp)
                    sel.pp = min(sel.ppmax, sel.pp + p.ppheal)
                    sel.heal_flash = 12
					HEALSOUND
                    instance_create_depth(0, 0, -200, objDamageNumber, {amount: sel.pp - _oldpp, world_x: _gui_x, world_y: _gui_y, col: global.c_important, gui_mode: true})
                    choice = true
                }

                if p.removepoison and (sel.poison or sel.venom) {
                    sel.poison = false
                    sel.venom  = false
                    choice = true
                }

                if variable_struct_exists(p, "removebuffs") and p.removebuffs {
                    sel.atkmod = 0
                    sel.defmod = 0
                    choice = true
                }

                if variable_struct_exists(p, "defup") and p.defup > 0 {
                    sel.defmod += p.defup
                    sel.defmod_fresh = true
                    InjectLog(sel.name + " gains " + string(p.defup) + " DEF!")
                    choice = true
                    if caster.name == "Kendall" { caster.defmod += 1; caster.defmod_fresh = true }
                }

                if variable_struct_exists(p, "atkup") and p.atkup > 0 {
                    sel.atkmod += p.atkup
                    sel.atkmod_fresh = true
                    InjectLog(sel.name + " gains " + string(p.atkup) + " ATK!")
                    choice = true
                    if caster.name == "Kendall" { caster.defmod += 1; caster.defmod_fresh = true }
                }

                if variable_struct_exists(p, "rootTokens") and p.rootTokens > 0 {
                    sel.rootTokens += p.rootTokens
                    InjectLog(sel.name + " gains " + string(p.rootTokens) + " root tokens!")
                    choice = true
                    if caster.name == "Kendall" { caster.defmod += 1; caster.defmod_fresh = true }
                }

                if variable_struct_exists(p, "regen") and p.regen > 0 {
                    if !variable_struct_exists(sel, "regen")   { sel.regen   = 0 }
                    if !variable_struct_exists(sel, "regheal") { sel.regheal = 0 }
                    sel.regen   += p.regen
                    sel.regheal  = p.regheal
                    InjectLog(sel.name + " will regenerate " + string(p.regheal) + " health!")
                    if caster.name == "Kendall" { caster.defmod += 1; caster.defmod_fresh = true }
                    choice = true
                }

                if variable_struct_exists(p, "aegiscurse") and p.aegiscurse {
                    sel.aegiscurse = true
                    InjectLog(sel.name + "'s defense is boosted")
                }

                if variable_struct_exists(p, "cloak") and p.cloak {
                    sel.cloak = true
                    caster.cloaking = selected
                    caster.cloak_fresh = true
                    InjectLog(sel.name + " hides away from damage")
                    if caster.name == "Kendall" { caster.defmod += 1; caster.defmod_fresh = true }
					choice = true
                }

                if variable_struct_exists(p, "onConfirm") and variable_struct_exists(p.onConfirm, "grant_extra_turn") and p.onConfirm.grant_extra_turn > 0 {
                    global.players[selected].extraTurns += p.onConfirm.grant_extra_turn
                    InjectLog(global.players[selected].name + " is energized!")
                    choice = true
                    if caster.name == "Kendall" { caster.defmod += 1; caster.defmod_fresh = true }
                }

                if variable_struct_exists(p, "removebad") and p.removebad {
                    sel.poison  = false
                    sel.stun    = 0
                    sel.sleep   = false
                    sel.psyseal = false
                    sel.venom   = false
                    choice = true
                }
            } else {
                sel.delaydata = p.delaydata
                choice = true
            }

            if choice {
                if variable_global_exists("pendingPPCost") and global.pendingPPCost > 0 {
                    global.players[global.pendingPPCaster].pp -= global.pendingPPCost
                    global.pendingPPCost = 0
                }
                // Deferred caster self-heal (e.g. Cure heals both caster and ally)
                if variable_struct_exists(p, "caster_heal") and p.caster_heal > 0 {
                    var _ch = p.caster_heal
                    if caster.halfheal { _ch = floor(_ch / 2) }
                    if caster.hp < caster.hpmax {
                        caster.hp = min(caster.hpmax, caster.hp + _ch)
                        caster.heal_flash = 12
                    }
                }
                if variable_struct_exists(p, "itemid") and p.itemid != -1 {
                    array_push(global.discard, p.itemid)
                    array_delete(global.players[global.turn].inventory, p.itemid, 1)
                }
                _FinishCharTarget(p)
            }
        }),
        on_cancel: method({p: packet}, function() {
            if variable_struct_exists(p, "committed") and p.committed {
                if array_length(global.attackQueue) > 0 {
                    PopAll()
					ProcessAttackQueue()
                } else {
                    instance_create_depth(0, 0, 0, TurnDelay, { wait: 30, on_complete: NextTurn })
                }
            }
        }),
    }
}

/// @func _FinishCharTarget(packet)
/// @desc Clear menu stack and route to next state after ally targeting resolves.
function _FinishCharTarget(packet) {
    if global.inCombat {
        while array_length(global.menu_stack) > 0 { PopMenu() }
        if array_length(global.attackQueue) > 0 {
            ProcessAttackQueue()
        } else {
            instance_create_depth(0, 0, 0, TurnDelay, { wait: 30, on_complete: NextTurn })
        }
    } else {
        // Small delay so player sees the result, then pop back to item menu
        instance_create_depth(0, 0, 0, TurnDelay, { wait: 60, on_complete: PopMenu })
    }
}
