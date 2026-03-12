/// @function _BuildRandomPuzzleChallenge(_puzzle_pool)
/// @desc Builds one random puzzle challenge plus any floor effects it should add.
/// @param {Array} _puzzle_pool Array of puzzle indices to choose from. Pass `undefined` or `[]` to use all puzzles.
/// @return {Struct} {
///     success: bool,
///     challenge: struct,
///     effects: array,
///     puzzle_index: real
/// }
function _BuildRandomPuzzleChallenge(_puzzle_pool = []) {
    var _pool = [];

    if (is_array(_puzzle_pool) && array_length(_puzzle_pool) > 0) {
        _pool = _puzzle_pool;
    } else {
        for (var _i = 0; _i < array_length(global.puzzlelist); _i++) {
            array_push(_pool, _i);
        }
    }

    if (array_length(_pool) <= 0) {
        return {
            success: false,
            challenge: undefined,
            effects: [],
            puzzle_index: -1
        };
    }

    var _pi = _pool[irandom(array_length(_pool) - 1)];
    var _puzzle = global.puzzlelist[_pi];

    var _challenge = {
        type: "puzzle",
        troop: [],
        completed: false,
        unique: false,
        override_name: "",
        puzzle_index: _pi
    };

    var _effects = [];
    if (_puzzle.trap) {
        array_push(_effects, {
            name: _puzzle.name,
            puzzle_index: _pi
        });
    }

    return {
        success: true,
        challenge: _challenge,
        effects: _effects,
        puzzle_index: _pi
    };
}
