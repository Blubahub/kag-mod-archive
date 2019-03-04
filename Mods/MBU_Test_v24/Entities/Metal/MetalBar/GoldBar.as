
void onInit(CBlob @this){
	this.Tag("hard_liquid_blob");
}

void onTick(CBlob @this){

	if(this.hasTag("heated"))
	if(!this.hasTag("melted")){
		this.Tag("melted");
		if(getNet().isServer()){
			CBlob @blob = server_CreateBlob("molten_gold",-1,this.getPosition());
			if(this.hasTag("light_infused"))blob.Tag("light_infused");
			this.server_Die();
		}
	}

}