
if instance_exists(objTownShop){
	instance_destroy(objTownShop)
	CreateOptions()
}else{
	DeleteButtons()
	ClearOptions()
	instance_create_depth(0,0,0,objTownShop)
}