if global.inCombat{
			if array_length(global.attackQueue) > 0 {
				ProcessAttackQueue()
				instance_destroy()
				
			}else{
				
				NextTurn()
				instance_destroy()
				
			}

		}else{
			DeleteButtons()
			alarm_set(2,60)
			
		}
	