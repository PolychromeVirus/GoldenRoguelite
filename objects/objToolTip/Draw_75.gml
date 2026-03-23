var _scale = 6
var drawx  = 0
var drawy  = 120 * _scale+6

draw_set_font(GoldenSunItalic)
draw_set_valign(fa_bottom)
var target = instance_position(mouse_x, mouse_y, all)
var _text  = ""
if global.kbd_tooltip != "" and global.textdisplay == "" {
    _text = global.kbd_tooltip
} else if global.textdisplay == "" {
    if variable_instance_exists(target, "hovertext") and target.hovertext != "" {
        _text = target.hovertext
    }
} else {
    _text = global.textdisplay
	alarm_set(0,60)
}

if _text != "" {
    draw_rectangle_color(drawx, drawy-6, display_get_gui_width(), drawy-(string_height(_text)*6),
        c_black, c_black, c_black, c_black, false)
    draw_set_color(c_white)
    draw_text_transformed(drawx, drawy, _text, _scale, _scale, 0)
}

draw_set_valign(fa_top)
