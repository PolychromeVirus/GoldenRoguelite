if InputPressed(INPUT_LEFT) {
    if selected == 0 { selected = array_length(monsters) - 1 }
    else { selected -= 1 }
}
if InputPressed(INPUT_RIGHT) {
    if selected == array_length(monsters) - 1 { selected = 0 }
    else { selected += 1 }
}

if array_length(monsters) == 0 { instance_destroy(); exit }
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

global.textdisplay = "Charon: " + string(kills_remaining) + " kill(s) left | HP: " + string(mon.monsterHealth) + "/" + string(mon.maxhp)
            + " [" + mon.element + "]"
if _status_text != "" { global.textdisplay += _status_text }
