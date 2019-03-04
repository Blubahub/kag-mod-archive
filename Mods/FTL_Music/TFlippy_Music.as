// Game Music

#define CLIENT_ONLY

enum GameMusicTag
{
	ftl_scary,
	ftl_battle,
	ftl_peace
};

void onInit(CBlob@ this)
{
	CMixer@ mixer = getMixer();
	if (mixer is null)
		return;

	mixer.ResetMixer();
	this.set_bool("initialized game", false);
}

void onTick(CBlob@ this)
{
	CMixer@ mixer = getMixer();
	if (mixer is null)
		return;

	if (s_soundon != 0 && s_musicvolume > 0.0f)
	{
		if (!this.get_bool("initialized game"))
		{
			AddGameMusic(this, mixer);
		}

		GameMusicLogic(this, mixer);
	}
	else
	{
		mixer.FadeOutAll(0.0f, 2.0f);
	}
}

//sound references with tag
void AddGameMusic(CBlob@ this, CMixer@ mixer)
{
	if (mixer is null)
		return;

	this.set_bool("initialized game", true);
	
	mixer.ResetMixer();
	mixer.AddTrack("../Mods/FTL_Music/FTL_Music/FTL_Battle_0.ogg", ftl_battle);
	mixer.AddTrack("../Mods/FTL_Music/FTL_Music/FTL_Battle_1.ogg", ftl_battle);
	mixer.AddTrack("../Mods/FTL_Music/FTL_Music/FTL_Battle_2.ogg", ftl_battle);
	mixer.AddTrack("../Mods/FTL_Music/FTL_Music/FTL_Battle_3.ogg", ftl_battle);
	
	mixer.AddTrack("../Mods/FTL_Music/FTL_Music/FTL_Peace_0.ogg", ftl_peace);
	mixer.AddTrack("../Mods/FTL_Music/FTL_Music/FTL_Peace_1.ogg", ftl_peace);
	mixer.AddTrack("../Mods/FTL_Music/FTL_Music/FTL_Peace_2.ogg", ftl_peace);
	mixer.AddTrack("../Mods/FTL_Music/FTL_Music/FTL_Peace_3.ogg", ftl_peace);
	
	mixer.AddTrack("../Mods/FTL_Music/FTL_Music/FTL_Scary_0.ogg", ftl_scary);
	mixer.AddTrack("../Mods/FTL_Music/FTL_Music/FTL_Scary_1.ogg", ftl_scary);
	mixer.AddTrack("../Mods/FTL_Music/FTL_Music/FTL_Scary_2.ogg", ftl_scary);
	mixer.AddTrack("../Mods/FTL_Music/FTL_Music/FTL_Scary_3.ogg", ftl_scary);
}

void GameMusicLogic(CBlob@ this, CMixer@ mixer)
{
	if (mixer is null || !s_gamemusic)
		return;

	CRules @rules = getRules();
	CBlob @blob = getLocalPlayerBlob();
	if (blob is null)
	{
		mixer.FadeOutAll(0.0f, 6.0f);
		return;
	}

	CMap@ map = blob.getMap();
	if (map is null)
		return;

	GameMusicTag chosen;
	Vec2f pos = blob.getPosition();

	bool indoor = false;
	bool friendly = false;
	bool battle = false;
	u8 team = blob.getTeamNum();
	
	CBlob@[] blobs;
	if (map.getBlobsInRadius(pos, 128, @blobs))
	{
		for (u32 i = 0; i < blobs.length; i++)
		{
			indoor = blobs[i].hasTag("room");
			if (indoor) 
			{
				friendly = blobs[i].getTeamNum() == team;
				if (friendly) break;
			}
		}
	}
	
	CBlob@[] turrets;
	if (getBlobsByName("turret", @turrets))
	{
		for (u32 i = 0; i < turrets.length; i++)
		{
			battle = turrets[i].getTeamNum() != team && turrets[i].get_u16("gun_type") != 0;
			if (battle) break;
		}
	}

	if (battle) chosen = ftl_battle;
	else if (indoor && friendly) chosen = ftl_peace;
	else chosen = ftl_scary;

	if (!mixer.isPlaying(chosen))
	{
		// print("Indoor: " + indoor + "; Battle: " + battle + "; Friendly: " + friendly + "; Current type: " + chosen);
	
		mixer.FadeOutAll(0.0f, 5.0);
		mixer.FadeInRandom(chosen, 5.0f);
	}
}