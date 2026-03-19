var _top = (array_length(global.menu_stack) > 0)
         ? global.menu_stack[array_length(global.menu_stack) - 1]
         : noone

if _top != _prev_top{
    _prev_top = _top
    DeleteButtons()
    if global.turnPhase == "player" or MenuExists() {
        if instance_number(objMonsterTarget) == 0 and instance_number(objCharMenu) == 0 and instance_number(TurnDelay) == 0{
            alarm[0] = 1
        }
    }
}else if !instance_exists(objAttack) or !instance_exists(objButton2) or !instance_exists(objConfirm){
	 if instance_number(objMonsterTarget) == 0 and instance_number(objCharMenu) == 0 and instance_number(TurnDelay) == 0{
            alarm[0] = 1
        }
}
