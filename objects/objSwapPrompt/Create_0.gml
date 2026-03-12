// Struct properties passed in: new_item, old_item, armor_index, inv_slot
// Tear down the item menu and its buttons
instance_destroy(objItemMenu)
ClearOptions()
DeleteButtons()

// Spawn confirm/cancel buttons for the swap prompt
var _confirmSprite = {image: yes, text:"Swap"}
instance_create_depth(BUTTON3, BOTTOMROW, 0, objConfirm, _confirmSprite)
instance_create_depth(BUTTON5, BOTTOMROW, 0, objCancel)