string _uniqueAcountName;

void SteamCreateLink(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	UI::Clear();

	@_backCallback = LocalOrOnline;
	AddBackLabel(this);

	UI::AddGroup("steam", Vec2f(0.1f, 0.3f), Vec2f(0.9f, 0.65f));
	UI::SetBigSelector();
	UI::Grid(2, 3);
	UI::SetFont("gui");

	UI::Label::Add("First launch from Steam");
	UI::Label::Add("");

	UI::Button::Add("I'm new", SteamNewAccount);
	UI::Label::Add("");
	UI::Button::Add("I have an existing account", SteamExistingAccount);
	UI::Label::Add("recommended if you have\na TR/KAG/THD account");

	UI::Transition(Vec2f(-1.0f, 0.0f));
	UI::SetSelection(0);
}

void SteamNewAccount(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	UI::Clear();

	_uniqueAcountName = Engine::getSteamUniqueAccountName();

	@_backCallback = SteamCreateLink;
	AddBackLabel(this);

	UI::AddGroup("steam", Vec2f(0.1f, 0.3f), Vec2f(0.9f, 0.65f));
	UI::SetBigSelector();
	UI::Grid(2, 2);
	UI::SetFont("gui");

	UI::Button::Add("Play as '" + _uniqueAcountName + "'", SteamPlayAs);
	UI::Label::Add("");
	UI::Button::Add("I want to change my name", SteamChangeName);
	UI::Label::Add("and have access to community forums");

	UI::Transition(Vec2f(-1.0f, 0.0f));
	UI::SetSelection(0);
}

void SteamExistingAccount(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	UI::Clear();

	@_backCallback = SteamCreateLink;
	AddBackLabel(this);

	UI::AddGroup("steam", Vec2f(0.1f, 0.3f), Vec2f(0.9f, 0.65f));
	UI::SetBigSelector();
	UI::Grid(2, 3);
	UI::SetFont("menu");

	//UI::Label::Add("Login");
	//UI::Label::Add("");

	UI::TextInput::Add(auth_login, SetAuthLogin, false, 30);
	UI::Label::Add("your account name");
	UI::TextInput::Add(Engine::getAuthPasswordDummy(), SetAuthPassword, true, 30);
	UI::Label::Add("your account password");
	UI::Button::Add("OK", SelectLinkLogin);
	UI::Label::Add("login");

	UI::Transition(Vec2f(-1.0f, 0.0f));
	UI::SetSelection(0);
}

void SelectLinkLogin(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	UI::Clear();
	UI::AddGroup("authenticating", Vec2f(0.1f, 0.0), Vec2f(1, 0.2));
	UI::Grid(1, 1);
	UI::Label::Add("");


	@_failCallback = SteamExistingAccount;
	Engine::Authenticate();
}

void SteamPlayAs(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	UI::Clear();
	UI::AddGroup("authenticating", Vec2f(0.1f, 0.0), Vec2f(1, 0.2));
	UI::Grid(1, 1);
	UI::Label::Add("");


	@_failCallback = SteamExistingAccount;
	if (!Engine::SteamCreateAccount(_uniqueAcountName, "", ""))
	{
		if (getNet().lastErrorMsg != "")
		{
			EngineMessage( getNet().lastErrorMsg );
		}		
	}
}

void SteamChangeName(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	UI::Clear();

	@_backCallback = SteamNewAccount;
	AddBackLabel(this);

	UI::AddGroup("steam", Vec2f(0.1f, 0.3f), Vec2f(0.9f, 0.65f));
	UI::SetBigSelector();
	UI::Grid(2, 5);
	UI::SetFont("gui");

	UI::TextInput::Add(auth_login, SetAuthLogin, false, 30);
	UI::Label::Add("username");
	UI::TextInput::Add("", SetChangePassword, true, 30);
	UI::Label::Add("password");
	UI::TextInput::Add("", SetChangeConfirmPassword, true, 30);
	UI::Label::Add("confirm password");	
	UI::TextInput::Add("", SetChangeEmail, false, 40);
	UI::Label::Add("e-mail");
	UI::Button::Add("OK", SelectChangeNameDetails);
	UI::Label::Add("login");

	UI::Transition(Vec2f(-1.0f, 0.0f));
	UI::SetSelection(0);
}

string _email = "";
string SetChangeEmail(const string &in caption)
{
	_email = caption;
	return caption;
}

string _changepass = "";
string SetChangePassword(const string &in caption)
{
	_changepass = caption;
	return caption;
}

string _changepass2 = "";
string SetChangeConfirmPassword(const string &in caption)
{
	_changepass2 = caption;
	return caption;
}

void SelectChangeNameDetails(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	if (_changepass == ""){
		UI::Dialog::Add( "Pick a password please.");
		UI::Transition(Vec2f(0.0f, 1.0f));
		return;
	}
	if (_changepass != _changepass2){
		UI::Dialog::Add( "Passwords are not identical. Try again.");
		_changepass = _changepass2 = "";
		UI::Transition(Vec2f(0.0f, 1.0f));
		return;
	}

	@_failCallback = SteamExistingAccount;
	if (!Engine::SteamCreateAccount(auth_login, _email, _changepass)){
		SteamChangeName(this, group, control);
		if (getNet().lastErrorMsg != "")
		{
			//EngineMessage( getNet().lastErrorMsg );
			UI::Dialog::Add( getNet().lastErrorMsg );
			UI::Transition(Vec2f(0.0f, 1.0f));
		}		
	}
}