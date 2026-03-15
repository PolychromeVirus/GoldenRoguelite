// Click-to-confirm on 2x2 grid
if variable_instance_exists(self, "confirmed") and confirmed { exit }

if !use_kbd_selected {
    var _mx = device_mouse_x_to_gui(0)
    var _my = device_mouse_y_to_gui(0)

    var _col = floor((_mx - gridX) / cellW)
    var _row = floor((_my - gridY) / cellStrideY)
    if _col < 0 or _col > 1 or _row < 0 or _row > 1 { exit }
    // Ignore clicks in the padding between rows
    var _localY = (_my - gridY) - _row * cellStrideY
    if _localY > cellH { exit }
    var _clicked = _row * 2 + _col
    if _clicked < 0 or _clicked >= array_length(global.players) { exit }

    selected = _clicked
}
use_kbd_selected = false

var caster = global.players[global.turn]
var sel = global.players[selected]

// Validation checks — exit if invalid target
if revive and sel.hp > 0 { exit }
if sel.hp <= 0 and dmgtype != "mercury" and !revive { exit }
if removepoison and !sel.poison { exit }
if healing > 0 and sel.hp >= sel.hpmax and !variable_instance_exists(id, "regen") { exit }
if ppheal > 0 and sel.pp >= sel.ppmax { exit }
if trade and array_length(sel.inventory) > 4 { exit }

// Healer bonus
if healing > 0 and (caster.name == "Mia" or caster.name == "Rief") {
	healing += 1
}

// Deduct deferred PP cost
if variable_global_exists("pendingPPCost") and global.pendingPPCost > 0 {
	global.players[global.pendingPPCaster].pp -= global.pendingPPCost
	global.pendingPPCost = 0
}

// Trade logic
if trade and array_length(sel.inventory) < 5 {
	array_delete(global.players[global.turn].inventory, slot, 1)
	array_push(sel.inventory, itemid)
	InjectLog(global.itemcardlist[itemid].name + " transferred to " + sel.name)
	show_debug_message("itemid: " + string(itemid) + " slot: " + string(slot))
	confirmed = true
	ClearOptions()
	DeleteButtons()
	alarm_set(0, 30)
	exit
}

var choice = false
var _heal_amount = healing
if (sel.halfheal and _heal_amount > 0) { _heal_amount = floor(_heal_amount / 2) }
var _ratio_amount = 0
if (healingratio != 0) {
	_ratio_amount = sel.hpmax * healingratio
	if (sel.halfheal and _ratio_amount > 0) { _ratio_amount = floor(_ratio_amount / 2) }
}

// Damage number position based on grid cell
var _gui_x = gridX + (_clicked mod 2) * cellW + 64
var _gui_y = gridY + (_clicked div 2) * cellStrideY + 64

if !delayed {
	if revive and sel.hp <= 0 {
		sel.hp = min(_heal_amount, sel.hpmax)
		sel.heal_flash = 12
		instance_create_depth(0, 0, -200, objDamageNumber, { amount: sel.hp, world_x: _gui_x, world_y: _gui_y, col: global.c_important, gui_mode: true })
		choice = true
	}

	if _heal_amount > 0 and sel.hp != sel.hpmax {
		var oldhp = variable_clone(sel.hp)
		sel.hp = min(sel.hpmax, sel.hp + _heal_amount)
		InjectLog(sel.name + " is healed " + string(_heal_amount) + " (" + string(oldhp) + " to " + string(sel.hp) + ")")
		sel.heal_flash = 12
		instance_create_depth(0, 0, -200, objDamageNumber, { amount: sel.hp - oldhp, world_x: _gui_x, world_y: _gui_y, col: global.c_important, gui_mode: true })
		choice = true
	}

	if _ratio_amount != 0 {
		var _old_ratio_hp = variable_clone(sel.hp)
		sel.hp = min(sel.hpmax, sel.hp + _ratio_amount)
		if _ratio_amount > 0 {
			sel.heal_flash = 12
			instance_create_depth(0, 0, -200, objDamageNumber, { amount: sel.hp - _old_ratio_hp, world_x: _gui_x, world_y: _gui_y, col: global.c_important, gui_mode: true })
		}
	}

	if ppheal > 0 and sel.pp != sel.ppmax {
		var _oldpp = variable_clone(sel.pp)
		sel.pp = min(sel.ppmax, sel.pp + ppheal)
		sel.heal_flash = 12
		instance_create_depth(0, 0, -200, objDamageNumber, { amount: sel.pp - _oldpp, world_x: _gui_x, world_y: _gui_y, col: global.c_important, gui_mode: true })
		choice = true
	}

	if removepoison and sel.poison {
		sel.poison = false
		sel.venom = false
		choice = true
	}

	if removebuffs {
		sel.atkmod = 0
		sel.defmod = 0
		choice = true
	}

	if defup > 0 {
		sel.defmod += defup
		sel.defmod_fresh = true
		InjectLog(sel.name + " gains " + string(defup) + " DEF!")
		choice = true
		if caster.name == "Kendall" { caster.defmod += 1; caster.defmod_fresh = true }
	}

	if atkup > 0 {
		sel.atkmod += atkup
		sel.atkmod_fresh = true
		InjectLog(sel.name + " gains " + string(atkup) + " ATK!")
		choice = true
		if caster.name == "Kendall" { caster.defmod += 1; caster.defmod_fresh = true }
	}

	sel.rootTokens += rootTokens
	if rootTokens > 0 {
		InjectLog(sel.name + " gains " + string(rootTokens) + " root tokens!"); choice = true
		if caster.name == "Kendall" { caster.defmod += 1; caster.defmod_fresh = true }
	}

	if variable_instance_exists(self, "regen") {
		if !variable_struct_exists(sel, "regen") {
			sel.regen = 0
		}
		if !variable_struct_exists(sel, "regheal") {
			sel.regheal = 0
		}
		sel.regen = regen
		sel.regheal = regheal
		if regen > 0 {
			InjectLog(sel.name + " will regenerate " + string(regheal) + " health!")
			if caster.name == "Kendall" { caster.defmod += 1; caster.defmod_fresh = true }
		}
		choice = true
	}

	if aegiscurse {
		sel.aegiscurse = true
		InjectLog(sel.name + "'s defense is boosted")
	}

	if cloak {
		sel.cloak = true
		caster.cloaking = selected
		caster.cloak_fresh = true
		InjectLog(sel.name + " hides away from damage")
		if caster.name == "Kendall" { caster.defmod += 1; caster.defmod_fresh = true }
	}

	if variable_struct_exists(onConfirm, "grant_extra_turn") and onConfirm.grant_extra_turn > 0 {
		global.players[selected].extraTurns += onConfirm.grant_extra_turn
		InjectLog(global.players[selected].name + " is energized!")
		choice = true
		if caster.name == "Kendall" { caster.defmod += 1; caster.defmod_fresh = true }
	}

	if removebad {
		sel.poison = false
		sel.stun = 0
		sel.sleep = false
		sel.psyseal = false
		sel.venom = false
		choice = true
	}
} else {
	sel.delaydata = delaydata
	choice = true
}

if choice == true {
	if itemid != -1 {
		array_push(global.discard, itemid)
		array_delete(global.players[global.turn].inventory, itemid, 1)
	}
	confirmed = true
	ClearOptions()
	DeleteButtons()
	alarm_set(0, 30)
	exit
}
