
void onInit(CBlob @this){
	this.Tag("hard_liquid_blob");
}

void onTick(CBlob @this){

	if(this.hasTag("heated"))
	if(!this.hasTag("melted")){
		this.Tag("melted");
		if(getNet().isServer()){
			server_CreateBlob("molten_metal",-1,this.getPosition());
			this.server_Die();
		}
	}

}