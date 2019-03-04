
//SSK random items spawning logic

const array<string> ITEMS_LIST =
{
	"bomb",
	"waterbomb",
	"keg",
	"mine",
	"trampoline",
	"saw",
	"boulder",
	"green_shell",
	"smart_bomb",
	"food",
	"steak",
	"drill",
	"barrel",
	"grenade"
};

const int SPAWN_INTERVAL = 120;
const f32 MAX_SPAWN_HEIGHT = 128.0f;
const f32 SPAWN_MARGIN = 64.0f;

const int MAX_ITEMS = 20;

const int MAX_ITERATIONS = 20;

void onInit( CRules@ this )
{
	this.set_u16("item timer", 0);
	this.set_u16("item counter", 0);

	this.addCommandID("spawn item");
}

void onTick( CRules@ this )
{
	if (getNet().isServer()) 
	{
		u16 itemTimer = this.get_u16("item timer");
		bool itemSpawned = false;
		if (itemTimer <= 0)
		{
			u16 itemCounter = this.get_u16("item counter");

			if (itemCounter < MAX_ITEMS)
			{
				CMap@ map = getMap();
				const u16 mapWidth = map.tilemapwidth * map.tilesize;
				const u16 mapHeight = map.tilemapheight * map.tilesize;
				
				f32 randomPosX = SPAWN_MARGIN + XORRandom(mapWidth - SPAWN_MARGIN);
				f32 randomPosY = SPAWN_MARGIN + XORRandom(mapHeight - SPAWN_MARGIN);
				Vec2f spawnPos = Vec2f(randomPosX, randomPosY);

				if (canSpawnItemAtPos(spawnPos, map, mapWidth, mapHeight))
				{
					string randomItemName = ITEMS_LIST[XORRandom(ITEMS_LIST.length())];

					CBitStream bt;
					bt.write_string( randomItemName );
					bt.write_Vec2f( spawnPos );
					this.SendCommand(this.getCommandID("spawn item"), bt);

					u16 itemCounter = this.get_u16("item counter");
					itemCounter++;
					this.set_u16("item counter", itemCounter);

					itemSpawned = true;
				}
			}
			else
			{
				// update item counter on intervals
	  			CBlob@[] itemBlobs;
				getBlobsByTag("Item", @itemBlobs);
				this.set_u16("item counter", itemBlobs.length);

				this.set_u16("item timer", SPAWN_INTERVAL);
			}
		}

		if (itemSpawned)
		{
			this.set_u16("item timer", SPAWN_INTERVAL);
		}
		else if (itemTimer > 0)
		{
			itemTimer--;
			this.set_u16("item timer", itemTimer);
		}
	}
}

bool canSpawnItemAtPos(Vec2f spawnPos, CMap@ map, u16 mapWidth, u16 mapHeight)
{
	Tile tile = map.getTile(spawnPos);
	if (!map.isTileSolid(tile))
	{
		Vec2f endPos = Vec2f(spawnPos.x, spawnPos.y + MAX_SPAWN_HEIGHT);
		bool itemOverGround = map.rayCastSolidNoBlobs(spawnPos, endPos);

		return itemOverGround;
	}

	return false;
}

void onCommand( CRules@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("spawn item"))
	{
		string blobName = params.read_string();
		Vec2f spawnPos = params.read_Vec2f();

		if (getNet().isServer())
		{
			CBlob @blob = server_CreateBlob(blobName, -1, spawnPos);
			if (blob !is null)
			{
				blob.Tag("Item");

				if (blob.getName() == "bomb")
				{
					if (XORRandom(2) == 0)
					{
						blob.Tag("activated");
					}
				}
			}
		}
		
		if (getNet().isClient())
		{
			ParticleAnimated("sparkle3.png", spawnPos, Vec2f(0, 0), XORRandom(360), 1.0f, 6, 0.0f, true);
			makeSparks(spawnPos, 20);

			Sound::Play("itemland.ogg", spawnPos, 2.0f);
		}
	}
}

Random _sprk_r();
void makeSparks(Vec2f pos, int amount)
{
	if ( !getNet().isClient() )
		return;
		
	for (int i = 0; i < amount; i++)
    {
        Vec2f vel(_sprk_r.NextFloat() * 4.0f, 0);
        vel.RotateBy(_sprk_r.NextFloat() * 360.0f);

        CParticle@ p = ParticlePixel( pos, vel, SColor( 255, 200+_sprk_r.NextRanged(55), 200+_sprk_r.NextRanged(55), 255), true );
        if(p is null) return; //bail if we stop getting particles
		
		p.gravity = Vec2f(0.0f,0.1f);
        p.timeout = 20 + _sprk_r.NextRanged(20);
        p.scale = 1.0f + _sprk_r.NextFloat();
        p.damping = 0.95f;
    }
}