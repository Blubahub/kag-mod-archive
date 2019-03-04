// Detonator script
void onInit(CBlob@ this)
{
	this.Tag("no falldamage");
	this.Tag("heavy weight");
	this.set_u32("heals", 20);
}

/*void onTick(CBlob@ this)
{
	if (this.isLight() && this.isInWater())
	{
		Light(this, false);
	}
}*//*
bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return true;
}*/


void onTick(CBlob@ this)
{		
	u32 heals = this.get_u32("heals");
	if (heals < 1)
	{
		this.server_Die();
	}
	this.getCurrentScript().tickFrequency = 20; //heal interval, the bigger number, the slower
	this.getSprite().setRenderStyle(RenderStyle::normal);


	CBlob@[] blobsInRadius;

	if (this.getMap().getBlobsInRadius(this.getPosition(), 36.0f, @blobsInRadius)) //middle number is heal radius
	{			


		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ healed =  blobsInRadius[i];
			if (healed.getName() != "healer")
			{
				
				if ( healed.getHealth() <= (healed.getInitialHealth() - 0.25f))
				{
					this.getSprite().SetAnimation("default");
					healed.server_SetHealth(healed.getHealth() + 0.25f); //healing happens here
					healed.getSprite().PlaySound("/Heart.ogg");
					this.getSprite().setRenderStyle(RenderStyle::light);
					heals = (heals-1);
				}
			}
		//if(this.getTeamNum()==healed.getTeamNum() /*|| !this.get_bool("team_only") */) //checks if its a teammate

		}
	
	}
	this.set_u32("heals", heals);

}