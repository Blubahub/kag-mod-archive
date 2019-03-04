void onTick( CBlob@ this )
{
	CMap@ map = getMap();
	Vec2f pos = this.getPosition();
	if (pos.x < map.tilesize || pos.x > (map.tilemapwidth - 1) * map.tilesize || pos.y < map.tilesize || pos.y > (map.tilemapheight - 1) * map.tilesize)
	{
		Sound::Play("coinpick.ogg", pos, 25.0f, 0.25f);
		
		if (!getNet().isServer())
		{
			return;
		}

		this.server_Die();
	}
}