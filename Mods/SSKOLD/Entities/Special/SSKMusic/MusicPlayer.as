// Game Music

#include "MusicCommon.as"

#define CLIENT_ONLY

u16 PLAY_BUFFER = 10;

void onInit(CRules@ this)
{
	this.set_u16("music play buffer", 0);
	this.set_s8("song index", -1);
	this.Sync("song index", false);

	this.addCommandID("play song");
	
	AddGameMusic(this);

	CMixer@ mixer = getMixer();
	if (mixer !is null)
	{
		// play current song if player just joined
		s8 songIndex = this.get_s8("song index");
		if (songIndex >= 0)
		{
			if (!mixer.isPlaying(songIndex))
			{
				mixer.StopAll();
				//mixer.PlayRandom(songIndex);

				client_AddToChat( "Jukebox now playing: " + Music::songs[songIndex].description, SColor(255,130,40,190) );

				this.set_bool("isMusicOn", false);
				this.set_u16("music play buffer", PLAY_BUFFER);
			}
		}
	}
}

void onRestart(CRules@ this)
{
	this.set_bool("isMusicOn", false);
	this.set_u16("music play buffer", PLAY_BUFFER);
}

void onTick(CRules@ this)
{
	CMixer@ mixer = getMixer();
	if (mixer is null)
		return;

	if (s_gamemusic && s_musicvolume > 0.0f)
	{
		GameMusicLogic(this, mixer);
	}
	else
	{
		mixer.StopAll();

		// this bool used to determine that a song should only start from begining when music is re-enabled OR on init()
		this.set_bool("isMusicOn", false);
	}
}

//sound references with tag
void AddGameMusic(CRules@ this)
{
	CMixer@ mixer = getMixer();
	if (mixer is null)
		return;

	mixer.ResetMixer();
	for (uint i = 0; i < Music::songs.length; ++i)
	{
		mixer.AddTrack(Music::songs[i].fileHandle, i);
	}
}

void GameMusicLogic(CRules@ this, CMixer@ mixer)
{
	if (mixer is null)
		return;

	// game over
	if (this.isGameOver())
	{
		mixer.FadeOutAll(0.0f, 4.0f);
	}
	else
	{
		s8 songIndex = this.get_s8("song index");
		if (songIndex >= 0 && !this.get_bool("isMusicOn"))
		{
			u16 playBuffer = this.get_u16("music play buffer");
			if (playBuffer <= 0)
			{
				//mixer.StopAll();
				AddGameMusic(this);
				mixer.PlayRandom(songIndex);

				if (mixer.isPlaying(songIndex))
				{
					this.set_bool("isMusicOn", true);
				}				
			}
			else
			{
				playBuffer--;
				this.set_u16("music play buffer", playBuffer);
			}
		}
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("play song"))
	{
		u8 randSongIndex = params.read_u8();

		CMixer@ mixer = getMixer();
		if (mixer != null)
		{
			mixer.StopAll();
			//mixer.PlayRandom(randSongIndex);

			client_AddToChat( "Jukebox now playing: " + Music::songs[randSongIndex].description, SColor(255,130,40,190) );

			this.set_s8("song index", randSongIndex);
			this.set_bool("isMusicOn", false);
			this.set_u16("music play buffer", PLAY_BUFFER);
		}
	}
}
