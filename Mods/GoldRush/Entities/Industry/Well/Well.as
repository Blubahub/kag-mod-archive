void onInit( CBlob@ this )
{	 
	this.set_TileType("background tile", CMap::tile_castle_back);
	//this.getSprite().getConsts().accurateLighting = true;
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
}
