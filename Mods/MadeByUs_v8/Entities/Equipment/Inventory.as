void onInit(CBlob @this){

	this.Tag("inventory");

}

void onRemoveFromInventory( CBlob@ this, CBlob@ blob ){
	
	if(!getNet().isServer())return;
	
	if(blob !is null){
		if(this.isInInventory()){
			CBlob @owner = this.getInventoryBlob();
			if(owner !is null){
				if(owner.getCarriedBlob() is null){
					if(blob.canBePickedUp(owner))owner.server_Pickup(blob);
				} else {
					CBlob @carried = owner.getCarriedBlob();
					if(blob.canBePickedUp(owner)){
						owner.server_PutInInventory(carried);
						owner.server_Pickup(blob);
					}
				}
			}
		}
	}
}