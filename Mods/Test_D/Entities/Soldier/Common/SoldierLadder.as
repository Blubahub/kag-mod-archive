void onTick(CBlob@ this)
{
	CMap@ map = this.getMap();
	ShapeVars@ shapeVars = this.getShape().getVars();
	Vec2f pos = this.getPosition();
	f32 radius = this.getRadius();
	shapeVars.onladder = map.hasTileFlag(map.getTileOffset(pos + Vec2f(-radius * 0.25f, 0.0f)), Tile::LADDER) ||
	                     map.hasTileFlag(map.getTileOffset(pos + Vec2f(radius * 0.25f, 0.0f)), Tile::LADDER) ||
	                     map.hasTileFlag(map.getTileOffset(pos + Vec2f(-radius * 0.25f, radius * 0.9f)), Tile::LADDER) ||
	                     map.hasTileFlag(map.getTileOffset(pos + Vec2f(radius * 0.25f, radius * 0.9f)), Tile::LADDER);
}