if instance_exists(objStatDisplay) { objStatDisplay.viewPlayer = global.turn }

if instance_exists(objItemMenu) {
	PopMenu()
} else {
	PushMenu(objItemMenu, {})
}