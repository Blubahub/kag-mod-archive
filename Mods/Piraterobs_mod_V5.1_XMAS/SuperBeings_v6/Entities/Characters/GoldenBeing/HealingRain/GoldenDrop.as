#include "Hitters.as";

void onInit(CBlob@ this)
{
	//dont collide with edge of the map
	this.SetMapEdgeFlags(CBlob::map_collide_none);
	
	this.getShape().getConsts().bullet = true;
	
	this.Tag("gold");
}

void onTick(CBlob@ this)
{
	if (this.getCurrentScript().tickFrequency == 1)
	{
		this.getShape().SetGravityScale(1.0f);
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
	return !blob.hasTag("evil") && blob.hasTag("player") && (blob.getName() != "goldenbeing");
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(blob !is null && !blob.hasTag("evil") && blob.hasTag("player") && (blob.getName() != "goldenbeing"))
	{
		blob.server_Heal(1);
		
		CBlob@ carry = blob.getCarriedBlob();
		if(carry !is null)
		{
			if(carry.getName() == "ctf_flag"){
				blob.server_Die();
			}
		}
	}
	if(solid)this.server_Die();
}