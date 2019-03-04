//This Edited File was Created by Bunnie, ask for permission before using it.
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
	else if (controls.isKeyJustPressed( KEY_KEY_0 )) {
		set_emote(this,Emotes::skull);
	}
	else if (controls.isKeyJustPressed( KEY_NUMPAD1 )) {
		set_emote(this,Emotes::knight);
	}
	else if (controls.isKeyJustPressed( KEY_NUMPAD2 )) {
		set_emote(this,Emotes::archer);
	}
	else if (controls.isKeyJustPressed( KEY_NUMPAD3 )) {
		set_emote(this,Emotes::builder);
	}
	else if (controls.isKeyJustPressed( KEY_NUMPAD4 )) {
		set_emote(this,Emotes::fire);
	}
	else if (controls.isKeyJustPressed( KEY_NUMPAD5 )) {
		set_emote(this,Emotes::blueflag);
	}
	else if (controls.isKeyJustPressed( KEY_NUMPAD6 )) {
		set_emote(this,Emotes::redflag);
	}
	else if (controls.isKeyJustPressed( KEY_NUMPAD7 )) {
		set_emote(this,Emotes::wall);
	}
}
