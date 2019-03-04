const string _defaultName = "Jonny98";

void FirstScreen(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	if (group !is null)
	{
		UI::Transition(group, Vec2f(-1.0f, 0.0f));
		UI::Transition(control, Vec2f(1.0f, 0.0f));
		UI::Clear();
	}
	AskForName(this);
}

void AskForName(CRules@ this)
{
	AddOptionsLabel(this);
	@_backCallback = FirstSetupEscape;

	UI::SetFont("menu");

	//cl_name = ""; // this is needed cause cl_name gets overwritten and blablablaba - on server join this is run
	if (cl_name == "Peasant"){
		cl_name = "";
	}

	if (HandleFailMessage())
	{
		UI::AddGroup("firstsetup retry", Vec2f(0.2, 0.4), Vec2f(0.8, 0.6));
		UI::Grid(1, 2);
		UI::Label::Add("Connection failed");
		UI::Button::Add("OK", LocalOrOnline);
		UI::Transition(Vec2f(-1.0f, 0.0f));
	}
	else
	{
		UI::AddGroup("firstsetup askforname", Vec2f(0.2, 0.5), Vec2f(0.8, 0.8));
		UI::Grid(1, 2);
		UI::Label::Add("Welcome! What's your name?");
		UI::TextInput::Add(cl_name, SetYourName, false, 20);
		UI::Transition(Vec2f(-1.0f, 0.0f));

		// select text input
		@UI::getData().activeGroup.editControl = UI::getData().activeGroup.lastAddedControl;
		UI::SetLastSelection(0);
	}

	// set joy defaults - better place for this?

	for (uint i = 0; i < 4; i++)
	{
		CControls@ controls = getControls(i + 1);
		if (controls.getActionKeyKey(AK_ACTION1) == KEY_KEY_Z)  // hack
		{
			SetGamepadDefaults(i + 1, i);
		}
	}	
}

string SetYourName(const string &in caption)
{
	cl_name = caption;
	if (cl_name == "")
	{
		cl_name = _defaultName;
	}
	if (getJoysticksCount() > 0){
		ShowFirstSetup(getRules());
	}
	else{
		SelectKeyboard( getRules(), null, null );
	}
	return caption;
}

void SecondScreen(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	UI::Clear();
	ShowFirstSetup( this );
}

void ShowFirstSetup(CRules@ this)
{
	UI::Clear();

	@_backCallback = FirstScreen;
	AddBackLabel(this);

	UI::SetFont("menu");

	UI::AddGroup("firstsetup controls", Vec2f(0.2, 0.3), Vec2f(0.8, 0.7));
	UI::Grid(1, 3);
	UI::Label::Add("Which controller do you prefer?");
	UI::Button::Add("Keyboard", SelectKeyboard);
	UI::Button::Add("Gamepad", SelectGamepad);
	UI::Transition(Vec2f(-1.0f, 0.0f));

	UI::SetSelection(0);
}

int _controlsSelection = 0;

void SelectKeyboard(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	_controlsSelection = 0;
	SetKeyboardDefaults(0, 0);
	FirstControlsSetup(this, group, control);
}

void SelectGamepad(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	_controlsSelection = 1;
	SetGamepadDefaults(0, 0);
	FirstControlsSetup(this, group, control);
}

bool _controlsChanged = false;

void FirstControlsSetup(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	CControls@ controls = getControls();
	UI::Clear();

	if (getJoysticksCount() > 0){
		@_backCallback = SecondScreen;
	}
	else{
		@_backCallback = FirstScreen;
	}
	AddBackLabel(this);

	UI::AddGroup("firstsetup input2", Vec2f(0.2, 0.2), Vec2f(0.8, 0.8));

	UI::SetThinSelector();
	UI::Grid(2, 10);

	UI::SetFont("hud");

	UI::Label::Add("");
	UI::Label::Add("");

	if (_controlsChanged){
		UI::Button::Add("Defaults", FirstSetupBackToDefaults);
		UI::Label::Add("Set back default controls");
	}
	else {
		UI::Label::Add("Change controls?");
		UI::Label::Add("");
	}

	//UI::Label::Add("Action:");
	//UI::Label::Add("Key:");

	UI::Button::Add("ACTION 1", FirstSetupModifyKey);
	UI::Label::Add("[ " + controls.getActionKeyKeyName(AK_ACTION1) + " ]");
	UI::Button::Add("ACTION 2", FirstSetupModifyKey);
	UI::Label::Add("[ " + controls.getActionKeyKeyName(AK_ACTION2) + " ]");
	UI::Button::Add("JUMP", FirstSetupModifyKey);
	UI::Label::Add("[ " + controls.getActionKeyKeyName(AK_JUMP) + " ]");
	UI::Button::Add("CROUCH", FirstSetupModifyKey);
	UI::Label::Add("[ " + controls.getActionKeyKeyName(AK_CROUCH) + " ]");
	UI::Button::Add("LEFT", FirstSetupModifyKey);
	UI::Label::Add("[ " + controls.getActionKeyKeyName(AK_MOVE_LEFT) + " ]");
	UI::Button::Add("RIGHT", FirstSetupModifyKey);
	UI::Label::Add("[ " + controls.getActionKeyKeyName(AK_MOVE_RIGHT) + " ]");
	UI::Button::Add("UP", FirstSetupModifyKey);
	UI::Label::Add("[ " + controls.getActionKeyKeyName(AK_MOVE_UP) + " ]");
	UI::Button::Add("DOWN", FirstSetupModifyKey);
	UI::Label::Add("[ " + controls.getActionKeyKeyName(AK_MOVE_DOWN) + " ]");

	UI::Transition(Vec2f(-1.0f, 0.0f));

	UI::AddGroup("firstsetup input", Vec2f(0.2, 0.03), Vec2f(0.8, 0.2));
	UI::SetFont("menu");
	UI::Grid(2, 1);
	UI::Button::Add("OK", LocalOrOnline);
	UI::Label::Add("");
	UI::Transition(Vec2f(0.0f, 1.0f));

	UI::SetSelection(-1);
}

void FirstSetupBackToDefaults(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	_controlsChanged = false;
	if (_controlsSelection == 0)
	{
		SetKeyboardDefaults(0, 0);
		FirstControlsSetup(this, group, control);
	}
	else
	{
		SetGamepadDefaults(0, 0);
		FirstControlsSetup(this, group, control);
	}
}

void FirstSetupModifyKey(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	_controlsChanged = true;
	this.set_u32("modify controls", 0);
	this.set_string("modify key", control.caption);
	this.AddScript("modifykey");
	this.set("modify key callback", FirstControlsSetup);
}

string _gridNoTopIcons = "Sprites/UI/grid_notop_icons.png";
bool _onLocalOrOnlineScreen = false;

void LocalOrOnline(CRules@ this)
{
	_onLocalOrOnlineScreen = true;
	UI::Clear();

	@_backCallback = FirstSetupEscape;
	AddOptionsLabel(this);

	UI::AddGroup("firstsetup gamemode", Vec2f(0.05f, 0.4f), Vec2f(0.95f, 0.6f), _gridNoTopIcons, _gridIconSize);
	UI::SetNoSelector();
	UI::Grid(2, 1);
	UI::Control@ serverButton;

	// caption1 is used to determine region!

	@serverButton = UI::Button::Add("", ShowMultiplayerMenu, GridButtonRender, GridRenderCaption, false, 0.5f, 3);
	serverButton.vars.set("caption1", "Online");
	serverButton.vars.set("caption2", "");
	serverButton.vars.set("icon", 12);
	serverButton.vars.set("description", "Play with more friends over the internet");
	serverButton.vars.set("players", "");

	@serverButton = UI::Button::Add("", SelectGameLocal, GridButtonRender, GridRenderCaption, false, 0.5f, 3);
	serverButton.vars.set("caption1", "Local");
	serverButton.vars.set("caption2", "");
	serverButton.vars.set("icon", 11);
	serverButton.vars.set("description", "1-4 players on this computer");
	serverButton.vars.set("players", "");

	UI::Transition(Vec2f(-1.0f, 0.0f));

	UI::SetLastSelection(0);
}

void LocalOrOnline(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	LocalOrOnline(this);
}

void SelectGameLocal(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	UI::Clear();

	@_backCallback = LocalOrOnline;
	AddBackLabel(this);

	UI::AddGroup("firstsetup gamelocal", Vec2f(0.05f, 0.4f), Vec2f(0.95f, 0.6f), _gridNoTopIcons, _gridIconSize);
	UI::SetNoSelector();
	UI::Grid(2, 1);
	UI::Control@ serverButton;

	// caption1 is used to determine region!

	@serverButton = UI::Button::Add("", PlaySkirmish, GridButtonRender, GridRenderCaption, false, 0.5f, 3);
	serverButton.vars.set("caption1", "Skirmish");
	serverButton.vars.set("caption2", "");
	serverButton.vars.set("icon", 14);
	serverButton.vars.set("description", "1-4 humans or bots on one screen");
	serverButton.vars.set("players", "");

	@serverButton = UI::Button::Add("", PlayCampaign, GridButtonRender, GridRenderCaption, false, 0.5f, 3);
	serverButton.vars.set("caption1", "Run");
	serverButton.vars.set("caption2", "");
	serverButton.vars.set("icon", 13);
	serverButton.vars.set("description", "Solo campaign against bots");
	serverButton.vars.set("players", "");

	UI::Transition(Vec2f(-1.0f, 0.0f));

	UI::SetLastSelection(0);
}

void FirstSetupEscape(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	UI::Clear();

	if (!_onLocalOrOnlineScreen){
		@_backCallback = FirstScreen;
	}
	else{
		@_backCallback = LocalOrOnline;	
	}

	AddBackLabel(this);

	UI::SetFont("menu");
	UI::AddGroup("firstsetup restart", Vec2f(0.2, 0.2), Vec2f(0.8, 0.8));
	UI::Grid(2, 2);
	UI::Button::Add("OPTIONS", ShowSetupMenu);
	 UI::Label::Add("input, sound and player preferences");
	UI::Button::Add("QUIT", SelectQuitGame);
	 UI::Label::Add("exit to desktop");
	UI::Transition(Vec2f(1.0f, 0.0f));
	UI::SetLastSelection(0);
}
