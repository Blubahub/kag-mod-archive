#define SERVER_ONLY

const f32 meteor_interval = 300 * 30;
f32 meteor_time;
void onRestart(CRules@ this)
{
	meteor_time = meteor_interval + getGameTime();
}
void onTick(CRules@ this)
{
	if (!this.isWarmup())
	{
		f32 time_left = (meteor_time - getGameTime()) / 30;
		this.SetGlobalMessage("Meteor drops in " + Maths::Roundf(time_left) + " secs");
	}
	if (getGameTime() >= meteor_time)
	{
		CPlayer@ player = getPlayer(XORRandom(getPlayersCount()));
		if (player !is null)
		{
			CBlob@ blob = player.getBlob();
			while(blob is null)
			{
				@player = getPlayer(XORRandom(getPlayersCount()));
				@blob = player.getBlob();
			}
				
			if (blob !is null)
			{
				Vec2f pos = blob.getPosition();
				CMap@ map = getMap();
				const f32 mapWidth = map.tilemapwidth * map.tilesize;
				CBlob@ meteor = server_CreateBlob( "meteor", -1, Vec2f(pos.x, -mapWidth));
				
			}
			
		}
		meteor_time = getGameTime() + meteor_interval;
	}
}