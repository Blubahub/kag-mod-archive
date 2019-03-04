#include "PokerCommon.as"
#include "UI.as"
#include "DebugButton.as"
#include "GameColours.as"
#include "HoverMessage.as"
#include "RulesCommon.as"
#include "LobbyCommon.as"
#include "BackendCommon.as"

const string BAND_MENU = "bandmenu";
const int MENU_CLASS = 3;

void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	shape.SetStatic(true);
	ShapeConsts@ consts = shape.getConsts();
	consts.mapCollisions = false;

	CSprite@ sprite = this.getSprite();
	sprite.SetZ(-50);

	if (this.get_u8("class") == MENU_CLASS)
	{
		this.addCommandID("use");
		this.addCommandID("buy");
		//from server on success/fail
		this.addCommandID("bought");
		this.addCommandID("broke");
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("use") && this.get_u8("class") == MENU_CLASS)
	{
		CBlob@ blob = getBlobByNetworkID(params.read_netid());

		CRules@ rules = getRules();
		if (!getNet().isClient() || blob is null || hasMenus(rules) || Poker::hasLocalPokerSession(rules))
			return;

		CPlayer@ player = blob.getPlayer();
		if (player.isMyPlayer())
		{
			ShowMenu(rules, this, blob);
		}
	}
	else if (cmd == this.getCommandID("buy"))
	{
		//read out so we dont corrupt stream
		string music = params.read_string();
		u16 id = params.read_u16();

		//gather variables
		CBlob@ b = getBlobByNetworkID(id);
		if (b is null) return;
		CPlayer@ p = b.getPlayer();
		if (p is null) return;
		//only server does it
		if (!getNet().isServer()) return;
		//
		string name = p.getUsername();

		bool usebackend = getRules().hasTag("use_backend") && g_debug == 0;

		bool allowed = true;
		Lobby::PlayerRecord@ record = null;
		if (usebackend)
		{
			//todo: display error?
			if (Lobby::hasPlayerRecord(name))
			{
				//get the record
				@record = Lobby::getPlayerRecordFromUsername(name);
				allowed = record.coins > 0;
			}
			else
			{
				allowed = false;
			}
		}

		//has money?
		if (allowed || sv_test)
		{
			if (usebackend && !sv_test)
			{
				record.coins--;
				Backend::PlayerCoinTransaction(p, -1);
				Backend::PlayerMetric(p, "tipped_band");
			}

			CBitStream params;
			params.write_string(music);
			params.write_u16(id);
			this.SendCommand(this.getCommandID("bought"), params);
		}
		else
		{
			this.SendCommand(this.getCommandID("broke"));
		}

	}
	else if (cmd == this.getCommandID("bought"))
	{
		//read out so we dont corrupt stream
		string music = params.read_string();
		u16 id = params.read_u16();

		getRules().set_string("lobby_music", music);
		//this.Sync("lobby_music", true);

		printf("Playing music... " + music);

		if (music == ""){
			AddMessage(this, "Too bad :(");
		}
		else {
			AddMessage(this, "Sure thing, mate.");
		}
	}
	else if (cmd == this.getCommandID("broke"))
	{
		if (getNet().isClient())
		{
			//alt messages, increase with repeated tries:
			string[] messages =
			{
				"Sorry mate, we need coins.",
				"...A nice smile won't do.",
				"We're not a charity band!",
				"Musicians have families to feed too..."
			};
			if (!this.exists("_client_msgcounter"))
			{
				this.set_u8("_client_msgcounter", 0);
			}
			else
			{
				this.set_u8("_client_msgcounter", this.get_u8("_client_msgcounter") + 1);
			}
			u8 _client_msgcounter = this.get_u8("_client_msgcounter");
			AddMessage(this, messages[_client_msgcounter % messages.length]);
		}
	}
}

void ShowMenu(CRules@ this, CBlob@ band, CBlob@ player)
{
	UI::AddGroup(BAND_MENU, Vec2f(0.25f, 0.25f), Vec2f(0.7f, 0.7f));
	UI::SetFont("gui");
	UI::Grid(1, 11);
	UI::Debug::AddButton("Greet", MenuGreet);
	UI::Debug::AddButton("Play 'Trench Run Theme' (1c)", MenuTune1);
	UI::Debug::AddButton("Play 'Trench Run Classic' (1c)", MenuTune8);
	UI::Debug::AddButton("Play 'Sweet Surrender' (1c)", MenuTune7);
	//UI::Debug::AddButton("Play 'Lounge Music' (1c)", MenuTune2); //above is just a high res version? // fuck'em - let'em spend coins uselesly :p
	UI::Debug::AddButton("Play 'Spaghetti Western' (1c)", MenuTune3);
	UI::Debug::AddButton("Play 'Something Wacky' (1c)", MenuTune4);
	UI::Debug::AddButton("Play 'Electric Medic' (1c)", MenuTune5);
	UI::Debug::AddButton("Play 'Smooth Jazz' (1c)", MenuTune6);
	if (this.get_string("lobby_music") != "")
	{
		UI::Debug::AddButton("Please Stop Playing (1c)", MenuTuneStop);
	}
	UI::Debug::AddButton("Goodbye", MenuBye);

	UI::SetSelector("none", Vec2f_zero);
	UI::Debug::SetSelection(0);
	UI::Debug::SetLastSelection();

	UI::SetSelection(0);
	UI::SetLastSelection();

	UI::getGroup(BAND_MENU).vars.set("player", @player);
	UI::getGroup(BAND_MENU).vars.set("band", @band);
}


void MenuGreet(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	CBlob@ band;
	group.vars.get("band", @band);
	UI::Clear(group.name);
	if (band is null)
		return;

	if (this.get_string("lobby_music") == "")
	{
		AddMessage(band, "Hey mate, want us to play something?");
	}
	else
	{
		AddMessage(band, "Don't interrupt, we're playing.");
	}
}

void SwitchMusic(CRules@ this, CBlob@ band, CBlob@ player, const string &in music_file, const string &in tune_name)
{
	if (music_file == this.get_string("lobby_music"))
	{
		AddMessage(band, "We're already playing that!");
		return;
	}

	if (player.isMyPlayer())
	{
		CBitStream params;
		params.write_string(music_file);
		params.write_u16(player.getNetworkID());
		band.SendCommand(band.getCommandID("buy"), params);
	}
}

void MenuTuneDefault(CRules@ this, UI::Group@ group, UI::Control@ button, const string &in music, const string &in name )
{
	CBlob@ band;
	group.vars.get("band", @band);
	CBlob@ player;
	group.vars.get("player", @player);
	UI::Clear(BAND_MENU);
	if (band is null || player is null)
		return;
	SwitchMusic(this, band, player, music, name);
}

void MenuTune1(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	MenuTuneDefault(this, group, button, "Sounds/Music/TR01-Theme.ogg", "Trench Run Theme");
}

void MenuTune2(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	MenuTuneDefault(this, group, button, "Sounds/Music/Lobby_Music.ogg", "Lobby Theme");
}

void MenuTune3(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	MenuTuneDefault(this, group, button, "Sounds/Music/band-django.ogg", "Django Tune");
}

void MenuTune4(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	MenuTuneDefault(this, group, button, "Sounds/Music/band-littleloop.ogg", "Little Loop");
}

void MenuTune5(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	MenuTuneDefault(this, group, button, "Sounds/Music/band-medic.ogg", "Medic Tune");
}

void MenuTune6(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	MenuTuneDefault(this, group, button, "Sounds/Music/band-themejazz.ogg", "Jazz Theme");
}

void MenuTune7(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	MenuTuneDefault(this, group, button, "Sounds/Music/band-truce.ogg", "Truce Tune");
}

void MenuTune8(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	MenuTuneDefault(this, group, button, "Sounds/Music/band-maintheme.ogg", "Main Theme Electro");
}

void MenuTuneStop(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	MenuTuneDefault(this, group, button, "", "nothing");
}

void MenuBye(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	CBlob@ band;
	group.vars.get("band", @band);
	UI::Clear(BAND_MENU);
	if (band is null)
		return;
	AddMessage(band, "See ya.");
}


// SPRITE


void onInit(CSprite@ this)
{
	{
		//invisible by default
		Animation@ anim = this.addAnimation("default", 0, false);
		int[] frames = {30};
		anim.AddFrames(frames);
	}

	u32 speed_bass = 6;
	u32 speed_guitar = 4;

	{
		Animation@ anim = this.addAnimation("guitarist", speed_guitar, true);
		int[] frames = {0, 1, 2, 3, 4, 5, 6, 7};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("bassist", speed_bass, true);
		int[] frames = {10, 11, 12, 13, 14, 15, 16, 17, 8, 9, 18, 19};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("drummer", speed_guitar, true);
		int[] frames = {27, 20, 21, 22, 23, 24, 25, 26};
		anim.AddFrames(frames);
	}
}

void onTick(CSprite@ this)
{
	CBlob@ b = this.getBlob();
	if (b is null) return;

	u8 my_class = b.get_u8("class");
	if (my_class != 0)
	{
		string[] anims =
		{
			"default",
			"guitarist",
			"bassist",
			"drummer"
		};
		if (my_class < anims.length)
		{
			this.SetAnimation(anims[my_class]);
		}

		this.getAnimation(anims[my_class]).loop = (getRules().get_string("lobby_music") != "");
	}
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	GUI::SetFont("gui");

	//above is shown while we're in a menu

	if (getRules().get_s16("in menu") > 0 || blob.get_u8("class") != MENU_CLASS)
		return;

	// help msg

	//TODO; consider delaying this right after you've interacted
	CBlob@ playerblob = getLocalPlayerBlob();

	if (playerblob !is null && (playerblob.getPosition() - blob.getPosition()).getLength() < 20)
	{
		Vec2f help_offset(-16.0f, 84);
		Vec2f screenpos(blob.getScreenPos().x + help_offset.x, help_offset.y);

		string text = "[" + getControls().getActionKeyKeyName(AK_ACTION1) + "] talk to band";

		Vec2f dim;
		GUI::GetTextDimensions(text, dim);

		DrawTRGuiFrame(screenpos - dim * 0.5f - Vec2f(8, 0), screenpos + dim * 0.5f + Vec2f(8, 8));

		GUI::DrawTextCentered(text, screenpos, Colours::WHITE);
	}

}
