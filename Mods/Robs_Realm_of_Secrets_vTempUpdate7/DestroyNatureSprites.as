void DestroyNatureSprites()
{
	string world_sprite = "world_ded.png";
	getMap().CreateTileMap(0, 0, 8.0f, world_sprite);

	getMap().CreateSky(color_black, Vec2f(1.0f, 1.0f), 200, "cloud", 0);
	getMap().CreateSkyGradient("skygradient_ded.png");

	getMap().AddBackground("BackgroundPlains_ded.png", Vec2f(0.0f, -18.0f), Vec2f(0.3f, 0.3f), color_white);
	getMap().AddBackground("BackgroundTrees_ded.png", Vec2f(0.0f,  -5.0f), Vec2f(0.4f, 0.4f), color_white);
	getMap().AddBackground("BackgroundCastle_ded.png", Vec2f(0.0f, 0.0f), Vec2f(0.6f, 0.6f), color_white);
}