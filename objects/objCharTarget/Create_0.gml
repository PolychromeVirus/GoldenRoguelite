// Grid origin derived from object position (room coords * 6 = GUI coords)
gridX = x * 6 + 48
gridY = y * 6 + 48
cellW = 500
cellH = 200
cellStrideY = 250  // vertical spacing between row origins (cellH + padding)
portraitSize = 128
barW = 200
barH = 14
itemSize = 32

if instance_number(objCancel) > 0 {
	instance_destroy(objCancel)
}
if instance_number(objConfirm) > 0 {
	instance_destroy(objConfirm)
}

kbd_selected = 0
use_kbd_selected = false
using_kbd = false
_prev_mx = device_mouse_x_to_gui(0)
_prev_my = device_mouse_y_to_gui(0)

// No objConfirm — click-to-confirm on portraits
instance_create_depth(BUTTON5, BOTTOMROW, 0, objCancel)
