#macro TARGETHEIGHT 31

depth = 1

// Keyboard nav state for static screens (CharacterSelect, PostGame)
cs_row      = 0   // 0 = char row, 1 = action row
cs_sel      = 0   // index within row
cs_kbd      = false
_cs_prev_mx = 0
_cs_prev_my = 0
_cs_last_room = -1