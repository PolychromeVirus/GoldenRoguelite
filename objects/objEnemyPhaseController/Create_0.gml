// Receives: mon_list (array of monster IDs), on_complete (callback)
mon_index = 0
phase = 0       // 0 = announce, 1 = apply damage
pending_data = undefined
DeleteButtons()
alarm[0] = 15
