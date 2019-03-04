// BF_Storage script

#include "Requirements.as"
//#include "ShopCommon.as";
#include "CheckSpam.as";
#include "BF_Costs.as";

void onInit( CBlob@ this )
{
    this.set_TileType("background tile", CMap::tile_wood_back);
    this.getSprite().SetZ(-50);
    this.getShape().getConsts().mapCollisions = false;
}

bool isInventoryAccessible( CBlob@ this, CBlob@ forBlob )
{
	return ( forBlob.getTeamNum() == this.getTeamNum() && forBlob.isOverlapping(this) );
}