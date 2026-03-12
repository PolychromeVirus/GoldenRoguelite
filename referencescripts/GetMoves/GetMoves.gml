function GetMoves(ID){
	var moveArray = []
	for (var i=1; i<ds_grid_height(global.moveIDs); i+=1){
		if global.moveIDs[# 0,i] == global.enemyIDs[# 0, ID]{
			for (var j=0; j<global.moveIDs[# 2,i]; j+=1){
				array_push(moveArray,i)
			}
		}
	}
	return moveArray
}