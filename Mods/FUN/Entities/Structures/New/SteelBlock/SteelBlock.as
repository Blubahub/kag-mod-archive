//trap block script for devious builders

#include "Hitters.as"
#include "MapFlags.as"

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed( false );
	this.getSprite().getConsts().accurateLighting = true;
	this.server_setTeamNum(-1);
	this.Tag("place norotate");
	//block knight sword
	this.Tag("blocks sword");
	this.Tag("blocks water");	 

	this.set_TileType("background tile", CMap::tile_castle_back);
}

void onTick( CBlob@ this )
{     
	this.server_setTeamNum(-1);
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return false;
}

#include "Hitters.as"
f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	if(customData == Hitters::builder)
	{
		return 5.0f;
	}
	
	return damage;
}