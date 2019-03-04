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
	
	if (customData != Hitters::builder && customData != Hitters::saw){
		map.server_DestroyTile(worldPoint, damage, this);
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

		// spawn materials
		if (map.isTileStone(tile))
		{
			if (XORRandom(20) == 0)
			{
				this.server_PutInInventory(server_CreateBlob("metal_ore", this.getTeamNum(), this.getPosition()));
			}
			
			if (map.isTileThickStone(tile))
				MakeMat(this, worldPoint, "mat_stone", 6);
			else
				MakeMat(this, worldPoint, "mat_stone", 4);
		}
		else if (map.isTileGold(tile))
		{
			if (XORRandom(2) == 0){
				CBlob @gold = server_CreateBlob("gold_ore", this.getTeamNum(), this.getPosition());
				if (XORRandom(2) == 0)gold.Tag("light_infused");
				this.server_PutInInventory(gold);
			}
		}
		else
		if (map.isTileGroundStuff(tile))
		{
			MakeMat(this, worldPoint, "mat_dirt", 1);
		}
		else
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
		
		map.server_DestroyTile(worldPoint, damage, this);
	}
	
	
}
