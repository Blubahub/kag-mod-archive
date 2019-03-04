#include "Hitters.as"
#include "ParticleSparks.as";

void onInit(CBlob@ this)
{
	this.getSprite().getConsts().accurateLighting = true;
	
	CShape@ shape = this.getShape();
	shape.getConsts().waterPasses = true;
	shape.SetRotationsAllowed(false);
	shape.getConsts().mapCollisions = true;
	shape.getConsts().support = 16;
	

	this.set_TileType("background tile", CMap::tile_castle_back);
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	if (!isStatic) return;

	this.getSprite().PlaySound("/build_wall.ogg");
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}