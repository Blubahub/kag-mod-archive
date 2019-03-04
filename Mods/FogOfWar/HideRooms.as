class Room
{
    uint[] offsets;

    bool shouldHide()
    {
        CBlob@ playerBlob = getLocalPlayerBlob();

        if (playerBlob is null)
        {
            return false;
        }

        return !IsBlobInRoom(this, playerBlob);
    }

    void Draw()
    {
        if (!shouldHide())
        {
            return;
        }

        for (int i = 0; i < offsets.length(); i++)
        {
            Render::Quads(test_name, 1000.0f, GetCornersFromOffset(offsets[i]), tex_coords);
        }
    }
}

void GetRooms()
{
    current_index = 0;
    getMap().get("tiles to check", tiles_to_check);
    _rooms.clear();
    offsets_used.clear();
    updating = true;
}

Room GetRoom(uint offset)
{
    uint[] q;
    uint[] tiles;
    q.push_back(offset);
    tiles.push_back(offset);

    uint[] temp;

    Room _room;

    bool not_room = false;

    CMap@ map = getMap();

    Tile t = map.getTile(offset);

    if (map.isTileSolid(t.type) || t.type == CMap::tile_empty || t.type == CMap::tile_grass)
    {
        tiles.clear();
        _room.offsets = tiles;
        return _room;
    }

    while (!q.empty())
    {
        if (map.isTileSolid(map.getTile(q[0]).type) || hasTileValidBlob
        (q[0]))
        {
            q.removeAt(0);
            if (q.empty())
            {
                continue;
            }
        }

        temp = GetTouchingBackground(q[0]);
        for (int i = 0; i < temp.length(); i++)
        {
            if (Contains(temp[i], offsets_used))
            {
                continue;
            }

            if (map.isTileSolid(map.getTile(temp[i])) || hasTileValidBlob
            (q[0]))
            {
                continue;
            }

            if (map.getTile(temp[i]).type == CMap::tile_empty || map.getTile(temp[i]).type == CMap::tile_grass)
            {
                not_room = true;
                continue;
            }

            offsets_used.push_back(temp[i]);
            q.push_back(temp[i]);
            tiles.push_back(temp[i]);
        }
        q.removeAt(0);
    }
    if (not_room)
    {
        tiles.clear();
    }
    else
    {
        offsets_used.push_back(offset);
    }
    _room.offsets = tiles;
    return _room;
}

bool Contains(uint value, uint[] arr)
{
    for (int i = 0; i < arr.length(); i++)
    {
        if (arr[i] == value)
        {
            return true;
        }
    }
    return false;
}

uint[] GetTouchingBackground(uint offset)
{
    CMap@ map = getMap();
    
    uint[] offsets;

    if (offset % map.tilemapwidth != 0)
    {
        offsets.push_back(offset - 1);
    }

    if ((offset + 1) % map.tilemapwidth != 0)
    {
        offsets.push_back(offset + 1);
    }

    if (offset > map.tilemapwidth)
    {
        offsets.push_back(offset - map.tilemapwidth);
    }

    if (offset < (map.tilemapheight - 1) * map.tilemapwidth)
    {
        offsets.push_back(offset + map.tilemapwidth);
    }

    return offsets;
}

bool IsBlobInRoom(Room room, CBlob@ blob)
{
    for (int i = 0; i < room.offsets.length(); i++)
    {
        if (BlobArrContainsBlob(GetBlobsInTile(room.offsets[i]), blob))
        {
            return true;
        }
    }
    return false;
}

CBlob@[] GetBlobsInTile(uint offset)
{
    CBlob@[] blobs;
    CMap@ m = getMap();

    int x = offset % m.tilemapwidth;
    int y = Maths::Floor(offset / m.tilemapwidth);

    m.getBlobsAtPosition(Vec2f(x * 8 + 4, y * 8 + 4), blobs);

    return blobs;
}

bool BlobArrContainsBlob(CBlob@[] blobs, CBlob@ blob)
{
    for (int i = 0; i < blobs.length(); i++)
    {
        if (blobs[i] is blob)
        {
            return true;
        }
    }
    return false;
}

bool hasTileValidBlob(uint offset)
{
    CBlob@[] blobs = GetBlobsInTile(offset);

    for (int i = 0; i < blobs.length(); i++)
    {
        if (blobs[i].getName() == "stone_door" || blobs[i].getName() == "wooden_door" || blobs[i].getName() == "trap_block")
        {
            return true;
        }
    }
    return false;
}

Vec2f[] GetCornersFromOffset(uint offset)
{
    CMap@ m = getMap();

    Vec2f[] corners;

    int x = offset % m.tilemapwidth;
    int y = Maths::Floor(offset / m.tilemapwidth);

    corners.push_back(Vec2f(x * 8, y * 8));
    corners.push_back(Vec2f((x + 1) * 8, y * 8));
    corners.push_back(Vec2f((x + 1) * 8, (y + 1) * 8));
    corners.push_back(Vec2f(x * 8, (y  + 1) * 8));

    return corners;
}

const string test_name = "_scriptrender_test_texture";

Vec2f[] tex_coords = 
{
	Vec2f(0, 0),
	Vec2f(1, 0),
	Vec2f(1, 1),
	Vec2f(0, 1)
};

int current_index;
uint[] tiles_to_check;
uint[] offsets_used;
Room[] rooms;
Room[] _rooms;

bool updating = false;

void Setup()
{
	//ensure texture for our use exists
	if(!Texture::exists(test_name))
	{
		if(!Texture::createBySize(test_name, 1, 1))
		{
			warn("texture creation failed");
		}
		else
		{
			ImageData@ edit = Texture::data(test_name);

			for(int i = 0; i < edit.size(); i++)
			{
                edit[i] = SColor(0xff000000);
			}

			if(!Texture::update(test_name, edit))
			{
				warn("texture update failed");
			}
		}
	}

    updating = false;
    current_index = 0;

    getRules().Untag("map is loading");

    if (getNet().isServer())
    {
        return;
    }

    CMap@ map = getMap();
    uint[] _tiles_to_check;

    for (int i = 0; i < map.tilemapwidth * map.tilemapheight; i++)
    {
        switch (map.getTile(i).type)
        {
            case (CMap::tile_ground_back):
            case (CMap::tile_castle_back):
            case (CMap::tile_castle_back_moss):
            case (CMap::tile_wood_back):
            case (CMap::tile_ladder_ground):
            case (CMap::tile_ladder_castle):
            case (CMap::tile_ladder_wood):
                _tiles_to_check.push_back(i);
                break;

            default:
                break;
        }
    }

    map.set("tiles to check", _tiles_to_check);
}

void onInit(CRules@ this)
{
    this.addCommandID("get rooms");
    this.addCommandID("add tile");
    this.addCommandID("remove tile");

	Setup();
	int cb_id = Render::addScript(Render::layer_objects, "HideRooms.as", "ExampleRulesRenderFunction", 0.0f);
}

void onRestart(CRules@ this)
{
	Setup();
}

void onTick(CRules@ this)
{
    if (getNet().isServer())
    {
        return;
    }

    if (!updating || getGameTime() < 1)
    {
        return;
    }

    CMap@ map = getMap();

    for (int i = 0; i < 4; i++)
    {
        if (current_index++ == tiles_to_check.length())
        {
            updating = false;
            rooms = _rooms;
            return;
        }

        Tile t = map.getTile(tiles_to_check[current_index]);

        if (t.type == CMap::tile_empty || t.type == CMap::tile_grass)
        {
            continue;
        }

        if (Contains(tiles_to_check[current_index], offsets_used))
        {
            continue;
        }

        Room room = GetRoom(tiles_to_check[current_index]);
        if (room.offsets.empty())
        {
            continue;
        }
        _rooms.push_back(room);
    }
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
    if (cmd == this.getCommandID("get rooms") && getNet().isClient())
    {
        GetRooms();
    }

    if (cmd == this.getCommandID("add tile"))
    {
        uint[] temp;
        CMap@ map = getMap();
        map.get("tiles to check", temp);
        uint index = params.read_u32();
        if (temp.find(index) == -1)
        {
            temp.push_back(index);
        }
        map.set("tiles to check", temp);
    }

    if (cmd == this.getCommandID("remove tile"))
    {
        uint[] temp;
        CMap@ map = getMap();
        map.get("tiles to check", temp);
        uint index = params.read_u32();
        if (temp.find(index) != -1)
        {
            temp.removeAt(temp.find(index));
        }
        map.set("tiles to check", temp);
    }
}

void ExampleRulesRenderFunction(int id)
{
    for (int i = 0; i < rooms.length(); i++)
    {
        rooms[i].Draw();
    }
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
    if (getLocalPlayer() !is player)
    {
        return;
    }

    CMap@ map = getMap();
    uint[] _tiles_to_check;

    for (int i = 0; i < map.tilemapwidth * map.tilemapheight; i++)
    {
        switch (map.getTile(i).type)
        {
            case (CMap::tile_ground_back):
            case (CMap::tile_castle_back):
            case (CMap::tile_castle_back_moss):
            case (CMap::tile_wood_back):
            case (CMap::tile_ladder_ground):
            case (CMap::tile_ladder_castle):
            case (CMap::tile_ladder_wood):
                _tiles_to_check.push_back(i);
                break;

            default:
                break;
        }
    }

    map.set("tiles to check", _tiles_to_check);
}