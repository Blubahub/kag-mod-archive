#include "Hitters.as"

void onInit(CBlob@ this)
{
    this.getSprite().getConsts().accurateLighting = true;
	this.getShape().getConsts().waterPasses = false;
    this.server_setTeamNum(-1);
	this.Tag("place norotate");
	this.Tag("stone");
	this.Tag("large");
	this.set_TileType("background tile", CMap::tile_wood_back);
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return false;
}


bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return true;
}
