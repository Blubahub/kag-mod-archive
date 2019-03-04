// BF_RootStatic script

void onInit(CBlob@ this)
{
	this.Tag( "flora" );
    CSprite@ sprite = this.getSprite();
    CMap@ map = getMap();
    Vec2f pos = this.getPosition();
    Tile tile_above = map.getTile(pos + Vec2f( 0, -8 ));
    if ((map.isTileGround(tile_above.type)) || (map.isTileGrass(tile_above.type)) || (map.isTileStone(tile_above.type)))
    {
        sprite.SetFrameIndex(2 + XORRandom(3));
    }
    else
    {
        sprite.SetFrameIndex(XORRandom(2));
        sprite.SetZ(-50.0f);
    }
}