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


					this.setVelocity(vel + dir * 1.5f);
				}
			}
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return (blob.getTeamNum() != this.getTeamNum() && blob.hasTag("player"));
}


void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(blob !is null && blob.getTeamNum() != this.getTeamNum() && blob.hasTag("flesh") && blob.hasTag("player"))
	{
		CPlayer@ p = blob.getPlayer();
		if(p !is null){
			if(this.getDamageOwnerPlayer() !is null){
				CBlob@ b = this.getDamageOwnerPlayer().getBlob();
				if(b !is null){
					blob.server_SetPlayer(this.getDamageOwnerPlayer());
					blob.server_setTeamNum(this.getDamageOwnerPlayer().getTeamNum());
					b.server_SetPlayer(p);
					b.server_setTeamNum(p.getTeamNum());
				} else {
					blob.server_SetPlayer(this.getDamageOwnerPlayer());
					blob.server_setTeamNum(this.getDamageOwnerPlayer().getTeamNum());
				}
			}
		} else {
			if(this.getDamageOwnerPlayer() !is null){
				CBlob@ b = this.getDamageOwnerPlayer().getBlob();
				if(b !is null){
					blob.server_SetPlayer(this.getDamageOwnerPlayer());
					blob.server_setTeamNum(this.getDamageOwnerPlayer().getTeamNum());
					b.server_SetPlayer(null);
				} else {
					blob.server_SetPlayer(this.getDamageOwnerPlayer());
					blob.server_setTeamNum(this.getDamageOwnerPlayer().getTeamNum());
				}
			}
		}
	}
	
	if(solid)this.server_Die();
	if(blob !is null)if(blob.getName() == "stone_door" || blob.getName() == "wooden_door")if(blob.getShape().getConsts().collidable)this.server_Die();
}