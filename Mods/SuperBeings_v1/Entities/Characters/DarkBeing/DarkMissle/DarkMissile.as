#include "Hitters.as";
#include "BombCommon.as";

void onInit(CBlob@ this)
{
	//dont collide with edge of the map
	this.SetMapEdgeFlags(CBlob::map_collide_none);
	
	this.getShape().getConsts().bullet = true;
}

void onTick(CBlob@ this)
{
	if (this.getCurrentScript().tickFrequency == 1)
	{
		this.getShape().SetGravityScale(0.0f);
		this.server_SetTimeToDie(3);

		// done post init
		this.getCurrentScript().tickFrequency = 10;
	}
	
	this.setAngleDegrees(-((this.getVelocity()).Angle()+180));
	
	{
		u16 id = this.get_u16("target");
		if (id != 0xffff && id != 0)
		{
			CBlob@ b = getBlobByNetworkID(id);
			if (b !is null)
			{
				Vec2f vel = this.getVelocity();
				if (vel.LengthSquared() < 9.0f)
				{
					Vec2f dir = b.getPosition() - this.getPosition();
					dir.Normalize();


					this.setVelocity(vel + dir * 3.0f);
				}
			}
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.getName() == "goldenbeing";
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(blob !is null)
	if(blob.getName() == "goldenbeing"){
		blob.set_s16("power",blob.get_s16("power")-10);
		SetupBomb(this, 120, 16.0f, 0.5f, 16.0f, 0.4f, true);
		ParticleZombieLightning(this.getPosition()); // TFlippy
		this.server_Die();
	}
	if(solid){
		SetupBomb(this, 120, 16.0f, 0.5f, 16.0f, 0.4f, true);
		
		CMap@ map = getMap();
		map.server_setFireWorldspace(this.getPosition() + Vec2f(XORRandom(2) - 1, XORRandom(2) - 1), true); // TFlippy
		
		ParticleZombieLightning(this.getPosition()); // TFlippy
		this.server_Die();
	}
}