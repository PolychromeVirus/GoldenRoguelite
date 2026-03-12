var _inDraft = instance_exists(objPsynergyDraft) or instance_exists(objDjinnDraft) or instance_exists(objSummonDraft)

if _inDraft {
	if instance_exists(objStatDisplay) {
		instance_destroy(objStatDisplay)
		with (objConfirm) { visible = true }
		with (objCancel) { visible = true }
		with (objHalfMenu) { visible = true }
	} else {
		instance_create_depth(0,0,0,objStatDisplay)
		with (objConfirm) { visible = false }
		with (objCancel) { visible = false }
		with (objHalfMenu) { visible = false }
	}
	exit
}

DestroyAllBut(objStatDisplay)

if instance_number(objStatDisplay) > 0{
	instance_destroy(objStatDisplay)
	CreateOptions()
}else{
	DeleteButtons()
	instance_create_depth(0,0,0,objStatDisplay)
}