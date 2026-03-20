/// @func BuildDiceArray(player, subset)
/// @desc Flatten a player's dice pool into an array of {pip, col, pool, index} structs.
/// subset: "all" | "elemental" | "melee" | "venus" | "mars" | "jupiter" | "mercury"
function BuildDiceArray(player, subset) {
    var _pool_colors = [0x303030, 0x5fe4ff, 0x8585ff, 0xffabe7, 0xffc9a6]  // melee, venus, mars, jupiter, mercury (GML BGR)
    var _pools
    switch subset {
        case "venus":     _pools = [POOL_VENUS]; break
        case "mars":      _pools = [POOL_MARS]; break
        case "jupiter":   _pools = [POOL_JUPITER]; break
        case "mercury":   _pools = [POOL_MERCURY]; break
        case "melee":     _pools = [POOL_MELEE]; break
        case "elemental": _pools = [POOL_VENUS, POOL_MARS, POOL_JUPITER, POOL_MERCURY]; break
        default:          _pools = [POOL_MELEE, POOL_VENUS, POOL_MARS, POOL_JUPITER, POOL_MERCURY]; break
    }
    var _result = []
    for (var _pi = 0; _pi < array_length(_pools); _pi++) {
        var _p   = _pools[_pi]
        var _arr = player.dicepool[_p]
        for (var _i = 0; _i < array_length(_arr); _i++) {
            array_push(_result, {
                pip:   _arr[_i],
                col:   _pool_colors[_p],
                pool:  _p,
                index: _i,
            })
        }
    }
    return _result
}
