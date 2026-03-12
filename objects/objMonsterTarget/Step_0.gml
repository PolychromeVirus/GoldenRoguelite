if array_length(monsters) == 0 { instance_destroy(); exit }
if instance_position(mouse_x, mouse_y, objMonster){ 
		selected = instance_position(mouse_x, mouse_y, objMonster).slotID
	
	}
if selected >= array_length(monsters) { selected = array_length(monsters) - 1 }
if selected < 0 { selected = 0 }
var mon = monsters[selected]

var _status_text = ""
if mon.poison { _status_text += " Poison" }
if mon.venom { _status_text += " Venom" }
if mon.stun > 0 { _status_text += " Stun(" + string(mon.stun) + ")" }
if mon.sleep { _status_text += " Sleep" }
if mon.delude { _status_text += " Delude" }
if mon.psyseal { _status_text += " PsySeal" }

global.textdisplay = "HP: " + string(mon.monsterHealth) + "/" + string(mon.maxhp)
            + " [" + mon.element + "] Weak: " + mon.weakness
if mon.atkmod != 0 { _status_text += " ATK" + (mon.atkmod > 0 ? "+" : "") + string(mon.atkmod) }
if mon.defmod != 0 { _status_text += " DEF" + (mon.defmod > 0 ? "+" : "") + string(mon.defmod) }
if _status_text != "" { global.textdisplay += _status_text }