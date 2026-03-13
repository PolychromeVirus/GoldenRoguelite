if global.inCombat{
			if array_length(global.attackQueue) > 0 {
				ProcessAttackQueue()
				instance_destroy()
				
			}else{
				
				instance_create_depth(0, 0, 0, TurnDelay, {wait: 30})
				instance_destroy()
				
			}

		}else{
			DeleteButtons()
			alarm_set(2,60)
			
		}
	