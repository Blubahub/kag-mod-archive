// BF_MaterialsFromTiles.as

#include "MakeMat.as";
#include "ParticleSparks.as";

void onHitMap( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, u8 customData )
{
    if (damage <= 0.0f)
    {
        return;
    }
    CMap@ map = getMap();
    if (getNet().isServer())
    {
        map.server_DestroyTile(worldPoint, damage, this);
        Tile tile = map.getTile(worldPoint);
        //TileType tile_check = map.getTile(worldPoint + Vec2f(0, -8)).type;
        //print("tile_check        | type = " + tile.type);
        //print("tile_check offset | type = " + tile_check);
        if ((tile.type == 32) && (XORRandom(4) == 0))
        {
            TileType tile_above = map.getTile(worldPoint + Vec2f(0, -8)).type;
            if (tile_above == 0)
            {
                CBlob@ bf_root = server_CreateBlobNoInit("bf_root");
                if (bf_root !is null)
                {
                    bf_root.server_setTeamNum(-1);
                    bf_root.setPosition(worldPoint + Vec2f(0, -1));
                    bf_root.Init();
                }
            }
            else
            {
                for(int offset = -8; offset != -64; offset -= 8)
                {
                    TileType surface_check = map.getTile(worldPoint + Vec2f(0, offset)).type;
                    //print("offset            | change = " + offset);
                    //print("surface_check     | type = " + surface_check);
                    if (surface_check == 0)
                    {
                        CBlob@ bf_rootstatic = server_CreateBlobNoInit("bf_rootstatic");
                        if (bf_rootstatic !is null)
                        {
                            bf_rootstatic.server_setTeamNum(-1);
                            bf_rootstatic.setPosition(worldPoint);
                            bf_rootstatic.Init();
                        }
                        break;
                    }
                }
            }
        }
        else if (map.isTileStone(tile.type))
        {
            if(map.isTileThickStone(tile.type))
                MakeMat( this, worldPoint, "mat_stone", 8 * damage );
            else
                MakeMat( this, worldPoint, "mat_stone", 5 * damage );
        }
        else if (map.isTileGold(tile.type))
            MakeMat( this, worldPoint, "mat_gold", 4 * damage );
    }
}