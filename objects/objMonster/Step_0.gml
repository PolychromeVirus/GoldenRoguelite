if timerstart{alarm_set(1,240);timerstart=false}

if monsterHealth < 0{monsterHealth = 0}

if monsterHealth <= 0 and sprite_index != curse755{
	sprite_index = DEAD
	poison = false
	venom = false
	stun = 0
	sleep = false
	delude = false
	psyseal = false
	atkmod = 0
	defmod = 0
	lose_turn = false
}