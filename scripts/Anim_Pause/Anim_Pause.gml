function Anim_Pause(){
	
    var _step  = _queue[_qi]
    var _TOTAL = _step[$ "hold"] ?? 20
    _check_hit()

    if _timer >= _TOTAL {
        while _qi < array_length(_queue) - 1 and _queue[_qi + 1].type == "pause" {
            _qi++
        }
        _next_step()
    }

}