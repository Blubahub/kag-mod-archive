
void onInit(CBlob @ this)
{
	this.addCommandID("place_item");

	if(getNet().isServer())this.server_setTeamNum(-1);
	
	this.getShape().SetRotationsAllowed(false);
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(caller.getCarriedBlob() !is this){
		CBitStream params;
		params.write_u16(caller.getNetworkID());

		if(this.isAttachedToPoint("SMITH")){
			if(caller.getCarriedBlob() is null)caller.CreateGenericButton(16, Vec2f(0,0), this, this.getCommandID("place_item"), "Remove Item", params);
		} else {
			if(caller.getCarriedBlob() !is null)caller.CreateGenericButton(19, Vec2f(0,0), this, this.getCommandID("place_item"), "Place Item", params);
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("place_item"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			if(getNet().isServer()){
				
				if(this.isAttachedToPoint("SMITH")){
					CAttachment@ attach = this.getAttachments();
					if(attach.getAttachedBlob("SMITH") !is null){
						CBlob @attachedBlob = attach.getAttachedBlob("SMITH");
						if(getNet().isServer()){
							this.server_DetachFrom(attachedBlob);
						}
					}
				} else {
				
					CBlob@ hold = caller.getCarriedBlob();
					if(hold !is null)if(hold.getRadius() < this.getRadius()){
						caller.DropCarried();
						if(getNet().isServer()){
							this.server_AttachTo(hold, "SMITH");
						}
					}
				}
			}
		}
	}
}

void onInit(CSprite @this){
	this.SetZ(-10.0f);
	
	this.RemoveSpriteLayer("front");
	CSpriteLayer@ front = this.addSpriteLayer("front", "LogCage.png" , 13, 17, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (front !is null)
	{
		Animation@ anim = front.addAnimation("default", 0, false);
		anim.AddFrame(0);
		front.SetRelativeZ(10.0f);
		front.SetOffset(Vec2f(0,3));
	}
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(getNet().isServer()){
		if(!this.isAttached() && !this.hasAttached())
		if(Maths::Abs(this.getVelocity().x) > 0.5f || Maths::Abs(this.getVelocity().y) > 0.5f)
		if(blob !is null)
		if(blob.getName() == "w" || blob.getName() == "chicken" || blob.getName() == "fishy"){
			this.server_AttachTo(blob, "SMITH");
		}
	}
}