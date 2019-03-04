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
mixer.AddTrack("../Mods/Kotori/SakuraCherry.ogg", world_home);
mixer.AddTrack("../Mods/Kotori/TempleGuardians.ogg", world_home);
mixer.AddTrack("../Mods/Kotori/AsianPirates.ogg", world_home);
mixer.AddTrack("../Mods/Kotori/NightattheCastle.ogg", world_home);
mixer.AddTrack("../Mods/Kotori/AncientWharf.ogg", world_home);
mixer.AddTrack("../Mods/Kotori/Bushido.ogg", world_home);
mixer.AddTrack("../Mods/Kotori/Shogun.ogg", world_home);
mixer.AddTrack("../Mods/Kotori/SamuraiWarrior.ogg", world_home);
mixer.AddTrack("../Mods/Kotori/ImperialDynasty.ogg", world_home);


}

uint timer = 0;

void GameMusicLogic(CBlob@ this, CMixer@ mixer)
{
	if (mixer is null)
		return;

	//warmup
	CRules @rules = getRules();

	if (rules.isWarmup())
	{
		if (mixer.getPlayingCount() == 0)
		{
			mixer.FadeInRandom(world_home , 0.0f);
		}
	}
	else if (rules.isMatchRunning()) //battle music
	{
		if (mixer.getPlayingCount() == 0)
		{
			mixer.FadeInRandom(world_battle , 0.0f);
		}
	}
	else
	{
		mixer.FadeOutAll(0.0f, 1.0f);
	}
}
