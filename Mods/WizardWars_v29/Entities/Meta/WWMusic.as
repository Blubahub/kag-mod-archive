// Game Music

u8 numSongs = 11;

enum GameMusicTags
{
	CBoyarde,
	MarioKart,
	LogHorizon1,
	LogHorizon2,
	Corneria,
	Cornered,
	Guile,
	KingDedede,
	MetaKnight,
	MuteCity,
	Targets
};

void onInit(CBlob@ this)
{
	this.addCommandID("play song"); 

	this.Sync("current song", true);

	CMixer@ mixer = getMixer();
	if (mixer is null)
		return;

	this.set_bool("initialized game", false);
	
	if (mixer.getPlayingCount() == 0)
	{
		mixer.FadeInRandom(this.get_u8("current song"), 0.0f);
	}
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

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if( cmd == this.getCommandID("play song") )
    {
		u8 song;	
		song = params.read_u8();	
		this.set_u8("current song", song);
		this.Sync("current song", true);
		
		if ( !isDirector(getLocalPlayer()) )	//don't play for director to prevent song spamming
		{
			CMixer@ mixer = getMixer();
			if (mixer is null)
				return;		
				
			mixer.FadeOutAll(0.0f, 1.0f);
			mixer.FadeInRandom(song , 0.0f);
		}
		printf("Next song!");
	}
}

//sound references with tag
void AddGameMusic(CBlob@ this, CMixer@ mixer)
{
	if (mixer is null)
		return;

	this.set_bool("initialized game", true);
	mixer.ResetMixer();
	mixer.AddTrack("../Mods/WizardWars_Music/Sounds/Music/CBoyarde.ogg", CBoyarde);
	mixer.AddTrack("../Mods/WizardWars_Music/Sounds/Music/MarioKart.ogg", MarioKart);
	mixer.AddTrack("../Mods/WizardWars_Music/Sounds/Music/LogHorizon1.ogg", LogHorizon1);
	mixer.AddTrack("../Mods/WizardWars_Music/Sounds/Music/LogHorizon2.ogg", LogHorizon2);
	mixer.AddTrack("../Mods/WizardWars_Music/Sounds/Music/Corneria.ogg", Corneria);
	mixer.AddTrack("../Mods/WizardWars_Music/Sounds/Music/Cornered.ogg", Cornered);
	mixer.AddTrack("../Mods/WizardWars_Music/Sounds/Music/Guile.ogg", Guile);
	mixer.AddTrack("../Mods/WizardWars_Music/Sounds/Music/KingDedede.ogg", KingDedede);
	mixer.AddTrack("../Mods/WizardWars_Music/Sounds/Music/MetaKnight.ogg", MetaKnight);
	mixer.AddTrack("../Mods/WizardWars_Music/Sounds/Music/MuteCity.ogg", MuteCity);
	mixer.AddTrack("../Mods/WizardWars_Music/Sounds/Music/Targets.ogg", Targets);
}

uint timer = 0;

void GameMusicLogic(CBlob@ this, CMixer@ mixer)
{
	if (mixer is null)
		return;

	//warmup
	CRules @rules = getRules();
	if ( isDirector(getLocalPlayer()) )		//music directed by the first player only
	{	
		if (rules.isWarmup() || rules.isMatchRunning())
		{
			if (mixer.getPlayingCount() == 0)
			{
				u8 song = XORRandom(numSongs);
				CBitStream bt;
				bt.write_u8( song );	
				this.SendCommand( this.getCommandID("play song"), bt );
				mixer.FadeInRandom(song , 0.0f);
			}
		}
		else
		{
			mixer.FadeOutAll(0.0f, 1.0f);
		}
	}
}

bool isDirector( CPlayer@ player )
{
	return ( player is getPlayer(0) );
}
