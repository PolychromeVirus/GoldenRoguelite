instance_destroy(objHalfMenu)
ClearOptions()
if room != CharacterSelect {
    CreateOptions()
} else {
    with (objCharSelect) { visible = true }
    with (objBegin)      { visible = true }
    with (objLoadGame)   { visible = true }
    with (objLibrary)    { visible = true }
}