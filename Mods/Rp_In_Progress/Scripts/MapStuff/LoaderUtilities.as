#include "ParticleSparks.as"
#include "Tiles.as"
#include "FallingTiles.as"

TileType[] BehindTiles;

void onInit(CMap@ this)
{
	this.legacyTileMinimap = false;
	//this.legacyTileVariations = false;
	//this.legacyTileEffects = false;
	//this.legacyTileDestroy = false;
	//TileType[] temp(this.tilemapwidth * this.tilemapheight, 1);
	//print("len: "+temp.get_length());
	//BehindTiles = temp;
	//BehindTiles.resize(this.tilemapwidth * this.tilemapheight);
	//print("len: "+BehindTiles.get_length());
	this.MakeMiniMap();
	//BehindTiles.clear();
	//BehindTiles.resize(this.tilemapwidth * this.tilemapheight);
	//BehindTiles.set_length(this.tilemapwidth * this.tilemapheight);
	TileType[] BehindTiles(this.tilemapwidth * this.tilemapheight, 0);
	getRules().set("btiles", @BehindTiles);
}

void CalculateMinimapColour( CMap@ this, u32 offset, TileType tile, SColor &out col)
{
    /*if (isBlockSolidTT(this, tile))
	{
		if (!isBlockSolidTT(this, this.getTile(offset-1).type) || 
			!isBlockSolidTT(this, this.getTile(offset+1).type) || 
			!isBlockSolidTT(this, this.getTile(offset-this.tilemapwidth).type) || 
			!isBlockSolidTT(this, this.getTile(offset+this.tilemapwidth).type)) col = SColor(0xff844715);
		else col = SColor(0xffC4873A);
	}
	else if (!isBlockSolidTT(this, tile) && tile != 0)
	{
		if( (this.getTile(offset-1).type == 0) || 
			(this.getTile(offset+1).type == 0) || 
			(this.getTile(offset-this.tilemapwidth).type == 0) || 
			(this.getTile(offset+this.tilemapwidth).type == 0)) col = SColor(0xffC4873A);
		else col = SColor(0xffF3AC5C);
	}
	else col = SColor(0xffEDCCA6);*/
	
	BlockInfo@ Block = getBlockTT(this, tile);
	if(Block !is null && Block.name != "placeholder")
	{
		if (isBlockSolidTT(this, tile))
		{
			if (!isBlockSolidTT(this, this.getTile(offset-1).type) || 
				!isBlockSolidTT(this, this.getTile(offset+1).type) || 
				!isBlockSolidTT(this, this.getTile(offset-this.tilemapwidth).type) || 
				!isBlockSolidTT(this, this.getTile(offset+this.tilemapwidth).type))
				col = Block.map_color;
			else
				col = SColor(0xff130D1D);
		}
		else
			col = Block.map_color;
	}
	else
		col = SColor(0xffA5BDC8);

	if (this.isInWater(this.getTileWorldPosition(offset)))
	{
		col = col.getInterpolated(SColor(255,29,133,171),0.5f);
	}
	else if (this.isInFire(this.getTileWorldPosition(offset)))
	{
		col = col.getInterpolated(SColor(255,239,67,47),0.5f);
	}
}
 
TileType server_onTileHit(CMap@ this, f32 damage, u32 index, TileType oldTileType)
{
    for(int i = 0;i < Blocks.length;i++)
	{
        BlockInfo @Block = Blocks[i];
		bool oneofthevariations = isOneOfTheVariations(oldTileType, Block.DefaultTile, Block.Variative);
        if(oldTileType == Block.DefaultTile || oneofthevariations || (oldTileType >= Block.HitStart && oldTileType <= Block.HitEnd))
		{
            int newBlock = oldTileType;
			
			int hit = Maths::Clamp(damage, 0, Block.HitEnd-Block.HitStart+1);
			if(oldTileType == Block.DefaultTile || oneofthevariations)
			{
				if(Block.name == "rubble" || Block.name == "window" || Block.name == "old stone background")
					newBlock = Block.TransformIndex;
				else if(hit > (Block.HitEnd-Block.HitStart == 0 ? 1 : Block.HitEnd-Block.HitStart))
					newBlock = Block.TransformIndex;
				else
					newBlock = Block.HitStart+hit-1;
			}
			else if(oldTileType >= Block.HitStart && oldTileType < Block.HitEnd)
			{
				if(hit > Block.HitEnd-oldTileType)
					newBlock = Block.TransformIndex;
				else
					newBlock = oldTileType+hit;
			}
			else
			{
				if(Block.name == "wood wall" && this.isInFire(this.getTileWorldPosition(index)))
					newBlock = CMap::tile_charredwoodwall;
				else
					newBlock = Block.TransformIndex;
			}
			
			if(newBlock == Block.TransformIndex)
			{
				TileType[]@ BehindTiles;
				getRules().get("btiles", @BehindTiles);
				if(BehindTiles[index] != 0)
				{
					newBlock = BehindTiles[index];
				}
			}

            return newBlock;
        }
    }
    return oldTileType;
}
 
 
void onSetTile(CMap@ map, u32 index, TileType tile_new, TileType tile_old)
{
	
	BlockInfo@ NewBlock = getBlockTT(map, tile_new);
	BlockInfo@ OldBlock = getBlockTT(map, tile_old);
	bool oneofthevariationsNewNew = isOneOfTheVariations(tile_new, NewBlock.DefaultTile, NewBlock.Variative);
	bool oneofthevariationsNewOld = isOneOfTheVariations(tile_new, OldBlock.DefaultTile, OldBlock.Variative);
	bool oneofthevariationsOldNew = isOneOfTheVariations(tile_old, NewBlock.DefaultTile, NewBlock.Variative);
	bool oneofthevariationsOldOld = isOneOfTheVariations(tile_old, OldBlock.DefaultTile, OldBlock.Variative);
	
	TileType[]@ BehindTiles;
	getRules().get("btiles", @BehindTiles);
	
	if(tile_new == NewBlock.DefaultTile && NewBlock.Variative > 0)
	{
		if(!oneofthevariationsOldNew)
			Sound::Play(NewBlock.place_sound, map.getTileWorldPosition(index), 1.0f, 1.0f);
		//if(getNet().isServer())
		//	map.server_SetTile(map.getTileWorldPosition(index), getVariation(map, NewBlock.DefaultTile, index, NewBlock.Variative));
		//else
			map.SetTile(index, getVariation(map, NewBlock.DefaultTile, index, NewBlock.Variative));
	}

	if((tile_new == NewBlock.DefaultTile && !oneofthevariationsOldNew
	) || (oneofthevariationsNewNew && !oneofthevariationsOldNew && tile_old != OldBlock.DefaultTile) || ((tile_new >= NewBlock.HitStart && tile_new <= NewBlock.HitEnd) && OldBlock.name != NewBlock.name))
	{
		if(getNet().isClient())
		{
			Sound::Play(NewBlock.place_sound, map.getTileWorldPosition(index), 1.0f, 1.0f);
		}
	}
	
	if((tile_new >= NewBlock.HitStart && tile_new <= NewBlock.HitEnd) && (tile_old == NewBlock.DefaultTile || oneofthevariationsOldNew || (tile_old >= NewBlock.HitStart && tile_old <= NewBlock.HitEnd)))
	{
		if(getNet().isClient())
		{
			Sound::Play(NewBlock.hit_sound, map.getTileWorldPosition(index), 1.0f, 1.0f);
			if(OldBlock.name == "grass")
				CreateGrassParticles(map, map.getTileWorldPosition(index));
			else
				CreateDestroyParticles(map, index, tile_old);
		}
	}
	
	if(tile_new == OldBlock.TransformIndex || tile_new == CMap::tile_empty || (getGameTime() >= 1 && tile_new == BehindTiles[index]))
	{
		if(getNet().isClient())
		{
			Sound::Play(OldBlock.destroy_sound, map.getTileWorldPosition(index), 1.0f, 1.0f);
			if(OldBlock.name == "grass")
				CreateGrassParticles(map, map.getTileWorldPosition(index));
			else
				CreateDestroyParticles(map, index, tile_old);
		}
		if(getNet().isServer())
			if(OldBlock.name == "rubble")
				CreateRubbleParticles(map, index);
	}
	
	if(getGameTime() < 1)
	{		
		if(tile_new <= 0)
		{
			map.AddTileFlag(index, Tile::LIGHT_PASSES | Tile::WATER_PASSES | Tile::LIGHT_SOURCE);
			map.RemoveTileFlag(index, Tile::BACKGROUND | Tile::LADDER | Tile::SOLID | Tile::COLLISION | Tile::FLAMMABLE);
			map.SetTileSupport(index, 0);
		}
		else
		{
			map.SetTileSupport(index, NewBlock.support);
			map.AddTileFlag(index, NewBlock.flags);
			map.RemoveTileFlag(index, 65535 ^ (NewBlock.flags));
		}
/*
		if(NewBlock.TransformIndex == CMap::tile_dirtbackground)
		{
			TileType[]@ BehindTiles;
			getRules().get("btiles", @BehindTiles);
			BehindTiles[index] = CMap::tile_dirtbackground;
			getRules().set("btiles", @BehindTiles);
		}*/
	}
	else
	{
		if(
			(NewBlock.SaveBehind && OldBlock.flags & (Tile::SOLID + Tile::COLLISION) <= 0 && OldBlock.name != "placeholder" && (tile_old == OldBlock.DefaultTile || oneofthevariationsOldOld))
			|| OldBlock.name == "dirt background")
		{
			BehindTiles[index] = OldBlock.DefaultTile;
		}

		//for (uint s = 0; s < BehindTiles.length; s++)
		//{
		//	if(BehindTiles[s] == CMap::tile_dirtbackground)
		//		map.SetTileSupport(s, -1);
		//}
		
		if(tile_new <= 0)
		{
			if((BehindTiles[index] != 0 && BehindTiles[index] != OldBlock.DefaultTile) || BehindTiles[index] == CMap::tile_dirtbackground)
			{
				map.server_SetTile(map.getTileWorldPosition(index), BehindTiles[index]);
				BlockInfo@ TempBlock = getBlockTT(map, BehindTiles[index]);
				map.SetTileSupport(index, TempBlock.support);
				map.AddTileFlag(index, TempBlock.flags);
				map.RemoveTileFlag(index, 65535 ^ (TempBlock.flags));
			}
			else
			{
				BehindTiles[index] = 0;
				map.AddTileFlag(index, Tile::LIGHT_PASSES | Tile::WATER_PASSES | Tile::LIGHT_SOURCE);
				map.RemoveTileFlag(index, Tile::BACKGROUND | Tile::LADDER | Tile::SOLID | Tile::COLLISION | Tile::FLAMMABLE);
				map.SetTileSupport(index, 0);
			}
		}
		else
		{
			map.SetTileSupport(index, BehindTiles[index] == CMap::tile_dirtbackground ? -1 : NewBlock.support);
			map.AddTileFlag(index, NewBlock.flags);
			map.RemoveTileFlag(index, 65535 ^ (NewBlock.flags));
		}
	}
	getRules().set("btiles", @BehindTiles);
	map.SetTileDirt(index, 0);
	updateNearest(map, index);
}

void CreateGrassParticles(CMap@ map, Vec2f pos)
{
	for (int i = 0; i < 3; i++)
	{
		Vec2f vel = getRandomVelocity( 1.5f, 5.0f, 180.0f);
		vel.y = -Maths::Abs(vel.y)+Maths::Abs(vel.x)/4.0f-float(XORRandom(100))/100.0f;
		CParticle@ grass = makeGibParticle("grassparts.png", pos+Vec2f(4,4), vel, 0, XORRandom(4)+1, Vec2f(4.0f, 4.0f), 5.0f, 0, "");
		if(grass !is null)
		{
			grass.gravity = Vec2f(0,0.2);
			grass.damping = 0.8f;
		}
	}
}