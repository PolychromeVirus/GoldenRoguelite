// Multi-kill targeting (Charon): pick one target at a time
monsters = []
var count = instance_number(objMonster)
for (var i = 0; i < count; i++) {
	var inst = instance_find(objMonster, i)
	if inst.monsterHealth > 0 and !inst.boss {
		array_push(monsters, inst)
	}
}

// If no valid (non-boss) targets, cancel automatically
if array_length(monsters) == 0 {
	InjectLog("No monsters for Charon to target!")
	global.pause = false
	instance_destroy()
	instance_create_depth(0, 0, 0, TurnDelay, {wait: 30})
	exit
}

selected = 0
killed = []

instance_create_depth(36, 124, 0, objConfirm)
instance_create_depth(92, 124, 0, objCancel)

alarm_set(0, 1)
