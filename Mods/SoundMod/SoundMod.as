shared class SoundMod
{
	int tunelength;
	int tunetimer;
	bool playing_tune;
	bool allow_restarts;
	string tunesfolder;
	string current_tune;
	string[] tunes;
	int[] tunedurations;

	SoundMod()
	{
		tunelength = 0;
		tunetimer = 0;
		playing_tune = false;
		allow_restarts = false;
		tunesfolder = "../Mods/SoundMod/Tunes/";
		current_tune = "";
	}

	void Reset()
	{
		tunelength = 0;
		tunetimer = 0;
		playing_tune = false;
		current_tune = "";
	}

	void addTune(string tune, int duration)
	{
		tunes.push_back(tune);
		tunedurations.push_back(duration);
	}

	void removeTune(string tune)
	{
		for (int i = 0; i < tunes.length; i++)
		{
			if (tunes[i] == tune)
			{
				if (tunes[i] == current_tune)
				{
					//Skip();
				}

				tunes.removeAt(i);
				tunedurations.removeAt(i);
			}
		}
	}

	void tuneTimer()
	{
		if (!playing_tune) return;

		tunetimer += 1;

		if (tunetimer == tunelength)
		{
			Reset();
		}
	}

	void playTune(string tune)
	{
		for (int i = 0; i < tunes.size(); i++)
		{
			if (tunes[i] == tune && !playing_tune)
			{
				current_tune = tune;
				tunelength = tunedurations[i];
				playing_tune = true;
				Sound::Play(tunesfolder + tune);
			}
		}
	}

	bool isTunePlaying()
	{
		return playing_tune;
	}
};