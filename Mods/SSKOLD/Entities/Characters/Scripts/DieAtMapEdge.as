#include "Hitters.as"
#include "SSKStatusCommon.as"

void onInit(CBlob@ this)
{
	this.SetMapEdgeFlags( u8(CBlob::map_collide_none) | u8(CBlob::map_collide_nodeath) );	// fall out of map in every direction
}

void onTick(CBlob@ this)
{
	// die if outside of map
	CMap@ map = getMap();
	const u16 mapWidth = map.tilemapwidth * map.tilesize;
	const u16 mapHeight = map.tilemapheight * map.tilesize;
	Vec2f thisPos = this.getPosition();
	f32 DEATH_MARGIN = 8.0f;
	if (thisPos.x < -DEATH_MARGIN || thisPos.x > mapWidth + DEATH_MARGIN 
		|| thisPos.y < -DEATH_MARGIN || thisPos.y > mapHeight + DEATH_MARGIN)
	{
		this.server_Die();
	}
	else if (this.getPlayer() is null)
	{
		this.server_Die();
	}
}
