#include "Hitters.as";
#include "ModHitters.as";
#include "ep.as";
#include "Ally.as";
#include "eleven.as";

void onInit(CBlob@ this)
{
	this.SetMapEdgeFlags(CBlob::map_collide_none);
	this.getShape().getConsts().bullet = true;
	this.getShape().getConsts().mapCollisions = false;
	
	this.getShape().SetGravityScale(0.0f);
}

void onTick(CBlob@ this)
{
	if(getMap().isTileSolid(this.getPosition())){
		this.setVelocity(Vec2f(0,0));
		if(isServer() && !this.hasTag("ded")){
			this.server_Die();
			this.Tag("ded");
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return (blob.hasTag("flesh") && !blob.hasTag("dead") && checkAlly(this.getTeamNum(),blob.getTeamNum()) != Team::Ally);
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{

	if(blob !is null)
	if(blob.hasTag("flesh") && !blob.hasTag("dead") && checkAlly(this.getTeamNum(),blob.getTeamNum()) != Team::Ally)
	{
		this.server_Hit(blob, blob.getPosition(), this.getVelocity(), 5.0f, Hitters::suddengib, true);
		this.server_Die();
	}	
}

void onDie(CBlob @this){
	if(isServer())getMap().server_DestroyTile(this.getPosition(),100.0f);
}