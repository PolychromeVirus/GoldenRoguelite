/// @function WrapText(text, max_width)
/// @desc Splits text into an array of strings that each fit within max_width
///       pixels using the currently set font. Call draw_set_font first.
function WrapText(text, max_width) {
	var _words   = string_split(text, " ")
	var _lines   = []
	var _current = ""
	for (var _i = 0; _i < array_length(_words); _i++) {
		var _word = _words[_i]
		var _test = (_current == "") ? _word : (_current + " " + _word)
		if string_width(_test) > max_width and _current != "" {
			array_push(_lines, _current)
			_current = _word
		} else {
			_current = _test
		}
	}
	if _current != "" { array_push(_lines, _current) }
	return _lines
}
