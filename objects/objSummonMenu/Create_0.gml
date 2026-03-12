instance_create_depth(sprite_width,sprite_height/2,0,objQuarterMenu)

DeleteButtons()

instance_create_depth(BUTTON2,BOTTOMROW,0,objCancel)

var sprite = {image: yes,text:"Summon"}
instance_create_depth(BUTTON1,BOTTOMROW,0,objConfirm,sprite)
