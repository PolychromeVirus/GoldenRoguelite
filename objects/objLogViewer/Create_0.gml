scroll_offset  = 0   // 0 = bottom (newest), positive = scrolled up
_line_h        = 40
_visible_lines = 14
_pad_x         = 50
_pad_y         = 80

_build_buttons = method(id, function() {
    instance_create_depth(BUTTON1, BOTTOMROW, 0, objCancel, { hovertext: "Close Log" })
    clickable = true
})
clickable = false
alarm_set(0, 1)
