#include "Hitters.as";
#include "FireCommon.as";

void onInit(CBlob@ this)
{
    //this.getShape().SetOffset(Vec2f(-0.0, 0.0));
	this.getSprite().getConsts().accurateLighting = true;
	this.getSprite().SetRelativeZ(-10.0f);
	this.getShape().getConsts().waterPasses = true;

	this.Tag("place norotate");

	CShape@ shape = this.getShape();
	shape.AddPlatformDirection(Vec2f(0, -1), 70, false);
	shape.SetRotationsAllowed(false);

	this.server_setTeamNum(-1); //allow anyone to break them

	this.set_TileType("background tile", CMap::tile_wood_back);

	this.set_s16(burn_duration , 300);
	//transfer fire to underlying tiles
	this.Tag(spread_fire_tag);

}


void onSetStatic(CBlob@ this, const bool isStatic)
{
	if (!isStatic) return;

	this.getSprite().PlaySound("/build_wood.ogg");
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}