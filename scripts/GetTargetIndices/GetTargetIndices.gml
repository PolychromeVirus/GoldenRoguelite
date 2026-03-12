/// @function GetTargetIndices(selected, num, total)
/// @desc Returns an array of indices centered on selected, expanding outward, capped at total.
///       For num >= total, returns all indices.
function GetTargetIndices(selected, num, total) {
	// Target all
	if num >= total {
		var _all = []
		for (var _i = 0; _i < total; _i++) { array_push(_all, _i) }
		return _all
	}

	var _targets = [selected]
	var _left = selected - 1
	var _right = selected + 1

	// Alternate right then left outward from selected
	while (array_length(_targets) < num) {
		if _right < total {
			array_push(_targets, _right)
			_right++
		}
		if array_length(_targets) >= num { break }
		if _left >= 0 {
			array_push(_targets, _left)
			_left--
		}
		// If both exhausted, stop
		if _right >= total and _left < 0 { break }
	}

	return _targets
}
