#include "Hitters.as"
#include "MakeMat.as"
void onInit(CBlob@ this)
{
    this.getSprite().getConsts().accurateLighting = true;
	this.getShape().getConsts().waterPasses = false;
    //this.set_TileType("background tile", CMap::tile_castle);
    this.server_setTeamNum(-1); //allow anyone to break them
	this.Tag("place norotate");
	this.Tag("stone");
	this.Tag("large");
	this.Tag("rune");
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return false;
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	this.getSprite().PlaySound("/dig_stone");
	f32 dmg = damage;
	switch(customData)
	{
	case Hitters::builder:
		dmg *= 4.0f;
		break;	
	case Hitters::bomb:
	case Hitters::keg:
	case Hitters::cata_stones:
	break;
	case Hitters::arrow:
	default:
		dmg=0;
		break;
	}	
	return dmg;
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return true;
}