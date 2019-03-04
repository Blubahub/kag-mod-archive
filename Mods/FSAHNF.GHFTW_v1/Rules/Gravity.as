
void onInit(CRules @this){

	this.set_f32("gravity",this.get_u8("blob")/32);
	//wait... you... I remember you... IN THE MOUNTAINS...
}

void onBlobCreated( CRules@ this, CBlob@ blob ) {

	if(blob !is null)
	if(blob.getShape() !is null)
	if(!blob.getShape().isStatic())blob.AddScript("GravityController.as");

}

void onRestart(CRules@ this){
	this.set_f32("gravity",this.get_u8("blob")/32);
	if(getNet().isServer())this.Sync("gravity",true);
}

void onNewPlayerJoin( CRules@ this, CPlayer@ player ){
	if(getNet().isServer())this.Sync("gravity",true);
}