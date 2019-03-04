
void onInit(CBlob@ this)
{	
	f32 lifetimer = 0.0f;
	this.SetLight(true);
	this.getSprite().setRenderStyle(RenderStyle::light);
	this.SetLightRadius(128.0f);
	this.SetLightColor(SColor(255, 255, 0, 0));
	this.Tag("dont deactivate");
	this.Tag("fire source");
	CShape@ shape = this.getShape();
	shape.SetStatic(true);
	CSprite@ sprite = this.getSprite();
	if(sprite is null) return;

	//sprite.SetFacingLeft(false);
	sprite.SetZ(750);
	//this.getCurrentScript().tickFrequency = 24;

	this.set_u32("lifetime", 0);
	//this.server_SetTimeToDie(3);

}

void onTick(CBlob@ this)
{	
	u32 lifetime = this.get_u32("lifetime");
	lifetime = (lifetime + 1);
	//print("" + lifetime);
	this.SetLightRadius(lifetime*3);
	Vec2f xpos = Vec2f(this.getPosition().x, 0);
	this.SetLightRadius(96.0f);
	if(lifetime > 70)
	{	
		CBlob@ blob = server_CreateBlob("keg", this.getTeamNum(), xpos);
		if (blob !is null)
		{		

			blob.setVelocity(Vec2f(0, 15));
			blob.SendCommand(blob.getCommandID("activate"));
			blob.SetDamageOwnerPlayer(this.getPlayer());
			this.server_Die();
		}
		this.server_Die(); 
	}
	this.set_u32("lifetime", lifetime);

	this.setAngleDegrees(this.getAngleDegrees()+4.0f);

}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{/*
	if (this !is null && blob !is null)
	{
		CMap@ map = getMap();
		CBlob@[] blobsInRadius;
		if (map.getBlobsInRadius(this.getPosition(), 560.0f, @blobsInRadius ))
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob @b = blobsInRadius[i];
				if (blob.get_u8("teleported") != this.getTeamNum() && b !is null && b.getName() == "portal" && this.getTeamNum() != b.getTeamNum())
				{
					blob.setPosition(b.getPosition());
					//this.server_Die();
					blob.set_u8("teleported", b.getTeamNum());
				}
			}
		}
	}*/
}