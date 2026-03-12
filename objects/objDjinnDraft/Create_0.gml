djinnPool = global.djinnDraftPool
selected = 0
phase = 0       // 0 = pick djinni, 1 = pick adept
chosenDjinn = -1

instance_create_depth(sprite_width, 0, 0, objHalfMenu)
ClearOptions()

var sprite = { image: yes, text: "Select" }
instance_create_depth(36, 124, 0, objConfirm, sprite)
instance_create_depth(92, 124, 0, objCancel)
