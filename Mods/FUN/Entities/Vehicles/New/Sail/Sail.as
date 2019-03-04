void onInit(CBlob@ this )
{
	this.addCommandID("sail");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
    params.write_u16(caller.getNetworkID());
	
	if (!this.hasTag("up"))
		caller.CreateGenericButton( 12, Vec2f(0,0), this, this.getCommandID("sail"), "Activate the Sail" , params );
	else caller.CreateGenericButton( 12, Vec2f(0,0), this, this.getCommandID("sail"), "Deactivate the Sail" , params );
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	CSprite@ sprite = this.getSprite();
	if (cmd == this.getCommandID("sail"))
	{
		if (!this.hasTag("up")) 
		{
			sprite.SetAnimation("sailup");
			sprite.SetAnimation("sail");
			this.Tag("up");
		}
		else 
		{
			sprite.SetAnimation("saildown");
			this.Untag("up");
		}
	}
}