#include "MakeMat.as";
#include "ParticleSparks.as";
#include "Hitters.as";

void onHitMap(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, u8 customData)
{
	if (damage <= 0.0f) return;

	CMap@ map = getMap();

	TileType tile = map.getTile(worldPoint).type;
	
	if (!map.isTileWood(tile) && customData == Hitters::saw && !(tile >= 205 && tile <= 207)){
		return;
	}
	
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
			if (XORRandom(20)==0)
			{
				server_CreateBlob("metal_ore", this.getTeamNum(), this.getPosition());
			}
			
			if (map.isTileThickStone(tile))
				MakeMat(this, worldPoint, "mat_stone", 6);
			else
				MakeMat(this, worldPoint, "mat_stone", 4);
		}
		else if (map.isTileGold(tile))
		{
			MakeMat(this, worldPoint, "mat_gold", 1);
		}
		else
		if (map.isTileGroundStuff(tile))
		{
			MakeMat(this, worldPoint, "mat_dirt", 1);
		}

		if (map.isTileSolid(tile))
		{
			if (map.isTileCastle(tile))
			{
				MakeMat(this, worldPoint, "mat_stone", 1);
			}
			else if (map.isTileWood(tile))
			{
				MakeMat(this, worldPoint, "mat_wood", 1);
			}
		}
	}
}
