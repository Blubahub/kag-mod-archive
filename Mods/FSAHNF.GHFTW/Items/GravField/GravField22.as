
void onInit(CBlob@ this)
{

	this.getSprite().SetZ(-100);
	
	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.SetGravityScale(0.0);
	
	this.getSprite().setRenderStyle(RenderStyle::light);
	
	this.Tag("gravity_field");
	this.set_u16("field_size",88);
	
	if(getNet().isServer())this.server_SetTimeToDie(60);
}
