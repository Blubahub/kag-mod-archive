#include "Hitters.as";
#include "Knocked.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "Help.as";
#include "Requirements.as";
#include "FireParticle.as";
#include "DestroyNatureSprites.as";

void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;
	shape.SetGravityScale(0);
	shape.SetStatic(true);
}

void onTick(CBlob@ this)
{
	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius(this.getPosition(), 160.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b !is null){
				Vec2f dir = this.getPosition()-b.getPosition();
				dir.Normalize();
				b.setVelocity(dir+b.getVelocity()*0.9);
				this.server_Hit(b, this.getPosition(), this.getVelocity()*-0.5f, 0.01f, Hitters::suddengib, false);
			}
		}
	}
	
	if(getNet().isClient())
	if(!this.hasTag("NDS")){
		DestroyNatureSprites();
		this.Tag("NDS");
	}
}