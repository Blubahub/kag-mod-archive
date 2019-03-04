#include "Hitters.as";

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
	return true;
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(blob !is null && this.getTeamNum() != blob.getTeamNum() && blob.hasTag("flesh"))
	{
		if(getNet().isServer()){
			blob.server_Hit(blob, this.getPosition(), this.getVelocity()*-0.5f, 2.0f, Hitters::fire, false);
			this.server_Die();
		}
	}
	if(blob !is null && this.getTeamNum() == blob.getTeamNum() && this.getTickSinceCreated() > 1){
		if(blob.getHealth() < blob.getInitialHealth()){
			blob.server_Heal(0.25);
			this.server_Die();
		}
	}
	
	if(solid)
	{
		ParticleBloodSplat(this.getPosition(), true);
		this.getSprite().PlaySound("/OrbExplosion", 1.50f, 1.00f);
		ParticleAnimated("Entities/Effects/Sprites/SmallExplosion" + (XORRandom(3) + 1) + ".png", this.getPosition(), Vec2f(0, 0.5f), 0.0f, 1.0f, 3 + XORRandom(3), -0.1f, true);
	
		CMap@ map = getMap();
		if (map != null)
		map.server_setFireWorldspace(this.getPosition()-this.getVelocity(), true);
		this.server_Die();
	}
}