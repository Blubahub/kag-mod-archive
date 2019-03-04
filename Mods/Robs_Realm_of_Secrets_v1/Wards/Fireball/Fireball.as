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
		this.server_SetTimeToDie(1.0f);

		// done post init
		this.getCurrentScript().tickFrequency = 10;
	}
	
	if(this.isInWater())this.server_Die();
	
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
	if(!blob.hasTag("flesh") && !blob.hasTag("plant"))return false;
	if(blob.getTeamNum() != this.getTeamNum())return true;
	return false;
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	
	if(blob !is null && blob.getTeamNum() != this.getTeamNum())
	if(blob.hasTag("flesh") || blob.hasTag("plant")){
		this.server_Hit(blob, blob.getPosition(), this.getVelocity()*0.5f, 0.25f, Hitters::fire, false);
		if(blob.hasTag("flesh") || blob.hasTag("plant"))this.server_Die();
	}
	if(solid){
		CMap@ map = getMap();
		if (map != null)
		map.server_setFireWorldspace(this.getPosition()-this.getVelocity(), true);
		this.server_Die();
	}
	
}