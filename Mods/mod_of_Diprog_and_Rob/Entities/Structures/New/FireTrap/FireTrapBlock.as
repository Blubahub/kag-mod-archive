void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed( false );
	this.SetLight( true );
	this.SetLightRadius( 18.0f );
	this.SetLightColor( SColor(255, 255, 240, 171 ) );
	this.Tag("place norotate");
	this.Tag("blocks water");
	
	this.set_TileType("background tile", CMap::tile_castle_back);
}

void onTick( CBlob@ this )
{
	CSprite@ sprite = this.getSprite();
	if (this.isInWater()) this.SetLight( false );
		else this.SetLight( true );
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{	
	return true;
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
	CMap@ map = getMap();
	if (map !is null)	
	{
		if (blob !is null && this.getTeamNum() != blob.getTeamNum() && blob.hasTag("flesh") && this.isInWater() != true)
		{	
			for (int doFire = 0; doFire <= 16; doFire = doFire + 8)
			{
				map.server_setFireWorldspace(Vec2f(blob.getPosition().x, blob.getPosition().y + doFire), true);
				map.server_setFireWorldspace(Vec2f(blob.getPosition().x, blob.getPosition().y - doFire), true);
				map.server_setFireWorldspace(Vec2f(blob.getPosition().x + doFire, blob.getPosition().y), true);
				map.server_setFireWorldspace(Vec2f(blob.getPosition().x - doFire, blob.getPosition().y), true);
				map.server_setFireWorldspace(Vec2f(blob.getPosition().x + doFire, blob.getPosition().y + doFire), true);
				map.server_setFireWorldspace(Vec2f(blob.getPosition().x - doFire, blob.getPosition().y - doFire), true);
				map.server_setFireWorldspace(Vec2f(blob.getPosition().x + doFire, blob.getPosition().y - doFire), true);
				map.server_setFireWorldspace(Vec2f(blob.getPosition().x - doFire, blob.getPosition().y + doFire), true);
			}
		}
			
	}
}

void onEndCollision( CBlob@ this, CBlob@ blob )
{
	CMap@ map = getMap();
	if (map !is null)	
	{
		if (blob !is null && this.getTeamNum() != blob.getTeamNum() && blob.hasTag("flesh") && this.isInWater() != true)
		{	
			for (int doFire = 0; doFire <= 16; doFire = doFire + 8)
			{
				map.server_setFireWorldspace(Vec2f(blob.getPosition().x, blob.getPosition().y + doFire), true);
				map.server_setFireWorldspace(Vec2f(blob.getPosition().x, blob.getPosition().y - doFire), true);
				map.server_setFireWorldspace(Vec2f(blob.getPosition().x + doFire, blob.getPosition().y), true);
				map.server_setFireWorldspace(Vec2f(blob.getPosition().x - doFire, blob.getPosition().y), true);
				map.server_setFireWorldspace(Vec2f(blob.getPosition().x + doFire, blob.getPosition().y + doFire), true);
				map.server_setFireWorldspace(Vec2f(blob.getPosition().x - doFire, blob.getPosition().y - doFire), true);
				map.server_setFireWorldspace(Vec2f(blob.getPosition().x + doFire, blob.getPosition().y - doFire), true);
				map.server_setFireWorldspace(Vec2f(blob.getPosition().x - doFire, blob.getPosition().y + doFire), true);
			}
		}
			
	}
}