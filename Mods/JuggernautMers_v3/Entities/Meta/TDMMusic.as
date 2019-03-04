// Game Music

#define CLIENT_ONLY

enum GameMusicTags
{
	world_intro,
	world_home,
	world_calm,
	world_battle,
	world_battle_2,
	world_outro,
	world_quick_out,
};

void onInit(CBlob@ this)
{
	CMixer@ mixer = getMixer();
	if (mixer is null)
		return;

	this.set_bool("initialized game", false);
}

void onTick(CBlob@ this)
{
	CMixer@ mixer = getMixer();
	if (mixer is null)
		return;

	if (s_gamemusic && s_musicvolume > 0.0f)
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
	mixer.AddTrack("../Mods/JuggernautMusic/Sadistic.ogg",world_battle);
	mixer.AddTrack("../Mods/JuggernautMusic/SmellsLikeBurningCorpse.ogg",world_battle);
	mixer.AddTrack("../Mods/JuggernautMusic/LetsKillAtWill.ogg",world_battle);
	mixer.AddTrack("../Mods/JuggernautMusic/AimShootKill.ogg",world_battle);
	mixer.AddTrack("../Mods/JuggernautMusic/BetweenLevels.ogg",world_battle);
	mixer.AddTrack("../Mods/JuggernautMusic/ByeByeAmericanPie.ogg",world_battle);
	mixer.AddTrack("../Mods/JuggernautMusic/IntoTheBeastsBelly.ogg",world_battle);
}

uint timer = 0;

void GameMusicLogic(CBlob@ this, CMixer@ mixer)
{
	if (mixer is null)
		return;

	//warmup
	CRules @rules = getRules();

	if(mixer.getPlayingCount()==0) {
		mixer.FadeInRandom(world_battle , 0.0f);
	}
}
