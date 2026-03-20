if array_length(monsters) == 0 { instance_destroy(); exit }

var _mx = device_mouse_x_to_gui(0)
var _my = device_mouse_y_to_gui(0)
if _mx != _prev_mx or _my != _prev_my { using_kbd = false }
_prev_mx = _mx
_prev_my = _my

if !using_kbd and instance_position(mouse_x, mouse_y, objMonster) {
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

if InputPressed(INPUT_LEFT) {
    selected = (selected == 0) ? array_length(monsters) - 1 : selected - 1
    using_kbd = true
}
if InputPressed(INPUT_RIGHT) {
    selected = (selected == array_length(monsters) - 1) ? 0 : selected + 1
    using_kbd = true
}
if InputPressed(INPUT_CONFIRM) and clickable {
    logic()
}