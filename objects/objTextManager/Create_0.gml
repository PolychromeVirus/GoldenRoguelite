#macro TARGETHEIGHT 31

// Top HUD portrait layout constants
#macro HUD_PORTRAIT_FULL   144
#macro HUD_PORTRAIT_SCALE  0.79
#macro HUD_PORTRAIT_SIZE   round(HUD_PORTRAIT_FULL * HUD_PORTRAIT_SCALE)
#macro HUD_PORTRAIT_OFFSET ((HUD_PORTRAIT_FULL - HUD_PORTRAIT_SIZE) / 2)
#macro HUD_PORTRAIT_GAP    2
#macro HUD_MARGIN          3
#macro HUD_END_MARGIN      15
#macro HUD_TOP_Y           3

depth = 1
save_flash = 0  // counts down from 180 (3 seconds) when Autosave fires

// Keyboard nav state for static screens (CharacterSelect, PostGame)
cs_row      = 0   // 0 = char row, 1 = action row
cs_sel      = 0   // index within row
cs_kbd      = false
_cs_prev_mx = 0
_cs_prev_my = 0
_cs_last_room = -1