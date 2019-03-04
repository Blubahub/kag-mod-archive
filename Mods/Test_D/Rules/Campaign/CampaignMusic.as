#define CLIENT_ONLY

#include "GamemodeCommon.as"
#include "CampaignCommon.as"

bool _stateChanged = false;

void onStateChange(CRules@ this, const u8 oldState)
{
	CMixer@ mixer = getMixer();
	const u8 state = this.getCurrentState();

	if (state == GAME_OVER)
	{
		Campaign::Data@ data = Campaign::getCampaign(this);
		if (Campaign::isSeriesEnded(data))
		{
			mixer.FadeOutAll(0.0f, 1.0f);
		}
		else
		{
			mixer.FadeOutAll(0.0f, 5.0f);
		}

		Sound::Play("CrashCymbal");
	}

	if (state == WARMUP || state == GAME_OVER)
	{
		_stateChanged = true;
	}
}

void onTick(CRules@ this)
{
	CMixer@ mixer = getMixer();
	if (isMusicOn())
	{
		const u8 state = this.getCurrentState();

		if (_stateChanged && mixer.getPlayingCount() == 0)
		{
			if (state == WARMUP)
			{
				mixer.ResetMixer();

				string biome = this.get_string("biome");

				if (biome == "trenches")
				{
					mixer.AddTrack("Sounds/Music/TR02-Trenches.ogg", 0);
				}
				else if (biome == "city")
				{
					mixer.AddTrack("Sounds/Music/TR06-City.ogg", 0);
				}
				else if (biome == "forest")
				{
					mixer.AddTrack("Sounds/Music/TR05-Forest.ogg", 0);
				}
				else if (biome == "desert")
				{
					mixer.AddTrack("Sounds/Music/TR03-Desert.ogg", 0);
				}
				else if (biome == "swamp")
				{
					mixer.AddTrack("Sounds/Music/TR04-Swamp.ogg", 0);
				}
				else if (biome == "village")
				{
					mixer.AddTrack("Sounds/Music/TR07-Village.ogg", 0);
				}
				else
				{
					mixer.AddTrack("Sounds/Music/TR01A-ThemeNoloop.ogg", 0);
				}

				mixer.FadeInRandom(0, 0.5f);
				_stateChanged = false;
			}
			else if (state == GAME_OVER)
			{
				Campaign::Data@ data = Campaign::getCampaign(this);
				if (Campaign::isSeriesEnded(data))
				{
					mixer.ResetMixer();
					Sound::Play("scores-jazz.ogg");
				}
				else
				{
				}
				_stateChanged = false;
			}
		}
	}
	else
	{
		mixer.StopAll();
	}
}
