const string _defaultName = "Jonny98";

void FirstScreen(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	AskForName(this);
}

void AskForName(CRules@ this)
{
	UI::Clear();
	UI::SetFont("menu");

	cl_name = ""; // this is needed cause cl_name gets overwritten and blablablaba

	if (HandleFailMessage())
	{
		UI::AddGroup("firstsetup retry", Vec2f(0.2, 0.4), Vec2f(0.8, 0.6));
		UI::Grid(1, 2);
		UI::Button::Add("Retry", LaunchGame);
		UI::Button::Add("Quit", SelectQuitGame);
		UI::Transition(Vec2f(-1.0f, 0.0f));
	}
	else
	{
		int secsLeft = int(getFreeBuildEndTime()) - int(Time());
		int hoursLeft = secsLeft / 3600;
		int daysLeft = Maths::Floor(float(hoursLeft) / 24.0f);
		int remainderHours = hoursLeft - daysLeft * 24;
		string leftText = (
		                      hoursLeft > 24 ?
		                      ("" + daysLeft + (daysLeft > 1 ? " days " : " day ") + remainderHours + (remainderHours > 1 ? " hrs " : " hr ")) :
		                      ("" + hoursLeft + "" + (hoursLeft > 1 ? " hrs " : " hr "))
		                  ) + "remaining";

		if (secsLeft < 0)
		{
			UI::AddGroup("firstsetup expired", Vec2f(0.2, 0.5), Vec2f(0.8, 0.9));
			UI::Grid(1, 3);
			UI::Label::Add("The free test has expired. Thank you for playing!");
			UI::Button::Add("Website", PreOrder);
			UI::Button::Add("Quit", SelectQuitGame);
			UI::Transition(Vec2f(-1.0f, 0.0f));
			UI::SetLastSelection(0);
		}
		else
		{
			UI::AddGroup("firstsetup askforname", Vec2f(0.2, 0.5), Vec2f(0.8, 0.9));
			UI::Grid(1, 3);
			UI::Label::Add("Welcome to the free test! (" + leftText + ")");
			UI::Label::Add("What's your name?");
			UI::TextInput::Add(cl_name, SetYourName, false, 20);
			UI::Transition(Vec2f(-1.0f, 0.0f));

			// select text input
			@UI::getData().activeGroup.editControl = UI::getData().activeGroup.lastAddedControl;
			UI::SetLastSelection(0);
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
	ShowFirstSetup(getRules());
	return caption;
}

void ShowFirstSetup(CRules@ this)
{
	UI::Clear();
	UI::SetFont("menu");

	UI::AddGroup("firstsetup controls", Vec2f(0.2, 0.3), Vec2f(0.8, 0.7));
	UI::Grid(1, 3);
	UI::Label::Add("Which controller do you prefer?");
	UI::Button::Add("Keyboard", SelectKeyboard);
	UI::Button::Add("Gamepad", SelectGamepad);
	UI::Transition(Vec2f(-1.0f, 0.0f));

	UI::SetLastSelection(0);
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

void FirstControlsSetup(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	CControls@ controls = getControls();
	UI::Clear();
	UI::AddGroup("firstsetup input", Vec2f(0.2, 0.1), Vec2f(0.8, 0.9));

	UI::SetThinSelector();
	UI::Grid(2, 12);

	UI::SetFont("menu");
	UI::Label::Add("");
	UI::Label::Add("Change controls?");

	UI::SetFont("hud");
	UI::Button::Add("Back to defaults", FirstSetupBackToDefaults);
	UI::Label::Add("");
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

	UI::Label::Add("");
	UI::Label::Add("");

	UI::SetFont("menu");
	UI::Button::Add("OK", ExplainHappening);
	UI::Label::Add("");
	UI::SetLastSelection();
}

void FirstSetupBackToDefaults(CRules@ this, UI::Group@ group, UI::Control@ control)
{
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
	this.set_u32("modify controls", 0);
	this.set_string("modify key", control.caption);
	this.AddScript("modifykey");
	this.set("modify key callback", FirstControlsSetup);
}

void ExplainHappening(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	if (group !is null)
	{
		UI::Transition(group, Vec2f(-1.0f, 0.0f));
		UI::Transition(control, Vec2f(1.0f, 0.0f));
		UI::Clear("firstsetup input");
	}
	UI::AddGroup("firstsetup explain", Vec2f(0.2, 0.2), Vec2f(0.8, 0.8));
	UI::Grid(1, 5);
	UI::Label::Add("You will now be connected to the testing lobby.");
	UI::Label::Add("From there, you can make friends and join games.");
	UI::Label::Add("Please leave feedback on forum.thd.vg.");
	UI::Label::Add("Remember - Have Fun!");
	UI::Button::Add("Play!", LaunchGame);
	UI::Transition(Vec2f(-1.0f, 0.0f));
	UI::SetLastSelection();
}

void LaunchGame(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	//prevent music from carrying over
	if (getMixer() !is null)
	{
		getMixer().FadeOutAll(0.0f, 2.0f);
	}

	UI::Clear();
	// from GridBrowser.as
	_joinAddress = "178.63.17.152:50190";
	@group.data.escape_func = ExitAndConnect;
}

void FirstSetupEscape(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	//AskForName(this);

	UI::Clear();
	UI::SetFont("menu");
	UI::AddGroup("firstsetup restart", Vec2f(0.2, 0.2), Vec2f(0.8, 0.8));
	UI::Grid(1, 3);
	UI::Button::Add("Restart", FirstScreen);
	UI::Button::Add("Website", PreOrder);
	UI::Button::Add("Quit", SelectQuitGame);
	UI::SetLastSelection();

}

void PreOrder(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	Game::CreateTimer("website", 0.5f, @Website, false);
}
