#include "UI.as"

//skin
#include "MainButtonRender.as"
#include "MainImageRender.as"
#include "MainLabelRender.as"
#include "MainTextInputRender.as"
#include "MainToggleRender.as"
#include "MainOptionRender.as"
#include "MainSliderRender.as"
//controls
#include "UIButton.as"
#include "UIImage.as"
#include "UILabel.as"
#include "UITextInput.as"
#include "UIToggle.as"
#include "UIOption.as"
#include "UISlider.as"
#include "UIDialog.as"

#include "MainMenuSelectors.as"
//
#include "GridBrowser.as"
#include "Browser.as"

SELECT_FUNCTION@ _backCallback = BackToMainMenu;
bool _failedConnect = false;

SELECT_FUNCTION@ _failCallback = Login;

Vec2f select_area_tl(0.15f, 0.1f);
Vec2f select_area_br(0.85f, 0.85f);

void OnAuthenticationFail(CRules@ this, const string &in lastMsgCaption, const string &in lastMsg)
{
	print("AUTH FAILED: " + lastMsgCaption + " - " + lastMsg);

	_failCallback(this, null, null );

	if (auth_login == ""){
		UI::Dialog::Add( "Please provide your account name.");	
	}
	else if (Engine::getAuthPasswordDummy() == ""){
		UI::Dialog::Add( "Please provide your account password.");	
	}
	else {
		UI::Dialog::Add( lastMsgCaption + "\n" + lastMsg);
	}
	UI::Transition(Vec2f(0.0f, 1.0f));
}

void OnAuthenticationSuccess(CRules@ this)
{
	print("AUTH SUCCESS");

	//u_agreedterms = false;

	if (!u_agreedterms)
	{
		UI::Group@ group = UI::AddGroup("dialog#"+_dialogCount++, Vec2f(0.02f,0.05f), Vec2f(0.9f,0.8f));
		group.modal = false;
		UI::Grid( 1, 1 );
		UI::Label::Add( Engine::getTermsText(), false, 2.0f );
		UI::Transition(Vec2f(0.0f, -1.0f));

		UI::SetFont("gui");
		UI::Dialog::AddYesNo( "AGREE", TermsYes, "CANCEL", TermsNo, true );
		UI::Transition(Vec2f(0.0f, 1.0f));		
	}
	else
	{
		ShowGridBrowserInit(this, null, null);
	}
}

void OnOffline(CRules@ this)
{
	print("AUTH OFFLINE");
	_backCallback(this, null, null);
	//getHUD().HideCursor();
}

void OnURLAsk(CRules@ this)
{
	UI::Dialog::AddYesNo( "OPEN WEB BROWSER", WebsiteYes, "CANCEL", WebsiteNo );
	UI::Transition(Vec2f(0.0f, 1.0f));
}

void OnTerms(CRules@ this, bool agreed)
{
	print("TERMS " + agreed);
	if (agreed)
	{
		ShowGridBrowserInit(this, null, null);
		//getHUD().HideCursor();
	}
	else{
		_backCallback(this, null, null);
		//getHUD().HideCursor();
	}
}

void OnDisconnectMessage(CRules@ this, const string &in msg)
{
	// this ust prevent from engine popup showing
	print("script: OnDisconnectMessage " + msg);	
}

void Reconnect(const string &in gamemode)
{
	CNet@ net = getNet();
	net.SafeConnect("localhost:" + sv_port, "Rules/" + gamemode + "/gamemode.cfg" );
}

//---

void ShowMainMenu(CRules@ this)
{
	select_area_tl.y = 0.4;

	UI::Clear();
	UI::SetFont("menu");
	UI::AddGroup("title", Vec2f(0, 0.1f), Vec2f(1.0f, 0.3));
		UI::Grid(1, 1);
		UI::Image::Add("TitleScreen.png");
	UI::AddGroup("mainmenu", select_area_tl, select_area_br);
		UI::Grid(2, 4);
		UI::Button::Add("LOCAL", ShowSingleplayerMenu);
		UI::Label::Add("1-4 players");
		UI::Button::Add("ONLINE", ShowMultiplayerMenu);
		UI::Label::Add("play over the interwebz");
		UI::Button::Add("OPTIONS", ShowSetupMenu);
		UI::Label::Add("change settings");
		UI::Button::Add("QUIT", SelectQuitGame);
		UI::Label::Add("exit the game");
		UI::Transition(Vec2f(-1.0f, 0.0f));
	UI::SetLastSelection(0);

	// set joy defaults - better place for this?

	for (uint i = 0; i < 4; i++)
	{
		CControls@ controls = getControls(i + 1);
		if (controls.getActionKeyKey(AK_ACTION1) == KEY_KEY_Z)  // hack
		{
			SetGamepadDefaults(i + 1, i);
		}
	}

	HandleFailMessage();
}

bool HandleFailMessage()
{
	// connection failed message

	if (_failedConnect)
	{
		EngineMessage("Connection to " + cl_joinaddress + " failed");
		_failedConnect = false;
		return true;
	}
	else if (getNet().lastErrorMsg != "")
	{
		//OnDisconnectMessage( this, getNet().lastErrorMsg );
		EngineMessage( getNet().lastErrorMsg );
		getNet().lastErrorMsg = "";
		return true;
	}

	return false;
}

void BackToMainMenu(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	if (group !is null)
	{
		UI::Transition(group, Vec2f(-1.0f, 0.0f));
		UI::Transition(control, Vec2f(1.0f, 0.0f));
	}
	ShowMainMenu(this);
}

void ShowSingleplayerMenu(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	UI::Transition(group, Vec2f(-1.0f, 0.0f));
	UI::Transition(control, Vec2f(1.0f, 0.0f));
	UI::Clear(group.name);

	UI::AddGroup("solo", select_area_tl, select_area_br);
		UI::Grid(2, 3);
		UI::Button::Add("Skirmish", ShowSkirmishOptions);
		UI::Label::Add("fight vs humans or bots");
		UI::Button::Add("Campaign", PlayCampaign);
		UI::Label::Add("war with bots");
		UI::Button::Add("Back", _backCallback);
		UI::Label::Add("to main menu");

	UI::Transition(Vec2f(-1.0f, 0.0f));
	UI::SetLastSelection();
}

void ShowSetupMenu(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	UI::Transition(group, Vec2f(-1.0f, 0.0f));
	UI::Transition(control, Vec2f(1.0f, 0.0f));
	UI::Clear();

	@_backCallback = FirstSetupEscape;
	AddBackLabel( this );

	UI::SetFont("menu");
	UI::AddGroup("setup", select_area_tl, select_area_br);
		UI::Grid(2, 3);
		UI::Button::Add("INPUT", ShowSetupInputMenu);
		UI::Label::Add("set your keys");
		//UI::Button::Add("VIDEO", ShowVideoMenu);
		//UI::Label::Add("visual controls");
		UI::Button::Add("SOUND", ShowSoundMenu);
		UI::Label::Add("audio controls");
		UI::Button::Add("PLAYER", ShowPlayerMenu);
		UI::Label::Add("preferences & customization");
		//UI::Button::Add("BACK", _backCallback);
		//UI::Label::Add("to main menu");
	UI::SetLastSelection();
	UI::Transition(Vec2f(-1.0f, 0.0f));
}

// QUIT

void SelectQuitGame(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	QuitGame(); // bye bye
}

// SOLO

int _humanPlayers = 4;

void ShowSkirmishOptions(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	UI::Transition(group, Vec2f(-1.0f, 0.0f));
	UI::Transition(control, Vec2f(1.0f, 0.0f));
	UI::Clear(group.name);

	UI::AddGroup("skirmish", select_area_tl, select_area_br);
		UI::Grid(2, 3);
		UI::Button::Add("Play", PlaySkirmish);
		UI::Label::Add("start the game");
		UI::Slider::Add("Players", SetLocalPlayers, _humanPlayers, 1, 2, 4);
		UI::Label::Add("player count");
		//  UI::Slider::Add( "Bots", SetBots, sv_bots, 1, 0, 3 );
		//  UI::Label::Add( "CPU players]");
		UI::Button::Add("Back", _backCallback);
		UI::Label::Add("to main menu");

	UI::Transition(Vec2f(-1.0f, 0.0f));
	UI::SetLastSelection();
}

float SetLocalPlayers(float option)
{
	_humanPlayers = option;
	return option;
}
float SetBots(float option)
{
	sv_bots = option;
	return option;
}

void PlaySkirmish(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	sv_max_localplayers = _humanPlayers;
	Reconnect("Skirmish");
}

void PlayCampaign(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	sv_max_localplayers = 1;
	Reconnect("Campaign");
}

// void SelectSoloCampaign( CRules@ this, UI::Group@ group, UI::Control@ control )
// {
//     LateLoadRules(  "Rules/Campaign/gamemode.cfg" );
// }

// Multi

void ShowMultiplayerMenu(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	UI::Transition(group, Vec2f(-1.0f, 0.0f));
	UI::Transition(control, Vec2f(1.0f, 0.0f));
	if (group !is null)
	{
		UI::Clear(group.name);
		UI::Clear("title");
	}

	ShowGridBrowserInit( this, group, control );
}

void SelectMultiLocalDM(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	sv_max_localplayers = 4;
	Reconnect("Skirmish");
}

void SelectConnectTo(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	UI::Transition(group, Vec2f(-1.0f, 0.0f));
	UI::Transition(control, Vec2f(1.0f, 0.0f));
	UI::Clear("multigrid");
	UI::Clear(group.name);

	ShowConnectTo(this);
}

void ShowConnectTo(CRules@ this)
{
	UI::AddGroup("connect", select_area_tl, select_area_br);
	UI::SetFont("hud");
		UI::Grid(2, 4);
		UI::TextInput::Add(cl_joinaddress, SetJoinIPPort, false, 32);
		UI::Label::Add("IP:Port");
		UI::TextInput::Add(cl_password, SetJoinPassword, true, 32);
		UI::Label::Add("optional password");
		UI::Button::Add("Connect", SelectConnect);
		UI::Label::Add("join the server");
		UI::Button::Add("Back", _backCallback);
	UI::Transition(Vec2f(-1.0f, 0.0f));
	UI::SetLastSelection();
}

string SetJoinIPPort(const string &in caption)
{
	cl_joinaddress = caption;
	return caption;
}

string SetJoinPassword(const string &in caption)
{
	cl_password = caption;
	return caption;
}

void SelectConnect(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	CNet@ net = getNet();
	net.SafeConnect(cl_joinaddress);
}

void onConnectFail()
{
	sv_max_localplayers = 1;
	_failedConnect = true;
	Reconnect("Main");
}

// PLAYER

void ShowPlayerMenu(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	CControls@ controls = getControls();
	UI::Transition(group, Vec2f(-1.0f, 0.0f));
	UI::Transition(control, Vec2f(1.0f, 0.0f));
	UI::Clear();

	@_backCallback = ShowSetupMenu;
	AddBackLabel( this );

	UI::SetFont("hud");
	UI::AddGroup("setup player", select_area_tl, select_area_br);
		UI::SetThinSelector();
		UI::Grid(2, 4);

		UI::TextInput::Add(cl_name, SetCharName, false, 20);
		UI::Label::Add("your character name");
		//UI::Option::Add("Male|Female|Geti", SetGender, cl_sex);
		//UI::Label::Add("your character gender");
		UI::TextInput::Add(cl_clantag, SetClanName, false, 5);
		UI::Label::Add("optional: clan name");
		UI::Toggle::Add("Kids safe", SetKidsSafe, g_kidssafe);
		UI::Label::Add("no gore or swearing");
		//UI::Toggle::Add("Team-mate names", SetTeammateNames, u_shownames);
		//UI::Label::Add("Show names on players");
		//UI::Toggle::Add("Chat bubbles", SetChatBubbles, cl_chatbubbles);
		//UI::Label::Add("Show chat on player");

		//UI::Button::Add("BACK", ShowSetupMenu);
		//UI::Label::Add("to main menu");
	UI::SetLastSelection();
}

string SetCharName(const string &in caption)
{
	cl_name = caption;
	return caption;
}

string SetClanName(const string &in caption)
{
	cl_clantag = caption;
	return caption;
}

int SetGender(int option)
{
	cl_sex = option;
	return option;
}

bool SetKidsSafe(bool toggle)
{
	g_kidssafe = toggle;
	return toggle;
}

bool SetTeammateNames(bool toggle)
{
	u_shownames = toggle;
	return toggle;
}

bool SetChatBubbles(bool toggle)
{
	cl_chatbubbles = toggle;
	return toggle;
}

bool SetRememberMe(bool toggle)
{
	auth_remember = toggle;
	return toggle;
}

// VIDEO


void ShowVideoMenu(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	CControls@ controls = getControls();
	UI::Transition(group, Vec2f(-1.0f, 0.0f));
	UI::Transition(control, Vec2f(1.0f, 0.0f));
	UI::Clear(group.name);
	UI::SetFont("hud");
	UI::AddGroup("setup video", select_area_tl, select_area_br);
		UI::SetThinSelector();
		UI::Grid(2, 5);

		UI::Toggle::Add("Use shaders", SetShaders, v_postprocess);
		UI::Label::Add("turn off for faster display");
		UI::Toggle::Add("Faster graphics", SetQuality, v_fastrender);
		UI::Label::Add("turn on for lower quality and more FPS");
		UI::Toggle::Add("VSync", SetVSync, v_vsync);
		UI::Label::Add("prevent tearing - requires restart");
		UI::Toggle::Add("Uncapped framerate", SetUncapped, v_uncapped);
		UI::Label::Add("smoother graphics but may be slower");

		UI::Button::Add("BACK", ShowSetupMenu);
		UI::Label::Add("to main menu]");
	UI::SetLastSelection();
}

bool SetShaders(bool toggle)
{
	v_postprocess = toggle;
	return toggle;
}
bool SetQuality(bool toggle)
{
	v_fastrender = toggle;
	return toggle;
}
bool SetVSync(bool toggle)
{
	v_vsync = toggle;
	return toggle;
}
bool SetUncapped(bool toggle)
{
	v_uncapped = toggle;
	return toggle;
}

// SOUND

void ShowSoundMenu(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	CControls@ controls = getControls();
	UI::Transition(group, Vec2f(-1.0f, 0.0f));
	UI::Transition(control, Vec2f(1.0f, 0.0f));
	UI::Clear();

	@_backCallback = ShowSetupMenu;
	AddBackLabel( this );

	UI::SetFont("hud");
	UI::AddGroup("setup sound", select_area_tl, select_area_br);
		UI::SetThinSelector();
		UI::Grid(2, 5);

		UI::Slider::Add("Sound volume", SetSoundVolume, s_volume*100, 5, 0, 100, "%");
		UI::Label::Add("sound volume");
		UI::Slider::Add("Music volume", SetMusicVolume, s_musicvolume*100, 5, 0, 100, "%");
		UI::Label::Add("music volume");
		UI::Toggle::Add("Game music", SetMusic, s_gamemusic);
		UI::Label::Add("in game music on/off");
		//UI::Toggle::Add("Sound effects", SetEffects, s_effects);
		//UI::Label::Add("turn off if you have audio issues");
		UI::Toggle::Add("Swap left/right", SetSwapChannels, s_swapchannels);
		UI::Label::Add("Swap audio channels");

		//UI::Button::Add("BACK", ShowSetupMenu);
		//UI::Label::Add("to main menu");
	UI::SetLastSelection();
}

bool SetMusic(bool toggle)
{
	s_gamemusic = toggle;
	return toggle;
}
bool SetAmbient(bool toggle)
{
	s_ambientmusic = toggle;
	return toggle;
}
bool SetEffects(bool toggle)
{
	s_effects = toggle;
	return toggle;
}
bool SetSwapChannels(bool toggle)
{
	s_swapchannels = toggle;
	return toggle;
}
float SetSoundVolume(float value)
{
	s_volume = value / 100.0f;
	return value;
}
float SetMusicVolume(float value)
{
	s_musicvolume = value / 100.0f;
	return value;
}


// INPUT

void ShowSetupInputMenu(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	uint controlIndex = 0;
	CControls@ controls = getControls(controlIndex);
	UI::Transition(group, Vec2f(-1.0f, 0.0f));
	UI::Transition(control, Vec2f(1.0f, 0.0f));
	UI::Clear();

	@_backCallback = ShowSetupMenu;
	AddBackLabel( this );

	UI::SetFont("hud");
	uint players = 4;
	UI::AddGroup("setup input", select_area_tl, select_area_br);
	UI::Grid(2, 0 + players);

	for (uint i = 0; i < players; i++)
	{
		UI::Button::Add("PLAYER " + (i + 1), ShowInputForPlayer);
		UI::Label::Add("set keys for player " + (i + 1));
	}
	//UI::Button::Add("BACK", ShowSetupMenu);
	//UI::Label::Add("to main menu");
	UI::SetLastSelection();
}

void ShowInputForPlayer(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	uint controlIndex = 0;
	if (control.caption == "PLAYER 1")
	{
		controlIndex = 0;
	}
	else if (control.caption == "PLAYER 2")
	{
		controlIndex = 1;
	}
	else if (control.caption == "PLAYER 3")
	{
		controlIndex = 2;
	}
	else if (control.caption == "PLAYER 4")
	{
		controlIndex = 3;
	}
	CControls@ controls = getControls(controlIndex);
	UI::Transition(group, Vec2f(-1.0f, 0.0f));
	UI::Transition(control, Vec2f(1.0f, 0.0f));
	UI::Clear();

	@_backCallback = ShowSetupInputMenu;
	AddBackLabel( this );

	UI::AddGroup("setup input " + controlIndex, select_area_tl, select_area_br);
		UI::SetThinSelector();
		UI::Grid(2, 11);
		UI::Label::Add("");
		UI::Label::Add("PLAYER " + (controlIndex + 1));
		UI::Button::Add("ACTION 1", ModifyKey);
		UI::Label::Add("[ " + controls.getActionKeyKeyName(AK_ACTION1) + " ]");
		UI::Button::Add("ACTION 2", ModifyKey);
		UI::Label::Add("[ " + controls.getActionKeyKeyName(AK_ACTION2) + " ]");
		UI::Button::Add("JUMP", ModifyKey);
		UI::Label::Add("[ " + controls.getActionKeyKeyName(AK_JUMP) + " ]");
		UI::Button::Add("CROUCH", ModifyKey);
		UI::Label::Add("[ " + controls.getActionKeyKeyName(AK_CROUCH) + " ]");
		UI::Button::Add("LEFT", ModifyKey);
		UI::Label::Add("[ " + controls.getActionKeyKeyName(AK_MOVE_LEFT) + " ]");
		UI::Button::Add("RIGHT", ModifyKey);
		UI::Label::Add("[ " + controls.getActionKeyKeyName(AK_MOVE_RIGHT) + " ]");
		UI::Button::Add("UP", ModifyKey);
		UI::Label::Add("[ " + controls.getActionKeyKeyName(AK_MOVE_UP) + " ]");
		UI::Button::Add("DOWN", ModifyKey);
		UI::Label::Add("[ " + controls.getActionKeyKeyName(AK_MOVE_DOWN) + " ]");

		UI::Button::Add("Keyboard defaults", SetKeyboardDefaults);
		UI::Label::Add("Set back to keyboard defaults");
		UI::Button::Add("Gamepad defaults", SetGamepadDefaults);
		UI::Label::Add("Set back to gamepad defaults");

		//UI::Button::Add("BACK", ShowSetupInputMenu);
		//UI::Label::Add("to main menu");
	UI::SetLastSelection();
}

uint getControlIndexFromGroup(UI::Group@ group)
{
	if (group.name == "setup input 0")
	{
		return 0;
	}
	else if (group.name == "setup input 1")
	{
		return 1;
	}
	else if (group.name == "setup input 2")
	{
		return 2;
	}
	else if (group.name == "setup input 3")
	{
		return 3;
	}
	return 255;
}

void ModifyKey(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	uint controlIndex = getControlIndexFromGroup(group);

	this.set_u32("modify controls", controlIndex);
	this.set_string("modify key", control.caption);
	this.AddScript("modifykey");
	this.set("modify key callback", ReturnToInputMenu);
}

void SetKeyboardDefaults(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	SetKeyboardDefaults(getControlIndexFromGroup(group), getControlIndexFromGroup(group));
	ReturnToInputMenu(this);
}

void SetKeyboardDefaults(const int controlsIndex, const int keyboard)
{
	CControls@ controls = getControls(controlsIndex);

	if (keyboard == 0)
	{
		controls.MapActionKey(AK_ACTION1, KEY_KEY_Z);
		controls.MapActionKey(AK_ACTION2, KEY_KEY_X);
		controls.MapActionKey(AK_MOVE_LEFT, KEY_LEFT);
		controls.MapActionKey(AK_MOVE_RIGHT, KEY_RIGHT);
		controls.MapActionKey(AK_MOVE_UP, KEY_UP);
		controls.MapActionKey(AK_MOVE_DOWN, KEY_DOWN);
		controls.MapActionKey(AK_JUMP, KEY_UP);
		controls.MapActionKey(AK_CROUCH, KEY_DOWN);
	}
	else if (keyboard == 1)
	{
		controls.MapActionKey(AK_ACTION1, KEY_KEY_Z);
		controls.MapActionKey(AK_ACTION2, KEY_KEY_X);
		controls.MapActionKey(AK_MOVE_LEFT, KEY_LEFT);
		controls.MapActionKey(AK_MOVE_RIGHT, KEY_RIGHT);
		controls.MapActionKey(AK_MOVE_UP, KEY_UP);
		controls.MapActionKey(AK_MOVE_DOWN, KEY_DOWN);
		controls.MapActionKey(AK_JUMP, KEY_UP);
		controls.MapActionKey(AK_CROUCH, KEY_DOWN);
	}
	else if (keyboard == 2)
	{
		controls.MapActionKey(AK_ACTION1, KEY_KEY_Z);
		controls.MapActionKey(AK_ACTION2, KEY_KEY_X);
		controls.MapActionKey(AK_MOVE_LEFT, KEY_LEFT);
		controls.MapActionKey(AK_MOVE_RIGHT, KEY_RIGHT);
		controls.MapActionKey(AK_MOVE_UP, KEY_UP);
		controls.MapActionKey(AK_MOVE_DOWN, KEY_DOWN);
		controls.MapActionKey(AK_JUMP, KEY_UP);
		controls.MapActionKey(AK_CROUCH, KEY_DOWN);
	}
	else if (keyboard == 3)
	{
		controls.MapActionKey(AK_ACTION1, KEY_KEY_Z);
		controls.MapActionKey(AK_ACTION2, KEY_KEY_X);
		controls.MapActionKey(AK_MOVE_LEFT, KEY_LEFT);
		controls.MapActionKey(AK_MOVE_RIGHT, KEY_RIGHT);
		controls.MapActionKey(AK_MOVE_UP, KEY_UP);
		controls.MapActionKey(AK_MOVE_DOWN, KEY_DOWN);
		controls.MapActionKey(AK_JUMP, KEY_UP);
		controls.MapActionKey(AK_CROUCH, KEY_DOWN);
	}
}

void SetGamepadDefaults(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	const int joyCount = getJoysticksCount();
	//SetGamepadDefaults(getControlIndexFromGroup(group), joyCount == 0 ? 0 : Maths::Min(getControlIndexFromGroup(group), joyCount - 1));
	SetGamepadDefaults(getControlIndexFromGroup(group), getControlIndexFromGroup(group));
	ReturnToInputMenu(this);
}

void SetGamepadDefaults(const int controlsIndex, const int joy)
{
	CControls@ controls = getControls(controlsIndex);

	if (joy == 0)
	{
		controls.MapActionKey(AK_ACTION1, JOYSTICK_1_BUTTON);
		controls.MapActionKey(AK_ACTION2, JOYSTICK_1_BUTTON + 1);
		controls.MapActionKey(AK_MOVE_LEFT, JOYSTICK_1_MOVE_LEFT);
		controls.MapActionKey(AK_MOVE_RIGHT, JOYSTICK_1_MOVE_RIGHT);
		controls.MapActionKey(AK_MOVE_UP, JOYSTICK_1_MOVE_UP);
		controls.MapActionKey(AK_MOVE_DOWN, JOYSTICK_1_MOVE_DOWN);
		controls.MapActionKey(AK_JUMP, JOYSTICK_1_MOVE_UP);
		controls.MapActionKey(AK_CROUCH, JOYSTICK_1_MOVE_DOWN);
	}
	else if (joy == 1)
	{
		controls.MapActionKey(AK_ACTION1, JOYSTICK_2_BUTTON);
		controls.MapActionKey(AK_ACTION2, JOYSTICK_2_BUTTON + 1);
		controls.MapActionKey(AK_MOVE_LEFT, JOYSTICK_2_MOVE_LEFT);
		controls.MapActionKey(AK_MOVE_RIGHT, JOYSTICK_2_MOVE_RIGHT);
		controls.MapActionKey(AK_MOVE_UP, JOYSTICK_2_MOVE_UP);
		controls.MapActionKey(AK_MOVE_DOWN, JOYSTICK_2_MOVE_DOWN);
		controls.MapActionKey(AK_JUMP, JOYSTICK_2_MOVE_UP);
		controls.MapActionKey(AK_CROUCH, JOYSTICK_2_MOVE_DOWN);
	}
	else if (joy == 2)
	{
		controls.MapActionKey(AK_ACTION1, JOYSTICK_3_BUTTON);
		controls.MapActionKey(AK_ACTION2, JOYSTICK_3_BUTTON + 1);
		controls.MapActionKey(AK_MOVE_LEFT, JOYSTICK_3_MOVE_LEFT);
		controls.MapActionKey(AK_MOVE_RIGHT, JOYSTICK_3_MOVE_RIGHT);
		controls.MapActionKey(AK_MOVE_UP, JOYSTICK_3_MOVE_UP);
		controls.MapActionKey(AK_MOVE_DOWN, JOYSTICK_3_MOVE_DOWN);
		controls.MapActionKey(AK_JUMP, JOYSTICK_3_MOVE_UP);
		controls.MapActionKey(AK_CROUCH, JOYSTICK_3_MOVE_DOWN);
	}
	else if (joy == 3)
	{
		controls.MapActionKey(AK_ACTION1, JOYSTICK_4_BUTTON);
		controls.MapActionKey(AK_ACTION2, JOYSTICK_4_BUTTON + 1);
		controls.MapActionKey(AK_MOVE_LEFT, JOYSTICK_4_MOVE_LEFT);
		controls.MapActionKey(AK_MOVE_RIGHT, JOYSTICK_4_MOVE_RIGHT);
		controls.MapActionKey(AK_MOVE_UP, JOYSTICK_4_MOVE_UP);
		controls.MapActionKey(AK_MOVE_DOWN, JOYSTICK_4_MOVE_DOWN);
		controls.MapActionKey(AK_JUMP, JOYSTICK_4_MOVE_UP);
		controls.MapActionKey(AK_CROUCH, JOYSTICK_4_MOVE_DOWN);
	}

	// if (joy == 0)
	// {
	// 	controls.MapActionKey(AK_ACTION1, JOYSTICK_1_BUTTON + 5);
	// 	controls.MapActionKey(AK_ACTION2, JOYSTICK_1_BUTTON + 4);
	// 	controls.MapActionKey(AK_MOVE_LEFT, JOYSTICK_1_MOVE_LEFT);
	// 	controls.MapActionKey(AK_MOVE_RIGHT, JOYSTICK_1_MOVE_RIGHT);
	// 	controls.MapActionKey(AK_MOVE_UP, JOYSTICK_1_MOVE_UP);
	// 	controls.MapActionKey(AK_MOVE_DOWN, JOYSTICK_1_MOVE_DOWN);
	// 	controls.MapActionKey(AK_JUMP, JOYSTICK_1_BUTTON);
	// 	controls.MapActionKey(AK_CROUCH, JOYSTICK_1_BUTTON + 1);
	// }
	// else if (joy == 1)
	// {
	// 	controls.MapActionKey(AK_ACTION1, JOYSTICK_2_BUTTON + 5);
	// 	controls.MapActionKey(AK_ACTION2, JOYSTICK_2_BUTTON + 4);
	// 	controls.MapActionKey(AK_MOVE_LEFT, JOYSTICK_2_MOVE_LEFT);
	// 	controls.MapActionKey(AK_MOVE_RIGHT, JOYSTICK_2_MOVE_RIGHT);
	// 	controls.MapActionKey(AK_MOVE_UP, JOYSTICK_2_MOVE_UP);
	// 	controls.MapActionKey(AK_MOVE_DOWN, JOYSTICK_2_MOVE_DOWN);
	// 	controls.MapActionKey(AK_JUMP, JOYSTICK_2_BUTTON);
	// 	controls.MapActionKey(AK_CROUCH, JOYSTICK_2_BUTTON + 1);
	// }
	// else if (joy == 2)
	// {
	// 	controls.MapActionKey(AK_ACTION1, JOYSTICK_3_BUTTON + 5);
	// 	controls.MapActionKey(AK_ACTION2, JOYSTICK_3_BUTTON + 4);
	// 	controls.MapActionKey(AK_MOVE_LEFT, JOYSTICK_3_MOVE_LEFT);
	// 	controls.MapActionKey(AK_MOVE_RIGHT, JOYSTICK_3_MOVE_RIGHT);
	// 	controls.MapActionKey(AK_MOVE_UP, JOYSTICK_3_MOVE_UP);
	// 	controls.MapActionKey(AK_MOVE_DOWN, JOYSTICK_3_MOVE_DOWN);
	// 	controls.MapActionKey(AK_JUMP, JOYSTICK_3_BUTTON);
	// 	controls.MapActionKey(AK_CROUCH, JOYSTICK_3_BUTTON + 1);
	// }
	// else if (joy == 3)
	// {
	// 	controls.MapActionKey(AK_ACTION1, JOYSTICK_4_BUTTON + 5);
	// 	controls.MapActionKey(AK_ACTION2, JOYSTICK_4_BUTTON + 4);
	// 	controls.MapActionKey(AK_MOVE_LEFT, JOYSTICK_4_MOVE_LEFT);
	// 	controls.MapActionKey(AK_MOVE_RIGHT, JOYSTICK_4_MOVE_RIGHT);
	// 	controls.MapActionKey(AK_MOVE_UP, JOYSTICK_4_MOVE_UP);
	// 	controls.MapActionKey(AK_MOVE_DOWN, JOYSTICK_4_MOVE_DOWN);
	// 	controls.MapActionKey(AK_JUMP, JOYSTICK_4_BUTTON);
	// 	controls.MapActionKey(AK_CROUCH, JOYSTICK_4_BUTTON + 1);
	// }
}

void ReturnToInputMenu(CRules@ this)
{
	printf("RETURN");
	UI::Data@ data = UI::getData();
	ShowInputForPlayer(this, data.activeGroup, data.activeGroup.controls[1][0]);
}

//

void NotAvailable(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	//UI::Dialog::Add( "This feature will be available in the full version.");
	u8[] frames = {0,1,2,3};
	UI::Dialog::AddImageAnimated( "Sprites/preorder.png", Vec2f(512, 320), frames, 10 );
	//UI::Dialog::AddImageFramed("Sprites/preorder.png", Vec2f(512, 320));
	UI::Transition(Vec2f(0.0f, 1.0f));
}

void WebsiteYes(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	Engine::AcceptWebsiteOpen( true );
	UI::Dialog::Select( this, group, control );
}

void WebsiteNo(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	Engine::AcceptWebsiteOpen( false );	
	UI::Dialog::Select( this, group, control );
}

void TermsYes(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	Engine::AcceptTerms(true);
	UI::Dialog::Select( this, group, control );
}

void TermsNo(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	Engine::AcceptTerms(false);
	UI::Dialog::Select( this, group, control );
	LocalOrOnline(this, null, null);
}