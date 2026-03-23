sprite_index = alias
alarm_set(0,240)
half = 8

hpx = x-half
hpx2 = x+half
flash_timer = 0
frozen = 0        // >0 = frozen overlay active (managed by animation system)
flash_color = c_white
tint_timer = 0
tint_color = c_red
damage_timer = 0
drawdam = false
damvis = 0
timerstart = false
dying = false
death_timer = -1