selected = 0
draftPool = global.draftPool
draftPlayer = global.draftPlayerIndex

instance_create_depth(sprite_width, 0, 0, objHalfMenu)

ClearOptions()

var sprite = { image: yes, text: "Select" }
instance_create_depth(BUTTON1, BOTTOMROW, 0, objConfirm, sprite)
