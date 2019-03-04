
void onInit(CBlob @this){
	this.Tag("metaldrop");
	this.Tag("hard_liquid_blob");
}

void onTick(CBlob @this){

	if(this.hasTag("heated"))
	if(!this.hasTag("melted")){
		this.Tag("melted");
		if(getNet().isServer()){
			if(this.getName() == "metal_drop")server_CreateBlob("molten_metal",-1,this.getPosition());
			if(this.getName() == "metal_drop_dirty")server_CreateBlob("molten_metal_dirty",-1,this.getPosition());
			if(this.getName() == "gold_drop")server_CreateBlob("molten_gold",-1,this.getPosition());
			this.server_Die();
		}
	}

}