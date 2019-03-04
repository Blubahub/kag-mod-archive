// common script for blocks included with BunnyFection

void onInit(CBlob@ this)
{
	this.getSprite().getConsts().accurateLighting = true;
	this.Tag( "block" );
	this.Tag( "medium weight" );
	this.getShape().SetRotationsAllowed(false);
    if ( (this.getName() == "bf_blockwood") || (this.getName() == "bf_doorwood") )
    {
        this.set_TileType("background tile", CMap::tile_wood_back);
    }
    else if ( (this.getName() == "bf_blockstone") || (this.getName() == "bf_doorstone") || (this.getName() == "bf_trapdoor") || (this.getName() == "bf_trapspike") )
    {
        this.set_TileType("background tile", CMap::tile_castle_back);
    }
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
	if ( !this.isAttached() && !this.getShape().isStatic() )
		this.server_Die();
}