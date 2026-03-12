selected = 0

DeleteButtons()
ClearOptions()

var sprite = {image: yes, text: "Enter"}
instance_create_depth(BUTTON1, BOTTOMROW, 0, objConfirm, sprite)
instance_create_depth(BUTTON2, BOTTOMROW, 0, objCancel)
instance_create_depth(sprite_width,0,0,objHalfMenu)