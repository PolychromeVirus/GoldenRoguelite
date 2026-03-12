/// @desc Takes input and returns a real number, if input is a string, returns 0
/// @param {string} num number to convert to real
function GetReal(in){
	if in == ""{return 0}
	if is_numeric(in){return real(in)}
	return 0
}