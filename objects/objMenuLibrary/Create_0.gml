if !variable_instance_exists(id, "entries")     { entries     = [] }
if !variable_instance_exists(id, "start_index") { start_index = 0 }
if !variable_instance_exists(id, "on_cancel")   { on_cancel   = function() {  } }
if !variable_instance_exists(id, "draw_entry")  { draw_entry  = function(entry, i) {
    draw_set_color(c_white)
    draw_text_ext(50, 120, variable_struct_exists(entry, "text") ? entry.text : "", 50, 1400)
} }

index = clamp(start_index, 0, max(0, array_length(entries) - 1))

_build_buttons = method(id, function() {
    instance_create_depth(BUTTON1, BOTTOMROW, 0, objCancel, { hovertext: "Back" })
    clickable = true
})
clickable = false
