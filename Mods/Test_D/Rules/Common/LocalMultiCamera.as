#define CLIENT_ONLY

void onTick(CRules@ this)
{
	CCamera@ camera = getCamera();
	if(camera !is null)	
	{

		CMap@ map = getMap();
		Vec2f campos( map.tilemapwidth * map.tilesize * 0.5f, map.tilemapheight * map.tilesize * 0.5f);
		camera.setPosition( campos );
		camera.targetDistance = 0.5f;
		Sound::SetScale(0.5f);
	}
}