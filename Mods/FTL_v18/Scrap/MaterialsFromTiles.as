#include "MakeMat.as";
#include "ParticleSparks.as";

void onHitMap(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, u8 customData)
{
	if (damage <= 0.0f) return;

	CMap@ map = getMap();

	if (getNet().isClient())
	{
		TileType tile = map.getTile(worldPoint).type;
		// hit bedrock
		if (map.isTileBedrock(tile))
		{
			this.getSprite().PlaySound("/metal_stone.ogg");
			sparks(worldPoint, velocity.Angle(), damage);
		}
	}

	if (getNet().isServer())
	{
		TileType tile = map.getTile(worldPoint).type;

		map.server_DestroyTile(worldPoint, damage, this);


		// spawn materials
		if (map.isTileStone(tile))
		{
			if (map.isTileThickStone(tile))
				MakeMat(this, worldPoint, "mat_scrap", 3 * damage);
			else
				MakeMat(this, worldPoint, "mat_scrap", 2 * damage);
		}
		else if (map.isTileGold(tile))
		{
			MakeMat(this, worldPoint, "mat_scrap", 3 * damage);
		}

		if (map.isTileSolid(tile))
		{
			if (map.isTileCastle(tile)) //Temporarily disabled cause rats
			{
				//MakeMat(this, worldPoint, "mat_scrap", 2 * damage);
			}
			else if (map.isTileWood(tile))
			{
				//MakeMat(this, worldPoint, "mat_scrap", 1 * damage);
			}
		}
	}
}
