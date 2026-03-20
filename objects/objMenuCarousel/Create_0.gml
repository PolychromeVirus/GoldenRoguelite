// Apply config defaults for any fields not provided
if !variable_instance_exists(id, "items")         { items         = [] }
if !variable_instance_exists(id, "on_confirm")    { on_confirm    = function(i, item) {} }
if !variable_instance_exists(id, "on_cancel")     { on_cancel     = function() {} }
if !variable_instance_exists(id, "description")   { description   = "none" }
if !variable_instance_exists(id, "title")         { title         = "" }
if !variable_instance_exists(id, "filter")        { filter        = undefined }
if !variable_instance_exists(id, "on_info")       { on_info       = undefined }
if !variable_instance_exists(id, "confirm_label")  { confirm_label  = "Select" }
if !variable_instance_exists(id, "confirm_sprite") { confirm_sprite = yes }
if !variable_instance_exists(id, "read_only")     { read_only     = false }
if !variable_instance_exists(id, "no_cancel")     { no_cancel     = false }
if !variable_instance_exists(id, "side")          { side          = "left" }
if !variable_instance_exists(id, "draw_pane")     { draw_pane     = undefined }
if !variable_instance_exists(id, "info_label")    { info_label    = "Info" }

selected  = 0
using_kbd = false
_prev_mx  = device_mouse_x_to_gui(0)
_prev_my  = device_mouse_y_to_gui(0)
pane      = noone

// Spawn description pane
var _half_w = sprite_get_width(HalfMenu)
var _half_h = sprite_get_height(HalfMenu)
var _pane_x = (side == "left") ? _half_w : 0

if description == "half" {
    pane = instance_create_depth(_pane_x, 0, 0, objHalfMenu)
}
// "quarter" pane drawn directly in Draw_64 — no room-space instance needed

_build_buttons = method(id, function() {
    if !read_only {
        var _confirm_spr = { image: confirm_sprite, hovertext: confirm_label }
        instance_create_depth(BUTTON1, BOTTOMROW, 0, objConfirm, _confirm_spr)
    }
    if !no_cancel { instance_create_depth(BUTTON2, BOTTOMROW, 0, objCancel) }
    if !is_undefined(on_info) {
        var _info_spr = { image: Save_Game, hovertext: info_label }
        instance_create_depth(BUTTONRIGHT2, BOTTOMROW, 0, objButton2, _info_spr)
    }
    clickable = true
})

clickable = false
