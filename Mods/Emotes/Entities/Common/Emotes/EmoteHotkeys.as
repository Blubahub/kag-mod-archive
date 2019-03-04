
#include "EmotesCommon.as";

bool init = false;
u8 emote_1 = 0;
u8 emote_2 = 0;
u8 emote_3 = 0;
u8 emote_4 = 0;
u8 emote_5 = 0;
u8 emote_6 = 0;
u8 emote_7 = 0;
u8 emote_8 = 0;
u8 emote_9 = 0;
u8 emote_10 = 0;
u8 emote_11 = 0;
u8 emote_12 = 0;
u8 emote_13 = 0;
u8 emote_14 = 0;
u8 emote_15 = 0;
u8 emote_16 = 0;
u8 emote_17 = 0;
u8 emote_18 = 0;
u8 emote_19 = 0;
u8 emote_20 = 0;

const string emote_config_file = "EmoteBindings.cfg";

void onInit(CBlob@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";

	if (!init)
	{
		init = true; 	//only load the cfg once to avoid
		//too much file access!

		ConfigFile cfg = ConfigFile();
		cfg.loadFile(emote_config_file);

		emote_1 = cfg.read_u8("emote_1", Emotes::attn);
		emote_2 = cfg.read_u8("emote_2", Emotes::smile);
		emote_3 = cfg.read_u8("emote_3", Emotes::frown);
		emote_4 = cfg.read_u8("emote_4", Emotes::mad);
		emote_5 = cfg.read_u8("emote_5", Emotes::laugh);
		emote_6 = cfg.read_u8("emote_6", Emotes::wat);
		emote_7 = cfg.read_u8("emote_7", Emotes::troll);
		emote_8 = cfg.read_u8("emote_8", Emotes::disappoint);
		emote_9 = cfg.read_u8("emote_9", Emotes::ladder);
		emote_10 = cfg.read_u8("emote_10", Emotes::heart);
		emote_11 = cfg.read_u8("emote_11", Emotes::blueflag);
		emote_12 = cfg.read_u8("emote_12", Emotes::redflag);
		emote_13 = cfg.read_u8("emote_13", Emotes::left);
		emote_14 = cfg.read_u8("emote_14", Emotes::right);
		emote_15 = cfg.read_u8("emote_15", Emotes::pickup);
		emote_16 = cfg.read_u8("emote_16", Emotes::archer);
		emote_17 = cfg.read_u8("emote_17", Emotes::builder);
		emote_18 = cfg.read_u8("emote_18", Emotes::knight);
		emote_19 = cfg.read_u8("emote_19", Emotes::finger);
		emote_20 = cfg.read_u8("emote_20", Emotes::fire);
	}
}

void onTick(CBlob@ this)
{
	CControls@ controls = getControls();
	if (controls.isKeyJustPressed(KEY_KEY_1))
	{
		set_emote(this, emote_1);
	}
	else if (controls.isKeyJustPressed(KEY_KEY_2))
	{
		set_emote(this, emote_2);
	}
	else if (controls.isKeyJustPressed(KEY_KEY_3))
	{
		set_emote(this, emote_3);
	}
	else if (controls.isKeyJustPressed(KEY_KEY_4))
	{
		set_emote(this, emote_4);
	}
	else if (controls.isKeyJustPressed(KEY_KEY_5))
	{
		set_emote(this, emote_5);
	}
	else if (controls.isKeyJustPressed(KEY_KEY_6))
	{
		set_emote(this, emote_6);
	}
	else if (controls.isKeyJustPressed(KEY_KEY_7))
	{
		set_emote(this, emote_7);
	}
	else if (controls.isKeyJustPressed(KEY_KEY_8))
	{
		set_emote(this, emote_8);
	}
	else if (controls.isKeyJustPressed(KEY_KEY_9))
	{
		set_emote(this, emote_9);
	}
	else if (controls.isKeyJustPressed(KEY_KEY_0))
	{
		set_emote(this, emote_10);
	}			
	else if (controls.isKeyJustPressed(KEY_NUMPAD1))
	{	// MORE EMOTES
		set_emote(this, emote_11);
	}
	else if (controls.isKeyJustPressed(KEY_NUMPAD2))
	{
		set_emote(this, emote_12);
	}
	else if (controls.isKeyJustPressed(KEY_NUMPAD3))
	{
		set_emote(this, emote_13);
	}
	else if (controls.isKeyJustPressed(KEY_NUMPAD4))
	{
		set_emote(this, emote_14);
	}
	else if (controls.isKeyJustPressed(KEY_NUMPAD5))
	{
		set_emote(this, emote_15);
	}
	else if (controls.isKeyJustPressed(KEY_NUMPAD6))
	{
		set_emote(this, emote_16);
	}
	else if (controls.isKeyJustPressed(KEY_NUMPAD7))
	{
		set_emote(this, emote_17);
	}
	else if (controls.isKeyJustPressed(KEY_NUMPAD8))
	{
		set_emote(this, emote_18);
	}
	else if (controls.isKeyJustPressed(KEY_NUMPAD9))
	{
		set_emote(this, emote_19);
	}
	else if (controls.isKeyJustPressed(KEY_NUMPAD0))
	{
		set_emote(this, emote_20);
	}
}
