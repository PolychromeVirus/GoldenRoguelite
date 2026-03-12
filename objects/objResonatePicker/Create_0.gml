/// @desc Pick Range or Damage for Resonate passive
DeleteButtons()

btn_range = instance_create_depth(BUTTON3, BOTTOMROW, 0, objButton2, { image: Resonate, text: "Range" })
btn_damage = instance_create_depth(BUTTON5, BOTTOMROW, 0, objButton3, { image: Resonate, text: "Damage" })
