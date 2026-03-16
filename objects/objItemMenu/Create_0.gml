mode = 0 // 0 = inventory, 1 = equipment
btn_selected = 0
bottom_buttons = []
lastmode = -1
others = []
otherslast = []

DeleteButtons()

clickable = false
alarm_set(0,1)

_build_buttons = method(id, function() {
    lastmode = -1  // force Step_0 to rebuild buttons next step
})