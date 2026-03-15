if InputPressed(INPUT_LEFT) {
    if indicator > 0 { indicator -= 1 }
    else { indicator = array_length(global.psynergylist) - 1 }
}
if InputPressed(INPUT_RIGHT) {
    if indicator < array_length(global.psynergylist) - 1 { indicator += 1 }
    else { indicator = 0 }
}
