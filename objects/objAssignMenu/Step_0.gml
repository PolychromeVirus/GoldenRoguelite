if selected > array_length(dice)-1{
	selected = array_length(dice)-1
}
if selected < 0{
	selected = 0
}

if array_length(dice) < 1{instance_destroy(objQuarterMenu)}else{

	if instance_number(objQuarterMenu) < 1{
		instance_create_depth(sprite_width,sprite_height/2,0,objQuarterMenu)
	}

}

if InputPressed(INPUT_UP) {
    if selected == 0 { selected = array_length(dice) - 1 }
    else { selected -= 1 }
}
if InputPressed(INPUT_DOWN) {
    if selected == array_length(dice) - 1 { selected = 0 }
    else { selected += 1 }
}