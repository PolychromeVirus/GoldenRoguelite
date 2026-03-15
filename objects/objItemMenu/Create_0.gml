mode = 0 // 0 = inventory, 1 = equipment
btn_selected = 0
bottom_buttons = []
lastmode = -1
others = []
otherslast = []

DeleteButtons()

instance_create_depth(sprite_width,sprite_height/2,0,objQuarterMenu)

clickable = false
alarm_set(0,1)