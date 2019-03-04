
#include "EmotesCommon.as";

void onInit( CBlob@ this )
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
}

void onTick(CBlob@ this)
{
	CControls@ controls = getControls();
	if (controls.isKeyJustPressed( KEY_KEY_1 )) {
		set_emote(this,Emotes::attn);
	}
	else if (controls.isKeyJustPressed( KEY_KEY_2 )) {
		set_emote(this,Emotes::smile);
	}
	else if (controls.isKeyJustPressed( KEY_KEY_3 )) {
		set_emote(this,Emotes::frown);
	}
	else if (controls.isKeyJustPressed( KEY_KEY_4 )) {
		set_emote(this,Emotes::mad);
	}
	else if (controls.isKeyJustPressed( KEY_KEY_5 )) {
		set_emote(this,Emotes::laugh);
	}
	else if (controls.isKeyJustPressed( KEY_KEY_6 )) {
		set_emote(this,Emotes::wat);
	}
	else if (controls.isKeyJustPressed( KEY_KEY_7 )) {
		set_emote(this,Emotes::troll);
	}
	else if (controls.isKeyJustPressed( KEY_KEY_8 )) {
		set_emote(this,Emotes::disappoint);
	}
	else if (controls.isKeyJustPressed( KEY_KEY_9 )) {
		set_emote(this,Emotes::ladder);
	}
}
