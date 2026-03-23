// Game over countdown
if global.gameover {
    global.gameover_timer--
    if global.gameover_timer == 239 {
        audio_stop_all()
        while array_length(global.menu_stack) > 0 { PopMenu() }
    }
    if global.gameover_timer == 180 {
        var _go_snd = audio_play_sound(_09_Game_Over__Variation_, 1, true)
        audio_sound_gain(_go_snd, 0.5, 0)
    }
    if global.gameover_timer <= 0 {
        global.gameover = false
        // Restore background color
        var _bg = layer_background_get_id(layer_get_id("Background"))
        layer_background_blend(_bg, c_white)
        room_goto(PostGame)
    }
    exit
}

global.pause = (array_length(global.menu_stack) > 0)
global._anim_clock = (global._anim_clock + 1) mod ANIM_TICK
_ProcessShake()

// Tick flash timers every step regardless of what's drawn
for (var _fi = 0; _fi < array_length(global.players); _fi++) {
    var _fp = global.players[_fi]
    if _fp.heal_flash > 0  { _fp.heal_flash-- }
    if _fp.flash_timer > 0 { _fp.flash_timer-- }
}


var _bg_layer = layer_background_get_id(layer_get_id("Background"))

if room != CharacterSelect and !global.gameover{
	if !global.inTown and !global.inCombat and !layer_background_get_sprite(global.genbackground){

		layer_background_sprite(_bg_layer, global.genbackground)
	}else if global.inTown{layer_background_sprite(_bg_layer, World_Map)}
}

// Reset static-screen kbd state on room change
if room != _cs_last_room {
    cs_kbd = false; cs_row = 0; cs_sel = 0
    global.using_kbd = false
}
_cs_last_room = room

// ── Keyboard nav for CharacterSelect ─────────────────────────────────────────
if room == CharacterSelect and array_length(global.menu_stack) == 0 {
    // mouse movement cancels keyboard mode
    if mouse_x != _cs_prev_mx or mouse_y != _cs_prev_my { cs_kbd = false }
    _cs_prev_mx = mouse_x
    _cs_prev_my = mouse_y
    global.using_kbd = cs_kbd

    // rows: 0 = char portraits (objChar1-4), 1 = action buttons (Begin, LoadGame, Library)
    var _char_row  = [instance_find(objChar1,0), instance_find(objChar2,0), instance_find(objChar3,0), instance_find(objChar4,0)]
    var _act_row   = [instance_find(objBegin,0), instance_find(objLoadGame,0), instance_find(objLibrary,0)]
    var _active    = (cs_row == 0) ? _char_row : _act_row
    var _alen      = array_length(_active)

    // clear all highlights
    for (var _i = 0; _i < 4; _i++) { if instance_exists(_char_row[_i]) { _char_row[_i].keyboard_hover = false } }
    for (var _i = 0; _i < 3; _i++) { if instance_exists(_act_row[_i])  { _act_row[_i].keyboard_hover  = false } }

    if cs_kbd {
        cs_sel = clamp(cs_sel, 0, _alen - 1)
        var _cur = _active[cs_sel]
        if instance_exists(_cur) {
            _cur.keyboard_hover = true
            if variable_instance_exists(_cur, "hovertext") { global.kbd_tooltip = _cur.hovertext }
        }
        if InputPressed(INPUT_LEFT)  { cs_sel = (cs_sel == 0) ? _alen - 1 : cs_sel - 1; MENUMOVE }
        if InputPressed(INPUT_RIGHT) { cs_sel = (cs_sel == _alen - 1) ? 0 : cs_sel + 1; MENUMOVE }
        if InputPressed(INPUT_UP) and cs_row == 1 {
            cs_row = 0; cs_sel = clamp(cs_sel, 0, 3); MENUMOVE
        }
        if InputPressed(INPUT_DOWN) and cs_row == 0 {
            cs_row = 1; cs_sel = clamp(cs_sel, 0, 2); MENUMOVE
        }
        if InputPressed(INPUT_CONFIRM) {
            var _btn = _active[cs_sel]
            if instance_exists(_btn) { with (_btn) { event_perform(ev_mouse, ev_left_release) } }
        }
    }

    if InputPressed(INPUT_LEFT) or InputPressed(INPUT_RIGHT) or InputPressed(INPUT_UP) or InputPressed(INPUT_DOWN) {
        cs_kbd = true
    }
}

// ── Keyboard nav for PostGame ─────────────────────────────────────────────────
if room == PostGame {
    if mouse_x != _cs_prev_mx or mouse_y != _cs_prev_my { cs_kbd = false }
    _cs_prev_mx = mouse_x
    _cs_prev_my = mouse_y
    global.using_kbd = cs_kbd

    var _btn = instance_find(objNewrun, 0)
    if instance_exists(_btn) {
        _btn.keyboard_hover = cs_kbd
        if cs_kbd { global.kbd_tooltip = "New Run" }
    }

    if InputPressed(INPUT_CONFIRM) and cs_kbd and instance_exists(_btn) {
        with (_btn) { event_perform(ev_mouse, ev_left_release) }
    }
    if InputPressed(INPUT_LEFT) or InputPressed(INPUT_RIGHT) or InputPressed(INPUT_UP) or InputPressed(INPUT_DOWN) or InputPressed(INPUT_CONFIRM) {
        cs_kbd = true
    }
}

// Open log viewer via keyboard shortcut or corner button click
var _log_btn_x = display_get_gui_width() - 8
var _log_btn_y = 726 - 24
var _log_click = mouse_check_button_pressed(mb_left)
    and device_mouse_x_to_gui(0) > _log_btn_x - 48
    and device_mouse_y_to_gui(0) > _log_btn_y - 8
    and device_mouse_y_to_gui(0) < _log_btn_y + 24

if InputPressed(INPUT_SAVE) { Autosave() }

var _log_open = instance_number(objLogViewer) > 0
if (InputPressed(INPUT_LOG) or _log_click) and !_log_open and room != CharacterSelect {
    PushMenu(objLogViewer, {})
}else if InputPressed(INPUT_LOG) and _log_open{PopMenu()}