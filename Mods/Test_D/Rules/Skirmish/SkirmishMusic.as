#define CLIENT_ONLY

#include "GamemodeCommon.as"

bool _stateChanged = false;

void onStateChange(CRules@ this, const u8 oldState)
{
	CMixer@ mixer = getMixer();
	const u8 state = this.getCurrentState();

	if (this.hasTag("expo mode")){
		return;
	}

	if (state == GAME_OVER)
	{
		if (isScoreReached(this.get_u32("score_cap")))
		{
			mixer.FadeOutAll(0.0f, 1.0f);
		}
		else
		{
			mixer.FadeOutAll(0.0f, 5.0f);
		}
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

		if (mixer.getPlayingCount() == 0 && this.hasTag("expo mode"))
		{
			mixer.AddTrack("Sounds/Music/TR01-Theme.ogg", 1);
			mixer.FadeInRandom(1, 0.5f);
		}
		else if (_stateChanged && mixer.getPlayingCount() == 0)
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
				// play jingle
				int count, deadcount;
				CalcPlayerCounts(count, deadcount);

				if (isScoreReached(this.get_u32("score_cap")))
				{
					mixer.ResetMixer();
					Sound::Play("scores-jazz.ogg");
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
