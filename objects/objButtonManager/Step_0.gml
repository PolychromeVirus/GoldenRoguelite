var _top = (array_length(global.menu_stack) > 0)
         ? global.menu_stack[array_length(global.menu_stack) - 1]
         : noone

// Check if any monster is mid-death animation
var _any_dying = false
var _mc = instance_number(objMonster)
for (var _m = 0; _m < _mc; _m++) {
    var _mon = instance_find(objMonster, _m)
    if _mon.dying and _mon.death_timer > 0 { _any_dying = true; break }
}
var _blocked = _any_dying or instance_exists(TurnDelay) or instance_exists(objAnimOrchestrator) or instance_exists(objSpellAnimation) or instance_exists(objEnemyPhaseController) or instance_exists(objPostBattle)

if _top != _prev_top{
    _prev_top = _top
    DeleteButtons()
    if global.turnPhase == "player" or MenuExists() {
        if !_blocked{
            alarm[0] = 1
        }
    }
}else if !instance_exists(objAttack) and !instance_exists(objButton2) and !instance_exists(objConfirm) and !instance_exists(objChallenge) and !instance_exists(objCancel){
	 if instance_number(objMonsterTarget) == 0 and instance_number(objCharMenu) == 0 and !_blocked{
            alarm[0] = 1
        }
}
if global.inCombat != _prev_combat{

	_prev_combat = global.inCombat
	DeleteButtons()
	alarm[0] = 1

}

if _blocked and !_delay_exists{

	_delay_exists = true
	DeleteButtons()

}
if _delay_exists and !_blocked{

	_delay_exists = false
	DeleteButtons()
	alarm[0] = 1

}