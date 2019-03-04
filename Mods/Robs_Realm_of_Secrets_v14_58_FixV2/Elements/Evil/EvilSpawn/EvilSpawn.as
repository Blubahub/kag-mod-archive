#include "ChangeClass.as";

void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightColor(SColor(255, 200, 0, 255));
	this.SetLightRadius(80.0f);
	this.set_string("boss","");
}

void onTick(CBlob@ this)
{
	if (getNet().isServer()){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 32.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b.getName() == "ghost")
				{
					CBlob @newBlob = ChangeClass(b, "builder", b.getPosition(), this.getTeamNum());
					if (newBlob !is null)
					{
						newBlob.set_u8("race",1);
						newBlob.set_string("boss",this.get_string("boss"));
					}
				}
			}
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if(hitterBlob !is null)
	if(hitterBlob.getTeamNum() == this.getTeamNum())return 0;
	
	return damage;
}
