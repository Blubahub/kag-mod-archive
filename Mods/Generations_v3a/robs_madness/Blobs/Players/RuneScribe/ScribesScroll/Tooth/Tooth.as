#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.SetMapEdgeFlags(CBlob::map_collide_none);
	this.getShape().getConsts().bullet = true;

	this.server_SetTimeToDie(10.0f);
	
	this.set_u8("count",10);
	this.set_u32("timestamp",getGameTime());
	this.set_s8("direction",1);
	
	this.Tag("can_dispell");
}

void onTick(CBlob@ this)
{
	if(getNet().isServer())
	if(this.get_u8("count") > 0)
	if(this.get_u32("timestamp")+3 == getGameTime()){
		CBlob @blob = server_CreateBlob("tooth", this.getTeamNum(), this.getPosition()+Vec2f(this.get_s8("direction")*8,-5));
		blob.set_u8("count",this.get_u8("count")-1);
		blob.set_s8("direction",this.get_s8("direction"));
	}
	
	this.setAngleDegrees(-((this.getVelocity()).Angle()+90));
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if(blob.getShape().isStatic())return true;
	if(!blob.hasTag("flesh") && !blob.hasTag("plant"))return false;
	if(blob.getTeamNum() != this.getTeamNum())return true; 
	return false;
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(blob !is null && blob.getTeamNum() != this.getTeamNum())
	
	if(blob.hasTag("flesh") || blob.hasTag("plant"))
	{
		this.server_Hit(blob, blob.getPosition(), this.getVelocity()*-0.5f, 1.0f, Hitters::sword, false);
		this.server_Die();
	}
	if(solid)
	{
		this.server_Die();
	}
	
}