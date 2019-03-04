
void onTick(CBlob @this){
	if(this.hasTag("light_infused")){
		this.getShape().SetGravityScale(0.0f);
		if(this.getInventoryName().find("loating") <= 0)this.setInventoryName("Floating "+this.getInventoryName());
	}
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint ){
	if(attached !is null){
		if(attached.getName() == "humanoid" && this.hasTag("light_infused")){
			attached.Tag("light_knowledge");
		}
	}
}