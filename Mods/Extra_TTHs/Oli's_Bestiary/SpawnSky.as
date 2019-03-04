#define SERVER_ONLY

const int min_bird = 11;
const string bird_name = "bird";

void onTick(CRules@ this)
{
	spawnSky(min_bird, bird_name);
}
void spawnSky(int min_sky, string sky_name)
{
	if (getGameTime() % 29 != 0) return;
	if (XORRandom(70) != 0) return; //much slower spawn rate, birds annoy ppl and they want to be able to kill them without having them spawn back instantaneously:LP

	CMap@ map = getMap();
	if (map is null || map.tilemapwidth < 2) return; //failed to load map?
	//spawn from nowhere
	CBlob@[] sky;
	getBlobsByName(sky_name, @sky);

	if(getNet().isServer() && sky.length < min_sky)
	{
		server_CreateBlob(sky_name, -1, Vec2f(XORRandom(map.tilemapwidth), 5));
	}
}