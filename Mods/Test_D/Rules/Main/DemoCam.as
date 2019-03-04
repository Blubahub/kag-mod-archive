void onTick(CRules@ this)
{
	CMap@ map = getMap();
	CCamera@ camera = getCamera();
	if (map is null || camera is null) return;

	camera.setPosition(Vec2f(map.tilesize * map.tilemapwidth * 0.5f, map.tilesize * map.tilemapheight * 0.5f));
}
