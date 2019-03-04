void onInit( CBlob@ this )
{
	this.getShape().SetRotationsAllowed( false );
    this.SetLight( true );
    this.SetLightRadius( 64.0f );
    this.SetLightColor( SColor(255, 255, 240, 171 ) );
    this.getShape().getConsts().mapCollisions = false;

    this.Tag("dont deactivate");
    this.Tag("fire source");
    this.set_TileType("background tile", CMap::tile_wood_back);

}

void onTick( CBlob@ this )
{
    CMap@ map = getMap();
    Vec2f pos = this.getPosition();
    const f32 tilesize = map.tilesize;
   
    if (tileCheck( map, pos + Vec2f(tilesize, 0.0f) ) == true)
    {
        this.getSprite().SetAnimation( "fire_right");
    }
    else if (tileCheck( map, pos + Vec2f(-tilesize, 0.0f) ) == true )
    {
        this.getSprite().SetAnimation( "fire_left");
    }
}

bool tileCheck( CMap@ map, Vec2f pos )
{
    TileType t = map.getTile(pos).type;
    
	if (map.isTileSolid(t))
	{
		return true;
	}
    else{
        return false;
    }
}

bool check_background( Tile tile ){
    return getMap().isTileBackground(tile);
}

