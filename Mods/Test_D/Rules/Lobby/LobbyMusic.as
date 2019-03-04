#define CLIENT_ONLY

#include "GamemodeCommon.as"

void onTick(CRules@ this)
{
	CMixer@ mixer = getMixer();
	if (isMusicOn())
	{
		const u8 state = this.getCurrentState();

		string music = this.get_string("lobby_music");

		if (music == "")
		{
			mixer.ResetMixer(); //we need to shred the tags as well actually
		}
		else if (music != this.get_string("last_lobby_music"))
		{
			mixer.FadeOutAll(0.0f, 2.0f);
			mixer.AddTrack(music, 0);
			mixer.FadeInRandom(0, 1.5f);
		}
		this.set_string("last_lobby_music", music);

		if (mixer.getPlayingCount() == 0 && music != "") // play infinitely
		{
			mixer.AddTrack(music, 0);
			mixer.FadeInRandom(0, 1.5f);
			//this.set_string("lobby_music", "");
			//this.set_string("last_lobby_music", "");
		}
	}
	else
	{
		mixer.ResetMixer();
		mixer.StopAll();
	}
}
