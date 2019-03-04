#include "MakeMat.as";
#include "ParticleSparks.as";

void onHitMap(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, u8 customData)
{
	if (damage <= 0.0f) return;
	f32 dmg = 0.125;

	CMap@ map = getMap();

	if (getNet().isClient())
	{
		TileType tile = map.getTile(worldPoint).type;
		// hit bedrock
		if (map.isTileBedrock(tile))
		{
			this.getSprite().PlaySound("/metal_stone.ogg");
			sparks(worldPoint, velocity.Angle(), dmg);
		}
	}

	if (getNet().isServer())
	{
		TileType tile = map.getTile(worldPoint).type;

		map.server_DestroyTile(worldPoint, dmg, this);
	}
}
