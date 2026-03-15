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

// Reset all button tints
for (var _i = 0; _i < array_length(global.option_buttons); _i++) {
    if instance_exists(global.option_buttons[_i]) {
        global.option_buttons[_i].image_blend = c_white
    }
}
for (var _i = 0; _i < array_length(global.challenge_buttons); _i++) {
    if instance_exists(global.challenge_buttons[_i]) {
        global.challenge_buttons[_i].image_blend = c_white
    }
}
// Highlight selected only in keyboard mode
if using_kbd and !global.pause { _active[selected].image_blend = c_ltgray }

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
