#include "Hitters.as";
#include "BombCommon.as";
#include "DarkTribute.as";

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
	return this.getTeamNum() != blob.getTeamNum();
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(blob !is null && this.getTeamNum() != blob.getTeamNum() && blob.hasTag("player"))
	{
		if(blob.getHealth() > 0) blob.server_Heal(-1);
		else {
			this.server_Hit(blob, this.getPosition(), this.getVelocity()*0.5f, 0.5f, Hitters::suddengib, false);
			if(getNet().isServer()){
				server_CreateBlob("zombie", this.getTeamNum(), blob.getPosition());
				blob.server_Die();
				Tribute(this,1);
			}
		}
	} else
	if(blob !is null && this.getTeamNum() != blob.getTeamNum()){
		this.server_Hit(blob, this.getPosition(), this.getVelocity()*0.5f, 1, Hitters::suddengib, false);
	}
	if(blob !is null && blob.getName() == "seed"){
		blob.server_Die();
	}
	if(solid)this.server_Die();
}