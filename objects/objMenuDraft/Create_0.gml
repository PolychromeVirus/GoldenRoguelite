if !variable_instance_exists(id, "items")      { items      = [] }
if !variable_instance_exists(id, "on_confirm") { on_confirm = function(i, item) {} }
if !variable_instance_exists(id, "on_cancel")  { on_cancel  = function() { PopMenu() } }
if !variable_instance_exists(id, "title")      { title      = "" }
if !variable_instance_exists(id, "filter")     { filter     = undefined }
if !variable_instance_exists(id, "draw_item")  { draw_item  = undefined }
if !variable_instance_exists(id, "box_height") { box_height = 550 }
if !variable_instance_exists(id, "no_cancel")  { no_cancel  = false }

selected  = 0
using_kbd = false
_prev_mx  = device_mouse_x_to_gui(0)
_prev_my  = device_mouse_y_to_gui(0)

_build_buttons = method(id, function() {
    var _confirm_spr = { image: yes, text: "Select" }
    instance_create_depth(BUTTON1, BOTTOMROW, 0, objConfirm, _confirm_spr)
    if !no_cancel {
        instance_create_depth(BUTTON2, BOTTOMROW, 0, objCancel)
    }
    clickable = true
})

clickable = false
