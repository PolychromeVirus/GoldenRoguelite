summonPool = global.summonDraftPool
selected = 0

instance_create_depth(sprite_width, 0, 0, objHalfMenu)
ClearOptions()

var sprite = { image: Summon, text: "Select" }
instance_create_depth(36, 124, 0, objConfirm, sprite)
instance_create_depth(92, 124, 0, objCancel)
