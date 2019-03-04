#include "ProductionCommon.as";
#include "Requirements.as";
#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 30;
}

void onTick(CBlob@ this)
{
// if it's at 0 then it should be smokey! else it should be anything from 1 to 8!
	if (this.get_u16("wood_amount") == 0)
	{
		this.SetLightRadius(0.0f);
	}
	else 
	{
		this.SetLightRadius(this.get_u16("wood_amount")/120);
	}
	if (this.get_u16("wood_amount") > 0)
		this.set_u16("wood_amount", this.get_u16("wood_amount")-1);
		
		

	CBlob@[] blobsInRadius;	 
	if(getNet().isServer())
	if(this.get_u16("wood_amount") > 120*6)
	if (this.getMap().getBlobsInRadius(this.getPosition(), 8.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b !is this)
			this.server_Hit(b, b.getPosition(), Vec2f(), 2.0f, Hitters::fire, true);
			
			if(b.hasTag("liquid_blob")){
				b.set_u32("last_heated",getGameTime());
			}
			
			if(b.hasTag("metaldrop") || b.hasTag("hard_liquid_blob")){
				b.Tag("heated");
			}
		}
	}
}	