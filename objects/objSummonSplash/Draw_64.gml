var _fade_start = life_total * 0.4
if life < _fade_start {
    alpha = life / _fade_start
}
life--
if life <= 0 { instance_destroy() }
