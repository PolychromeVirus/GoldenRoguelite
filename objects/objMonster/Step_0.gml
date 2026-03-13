if timerstart{alarm_set(1,240);timerstart=false}

if monsterHealth < 0{monsterHealth = 0}

if monsterHealth <= 0 and !dying and sprite_index != curse755 and sprite_index != DEAD{
	dying = true
	death_timer = DEATH_PRE_DELAY + DEATH_FADE_FRAMES + DEATH_SHRINK_FRAMES + DEATH_POST_DELAY
	death_frame = image_index
	image_speed = 0
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