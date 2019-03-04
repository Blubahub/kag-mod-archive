
void onInit(CBlob @this){
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint ){
	if(attached !is null){
		if(attached.getName() == "humanoid"){
			attached.Tag("death_knowledge");
		}
	}
}