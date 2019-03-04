const string layername = "parachute";

void AddParachute(CBlob@ this)
{
	if (!getNet().isServer())
		return;

    this.Tag("parachute");
    this.Sync("parachute", true);
}

void AddParachuteToBlobs( const string &in name )
{
	if (!getNet().isServer())
		return;

    CBlob@[] blobs;
    if (getBlobsByName( name, @blobs ))
    {
        for (uint step = 0; step < blobs.length; ++step)
        {
        	AddParachute( blobs[step] );
        }
    }
}

void RemoveParachute(CBlob@ this)
{
	if (!getNet().isServer())
		return;

	this.Untag("parachute");
	this.Sync("parachute", true);
}

Vec2f getSkyPos()
{
    return Vec2f(getMap().tilemapwidth * getMap().tilesize * 0.45f, 0.0f);
}