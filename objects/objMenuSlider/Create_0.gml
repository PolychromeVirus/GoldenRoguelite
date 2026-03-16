if !variable_instance_exists(id, "minim")       { minim       = 1 }
if !variable_instance_exists(id, "maxim")       { maxim       = 10 }
if !variable_instance_exists(id, "value")       { value       = minim }
if !variable_instance_exists(id, "on_confirm")  { on_confirm  = function(v) {} }
if !variable_instance_exists(id, "on_cancel")   { on_cancel   = function() { PopMenu() } }
if !variable_instance_exists(id, "label")       { label       = function(v) { return string(v) } }
if !variable_instance_exists(id, "preview")     { preview     = undefined }
if !variable_instance_exists(id, "confirm_label") { confirm_label = "Confirm" }

value = clamp(value, minim, maxim)

_build_buttons = method(id, function() {
    instance_create_depth(BUTTON3, BOTTOMROW, 0, objConfirm, { image: yes, text: confirm_label })
    instance_create_depth(BUTTON5, BOTTOMROW, 0, objCancel)
    clickable = true
})

clickable = false
