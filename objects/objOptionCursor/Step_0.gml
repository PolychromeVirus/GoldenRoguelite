var _has_challenges = array_length(global.challenge_buttons) > 0

// Clamp row: only allow row 1 if challenge buttons exist
if !_has_challenges { row = 0 }
row = clamp(row, 0, _has_challenges ? 1 : 0)

// Pick active array
var _active = (row == 1) ? global.challenge_buttons : global.option_buttons

// Clean up stale entries from front of active array
while (array_length(_active) > 0 && !instance_exists(_active[0])) {
    array_delete(_active, 0, 1)
    if selected > 0 { selected-- }
}
if array_length(global.option_buttons) == 0 { exit }
_active = (row == 1) ? global.challenge_buttons : global.option_buttons
if array_length(_active) == 0 { row = 0; _active = global.option_buttons }
selected = clamp(selected, 0, array_length(_active) - 1)

// Mouse/keyboard mode detection
if mouse_x != _prev_mx or mouse_y != _prev_my { using_kbd = false }
_prev_mx = mouse_x
_prev_my = mouse_y
global.using_kbd = using_kbd

// Reset all button keyboard highlights
for (var _i = 0; _i < array_length(global.option_buttons); _i++) {
    if instance_exists(global.option_buttons[_i]) {
        global.option_buttons[_i].keyboard_hover = false
    }
}
for (var _i = 0; _i < array_length(global.challenge_buttons); _i++) {
    if instance_exists(global.challenge_buttons[_i]) {
        global.challenge_buttons[_i].keyboard_hover = false
    }
}
// Highlight selected and set tooltip in keyboard mode
global.kbd_tooltip = ""
if using_kbd and !global.pause and array_length(_active) > 0 {
    var _btn = _active[selected]
    _btn.keyboard_hover = true
    if variable_instance_exists(_btn, "hovertext") and _btn.hovertext != "" {
        global.kbd_tooltip = _btn.hovertext
    } else {
        var _oi = _btn.object_index
        if      _oi == objAttack     { global.kbd_tooltip = "Attack" }
        else if _oi == objItem       { global.kbd_tooltip = "Items" }
        else if _oi == objPsynergy   { global.kbd_tooltip = "Psynergy" }
        else if _oi == objDjinni     { global.kbd_tooltip = "Djinn" }
        else if _oi == objSummon     { global.kbd_tooltip = "Summon" }
        else if _oi == objReroll     { global.kbd_tooltip = "Reroll" }
        else if _oi == objContinue   { global.kbd_tooltip = "Continue" }
        else if _oi == objTownButton { global.kbd_tooltip = "Town" }
        else if _oi == objShopButton { global.kbd_tooltip = "Shop" }
    }
}

if global.pause { exit }

if InputPressed(INPUT_UP) && _has_challenges {
    row = 1
    selected = clamp(selected, 0, array_length(global.challenge_buttons) - 1)
    using_kbd = true
}
if InputPressed(INPUT_DOWN) && row == 1 {
    row = 0
    selected = clamp(selected, 0, array_length(global.option_buttons) - 1)
    using_kbd = true
}
if InputPressed(INPUT_LEFT) {
    selected--
    if selected < 0 { selected = array_length(_active) - 1 }
    using_kbd = true
}
if InputPressed(INPUT_RIGHT) {
    selected++
    if selected >= array_length(_active) { selected = 0 }
    using_kbd = true
}
if InputPressed(INPUT_CONFIRM) {
    with (_active[selected]) {
        event_perform(ev_mouse, ev_left_release)
    }
}
