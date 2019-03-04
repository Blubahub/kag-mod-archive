#include "Tiles.as";

void onInit(CRules@ this)
{
	CRules@ rules = getRules();
	rules.addCommandID("ftileAdd");
	rules.addCommandID("ftileRemove");
	Render::addScript(Render::layer_postworld, "FallingTiles.as", "FallingTilesRender", 0.0f);
	FallingTile[] FallingTiles;
	rules.set("ftiles", @FallingTiles);
}

FallingTile[]@ getFallingTiles()
{
	FallingTile[]@ FallingTiles;
	getRules().get("ftiles", @FallingTiles);
	return FallingTiles;
}

class FallingTile
{
	TileType tile;
	bool solid = false;
	f32 damage = 0.0f;
	Vec2f position = Vec2f(0.0f, 0.0f);
	Vec2f velocity = Vec2f(0.0f, 0.3f);
	bool remove = false;

	FallingTile(TileType tile,  Vec2f position, bool solid, f32 damage)
	{
		this.tile = tile;
		this.position = position;
		this.solid = solid;
		this.damage = damage;
		this.velocity = Vec2f(0.0f, 0.3f);
		this.remove = false;
	}
	
	void UpdateFallingTile(CMap@ map)
	{
		if(getNet().isServer())
		{
			if(solid)
			{
				CBlob@[] blobs;
				if (map.getBlobsAtPosition(position, blobs))
				{
					for (uint i = 0; i < blobs.length; i++)
					{
						CBlob@ b = blobs[i];
						if (b is null) continue;

						if (b.hasTag("material") || b.hasTag("invincible") || b.getName() == "egg") continue;

						f32 dmg = damage;
						if(!b.hasTag("flesh"))
							dmg *= 10;

						b.server_Hit(b, position, velocity, dmg, 0, true);

						remove = true;

						break;
					}
				}
			}

			if (!remove && isBlockSolid( map, map.getTileOffset(position + Vec2f(0, 8))) && velocity.y > -0.1f)
			{
				if(solid)
				{
					PlaceTile(map, tile, position, velocity.y);
					//map.server_SetTile(position, tile);
				}
			
				remove = true;
			}
			else
			{
				if(velocity.y < 6.2)
					velocity.y += 0.2f;
				position += velocity;
			}
		}
		else
		{
			if(velocity.y < 6.2)
				velocity.y += 0.2f;
			position += velocity;
		}
	}
	
	void RenderFallingTile()
    {
        //TODO: consider if we need to get lighting here
		u8 light = getMap().getTile(position).light;
		SColor col(0xff000000 | light << 16 | light << 8 | light);
        //SColor col(255, 80, 80, 80);

        //add vertices

        //TODO: pass vertex array in and push content here, rather than actually rendering
        //
        //      that way it can be faster because you can avoid re-allocating array all the time
        //      and render in 1 call!

        const float tile_size = 8.0f; //(faster than getting it from map all the time)
        const float halfsize = tile_size * 0.5f;

        //z in line with front of map - you can choose whatever you want
        const float z = 500.0f;

        //(frame size in texcoords)
        const float frame_width =  1.0f / 16.0f;
        const float frame_height = 1.0f / 32.0f;
        //(calc texture coord top left)
        const float tile_u1 = (tile % 16) * frame_width;
        const float tile_v1 = (tile / 16) * frame_height;
        //(bottom right)
        const float tile_u2 = tile_u1 + frame_width;
        const float tile_v2 = tile_v1 + frame_height;
		
		//const float tile_u1 = 0;
        //const float tile_v1 = 0;
        //const float tile_u2 = 1;
        //const float tile_v2 = 1;

        Vertex[] v_raw;
        v_raw.push_back(Vertex(position.x - halfsize, position.y - halfsize, z, tile_u1, tile_v1, col));
        v_raw.push_back(Vertex(position.x + halfsize, position.y - halfsize, z, tile_u2, tile_v1, col));
        v_raw.push_back(Vertex(position.x + halfsize, position.y + halfsize, z, tile_u2, tile_v2, col));
        v_raw.push_back(Vertex(position.x - halfsize, position.y + halfsize, z, tile_u1, tile_v2, col));

        //render
        Render::RawQuads("world.png", v_raw);
    }
};

bool onMapTileCollapse(CMap@ map, u32 offset)
{
    if(getNet().isServer() && !map.hasTileFlag(offset, Tile::SPARE_2))
	{
		map.SetTileSupport(offset, 0);
		map.AddTileFlag(offset, Tile::SPARE_2);
		positions.push_back(offset);
		return false;
	}
	return false;
}

void onTick(CMap@ this)
{
	
	CRules@ rules = getRules();
	
	FallingTile[]@ FallingTiles = getFallingTiles();
	
	for(int t = 0; t < FallingTiles.length; t++)
	{
		FallingTile@ ftile = FallingTiles[t];
		ftile.UpdateFallingTile(this);
	}
	if(getNet().isServer())
	{
		for(int i = 0; i < FallingTiles.length; i++)
		{
			FallingTile@ ftile = FallingTiles[i];
			if(ftile.remove)
			{
				
				//BlockInfo@ Block = getBlock(getMap(), ftile.tile);
				//Sound::Play(Block.destroy_sound, ftile.position, 1.0f, 1.0f);
				//CreateDestroyParticles(getMap(), getMap().getTileOffset(ftile.position), ftile.tile);
				
				CBitStream params;
				params.write_s32(i);
				rules.SendCommand(rules.getCommandID("ftileRemove"), params, true);
				FallingTiles.removeAt(i);
			}
		}
	}

	rules.set("ftiles", @FallingTiles);
	
	if(getNet().isServer())
	{
		if(getGameTime() % 3 != 0)
			return;
	
		positions.sortAsc();
	
		int maxblockspertick = Maths::Min(positions.length(), 8);
	
		if(maxblockspertick > 0)
		{
			for(int i = 0; i < maxblockspertick; i++)
			{
				int index = positions[positions.length()-1];
				if(this.hasTileFlag(index, Tile::SPARE_2))
				{
					int tt = this.getTile(index).type;
					BlockInfo@ Block = getBlock(this, index);
					if(Block !is null && isOneOfTheVariations(tt, Block.DefaultTile, Block.Variative))
						tt = Block.DefaultTile;
					this.server_SetTile(this.getTileWorldPosition(index), CMap::tile_empty);
					if(Block.collapse)
					{
						CBitStream params;
						params.write_TileType(tt);
						params.write_Vec2f(this.getTileWorldPosition(index)+Vec2f(4,4));
						params.write_bool(isBlockSolidTT(this, tt));
						params.write_f32(Block.collapseDamage);
						rules.SendCommand(rules.getCommandID("ftileAdd"), params, true);
						FallingTile@ ftile = FallingTile(tt,  this.getTileWorldPosition(index)+Vec2f(4,4), isBlockSolidTT(this, tt), Block.collapseDamage);
						FallingTiles.push_back(ftile);
					}
				}
				positions.erase(positions.length()-1);
			}
			rules.set("ftiles", @FallingTiles);
		}
	}
}

void onCommand( CRules@ this, u8 cmd, CBitStream @params )
{
	if(getNet().isServer())
		return;

	if(cmd == this.getCommandID("ftileAdd"))
	{
		TileType tt = params.read_TileType();
		Vec2f position = params.read_Vec2f();
		bool solid = params.read_bool();
		f32 damage = params.read_f32();
		addFallingTile(tt, position, solid, damage);
		/*FallingTile@ ftile = FallingTile(tt,  position, solid, damage);
		FallingTile[] FallingTiles;
		this.get("ftiles", FallingTiles);
		FallingTiles.push_back(ftile);
		this.set("ftiles", FallingTiles);*/
	}
	else if(cmd == this.getCommandID("ftileRemove"))
	{
		int t = params.read_s32();
		removeFallingTile(t);
	}
}

void addFallingTile(TileType tt, Vec2f position, bool solid, f32 damage)
{
	CRules@ rules = getRules();
	
	FallingTile[]@ FallingTiles = getFallingTiles();

	FallingTile@ ftile = FallingTile(tt,  position, solid, damage);
	
	FallingTiles.push_back(ftile);
	rules.set("ftiles", @FallingTiles);
}

void removeFallingTile(s32 t)
{
	CRules@ rules = getRules();
	
	FallingTile[]@ FallingTiles = getFallingTiles();

	//FallingTile@ ftile = FallingTiles[t];
	//BlockInfo@ Block = getBlock(getMap(), ftile.tile);
	//Sound::Play(Block.destroy_sound, ftile.position, 1.0f, 1.0f);
	//CreateDestroyParticles(getMap(), getMap().getTileOffset(ftile.position), ftile.tile);

	FallingTiles.removeAt(t);
	rules.set("ftiles", @FallingTiles);
}

void FallingTilesRender(int id)
{
	FallingTile[]@ FallingTiles = getFallingTiles();

	//print("l: "+FallingTiles.length);
	for(int t = 0; t < FallingTiles.length; t++)
	{
		FallingTile@ ftile = FallingTiles[t];
		ftile.RenderFallingTile();
		//print("drawing: "+ftile.position.y);
	}
}

void PlaceTile(CMap@ map, TileType tile, Vec2f position, f32 vely)
{
	BlockInfo@ Block = getBlockTT(map, tile);
	if(Block !is null)
	{
		f32 collapsePlaceChance = Block.collapsePlaceChance;
		if(XORRandom(100) < collapsePlaceChance*100)
		{
			f32 collapsePlaceSelfHarmModif = Block.collapsePlaceSelfHarmModif;
			if(Block.name == "stone wall")
			{
				if(vely/6 < collapsePlaceSelfHarmModif)
					map.server_SetTile(position, tile);
				else
				{
					if(Block.name == "stone wall")
						map.server_SetTile(position, CMap::tile_newrubble);
				}
			}
			else
				map.server_SetTile(position, tile);
		}
	}
}