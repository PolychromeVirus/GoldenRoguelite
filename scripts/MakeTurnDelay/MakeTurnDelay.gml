function MakeTurnDelay(_t,_c = undefined){
	
	if _c != undefined{
		instance_create_depth(0,0,0,TurnDelay,{wait: _t, on_complete: _c})
	}else{
		instance_create_depth(0,0,0,TurnDelay,{wait: _t})
	
	}
}