void onInit(CRules @ this){
	particles_gravity = Vec2f(0,0);
}

void onBlobCreated( CRules@ this, CBlob@ blob ) {

	if(blob !is null)
	if(blob.getShape() !is null)
	if(!blob.getShape().isStatic())blob.AddScript("GravityController.as");

}