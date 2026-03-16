if !variable_instance_exists(id, "on_confirm")  { on_confirm  = function(i) {} }
if !variable_instance_exists(id, "on_cancel")   { on_cancel   = function() { PopMenu() } }
if !variable_instance_exists(id, "filter")      { filter      = undefined }
if !variable_instance_exists(id, "draw_header") { draw_header = undefined }
if !variable_instance_exists(id, "read_only")   { read_only   = false }
if !variable_instance_exists(id, "corner")      { corner      = "bottomleft" }

// Derive sprite origin from corner
// ThreeQuarterMenu at 6x = 1062 x 534; portrait bar top in GUI = objPortrait.y * 6 = 720
var _spr_w = sprite_get_width(ThreeQuarterMenu)   * 6  // 1062
var _spr_h = sprite_get_height(ThreeQuarterMenu)  * 6  // 534
var _gui_w = 1536
var _btn_y = objPortrait.y * 6  // 720 — flush with top of portrait bar
switch corner {
    case "topleft":     spr_x = 0;              spr_y = 0;              break
    case "topright":    spr_x = _gui_w - _spr_w; spr_y = 0;              break
    case "bottomleft":  spr_x = 0;              spr_y = _btn_y - _spr_h; break
    case "bottomright": spr_x = _gui_w - _spr_w; spr_y = _btn_y - _spr_h; break
    default:            spr_x = 0;              spr_y = 0;              break
}

if !variable_instance_exists(id, "gridX") { gridX = spr_x + 50 }
if !variable_instance_exists(id, "gridY") { gridY = spr_y + 60 }

cellW       = 500
cellH       = 200
cellStrideY = 250

kbd_selected    = 0
using_kbd       = false
_prev_mx        = device_mouse_x_to_gui(0)
_prev_my        = device_mouse_y_to_gui(0)

_build_buttons = method(id, function() {
    if read_only { exit }
    instance_create_depth(BUTTON5, BOTTOMROW, 0, objCancel)
    clickable = true
})

clickable = false
