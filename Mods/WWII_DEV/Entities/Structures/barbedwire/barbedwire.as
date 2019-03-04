//trap block script for devious builders

#include "Hitters.as"
#include "MapFlags.as"

int openRecursion = 0;

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed( false );
	this.getShape().getConsts().mapCollisions = false;
	this.getShape().SetStatic(true);
    this.getSprite().getConsts().accurateLighting = true;  
    //this.Tag("place norotate");
    
    //block knight sword
	this.Tag("blocks sword");

	this.Tag("blocks water");
	this.server_setTeamNum(-1);
	
	this.Tag("builder always hit");

	MakeDamageFrame( this );
	this.getCurrentScript().runFlags |= Script::tick_not_attached;		 
}



void MakeDamageFrame( CBlob@ this )
{
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null && blob.hasTag("flesh"))
	{
		this.server_Hit(blob, this.getPosition(), Vec2f(0, 0), 0.125f, Hitters::spikes, true);
	}
}


bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return false;
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	if (hitterBlob !is null && hitterBlob !is this && customData == Hitters::builder)
	{
		this.server_Hit(hitterBlob, this.getPosition(), Vec2f(0, 0), 0.125f, Hitters::spikes, false);
	}
	
	return damage;
}
