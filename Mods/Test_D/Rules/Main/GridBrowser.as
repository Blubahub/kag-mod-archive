#include "Timers.as"
#include "RankedServers.as"
#include "Steam.as"

APIServer@[] _servers;

string _region;
string _joinAddress;

void ShowGridBrowserInit(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	if (!Engine::isAuthenticated() || !u_agreedterms)
	{
		if (Engine::usesSteam())
		{
			int err = Engine::SteamAuthenticate();
			if (err == 1)
			{
				warn("Not steam linked");
				if (getNet().lastErrorMsg != "")
				{
					EngineMessage( getNet().lastErrorMsg );
				}
				SteamCreateLink(this, group, control);
			}
			else if (err > 1) {
				error("Couldn't auth with Steam");
				if (getNet().lastErrorMsg != "")
				{
					EngineMessage( getNet().lastErrorMsg );
				}
				ShowMultiplayerMenu( this, group, control );
			}
		}
		else
		{
			Login(this, group, control);
		}
		return;
	}

	UI::Clear();

	InitRankedServers();

	CScriptedBrowser@ browser = getBrowser();
	browser.ping = true;
	browser.filter = "";
	browser.RequestList();

	UI::AddGroup("servers downloading", Vec2f(0.1f, 0.0), Vec2f(1, 0.2));
	UI::Grid(1, 1);
	UI::Label::Add("Downloading servers list...");
}

void OnRequestList(CRules@ this)
{
	CScriptedBrowser@ browser = getBrowser();
	_servers.clear();
	browser.getServersList(_servers);

	ShowRegions(this, null, null);
}

void AddBack(CRules@ this)
{
	UI::AddGroup("back", Vec2f(0.0f, 0.9f), Vec2f(1.0f, 0.99f));
	UI::SetFont("hud");
	UI::Grid(1, 1);
	UI::SetSmallSelector();
	UI::Button::Add("BACK", _backCallback);
	UI::Transition(Vec2f(0.0f, -1.0f));
}

void AddBackLabel(CRules@ this)
{
	UI::AddGroup("back", Vec2f(0.0f, 0.9f), Vec2f(1.0f, 0.99f));
	UI::SetFont("hud");
	UI::Grid(1, 1);
	UI::Label::Add("<< BACK [ESC]");
	UI::Transition(Vec2f(0.0f, -1.0f));
}

void AddOptionsLabel(CRules@ this)
{
	UI::AddGroup("back", Vec2f(0.0f, 0.9f), Vec2f(1.0f, 0.99f));
	UI::SetFont("hud");
	UI::Grid(1, 1);
	UI::Label::Add("OPTIONS [ESC]");
	UI::Transition(Vec2f(0.0f, -1.0f));
}

//string _gridIcons = "Sprites/UI/gridicons.png";
string _gridIcons = "Sprites/UI/grid_notop_icons.png";
Vec2f _gridIconSize(64, 128);

void ShowRegions(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	UI::Clear();
	@_backCallback = LocalOrOnline;

	// back

	AddBackLabel(this);

	// regions

	UI::AddGroup("regions grid", Vec2f(0.05f, 0.4f), Vec2f(0.95f, 0.6f), _gridIcons, _gridIconSize);
	UI::SetFont("intro");
	UI::Grid(3, 1);
	UI::SetNoSelector();

	UI::Control@ serverButton;

	// caption1 is used to determine region!

/*	@serverButton = UI::Button::Add("", SelectUnranked, GridButtonRender, GridRenderCaption, false, 0.5f, 3);
	serverButton.vars.set("caption1", "Unranked");
	serverButton.vars.set("caption2", "");
	serverButton.vars.set("icon", 3);
	serverButton.vars.set("description", "Browse unranked servers");
	serverButton.vars.set("players", "" + getUnrankedPlayersCount());*/

	@serverButton = UI::Button::Add("", SelectRegion, GridButtonRender, GridRenderCaption, false, 0.5f, 3);
	serverButton.vars.set("caption1", "AUS");
	serverButton.vars.set("caption2", "");
	serverButton.vars.set("icon", 17);
	serverButton.vars.set("description", "Join region");
	serverButton.vars.set("players", "" + getRankedPlayersCount("AUS"));

	@serverButton = UI::Button::Add("", SelectRegion, GridButtonRender, GridRenderCaption, false, 0.5f, 3);
	serverButton.vars.set("caption1", "EU");
	serverButton.vars.set("caption2", "");
	serverButton.vars.set("icon", 15);
	serverButton.vars.set("description", "Join region");
	serverButton.vars.set("players", "" + getRankedPlayersCount("EU"));

	@serverButton = UI::Button::Add("", SelectRegion, GridButtonRender, GridRenderCaption, false, 0.5f, 3);
	serverButton.vars.set("caption1", "USA");
	serverButton.vars.set("caption2", "");
	serverButton.vars.set("icon", 16);
	serverButton.vars.set("description", "Join region");
	serverButton.vars.set("players", "" + getRankedPlayersCount("USA"));

	UI::SetLastSelection(-1);
}

void SelectUnranked(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	UI::Clear();
	@_backCallback = ShowRegions;

	// filter ranked servers
	APIServer@[] filtered;
	string ipport;
	bool isRanked;
	for (uint i = 0; i < _servers.length; i++)
	{
		APIServer@ server = _servers[i];
		ipport = getServerIPandPort(server);
		isRanked = false;
		for (uint ii = 0; ii < _rankedServers.length; ii++)
		{
			//print("comapre " + ipport + " < " + _rankedServers[ii].address_and_port + " | " + server.description);
			if (_rankedServers[ii].address_and_port == ipport || isRankedServer(server))
			{
				isRanked = true;
				break;
			}
		}

		if (!isRanked)
		{
			filtered.push_back(server);
		}
	}

	ListServers(this, filtered);
}

void SelectRegion(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	control.vars.get("caption1", _region);
	UI::Clear();
	ShowGridBrowser(this, _servers);
}

void ShowGridBrowser(CRules@ this, APIServer@[]@ servers)
{
	UI::Clear();
	@_backCallback = ShowRegions;

	// back

	AddBackLabel(this);

	AddGridBrowser(servers);
}

// grid button

const string _serverIcons = "Sprites/UI/lobby_icons.png";
Vec2f _serverIconSize(48, 48);

void GridButtonRender(UI::Proxy@ proxy)
{
	if (proxy !is null && proxy.control !is null && proxy.frames.length > 0)
	{
		GUI::DrawIcon(proxy.image, proxy.frames[0], proxy.imageSize, (proxy.ul + proxy.lr) / 2 - proxy.imageSize / 2, 0.5f);

		int serverIcon;
		proxy.control.vars.get("icon", serverIcon);

		GUI::DrawIcon(_serverIcons, serverIcon, _serverIconSize, (proxy.ul + proxy.lr) / 2 - _serverIconSize / 2 + Vec2f(0.0f, -8.0f), 0.5f);

		if (proxy.selected)
		{
			if (proxy.group.iconFilename.find("notop") == -1)
				GUI::DrawIcon("Sprites/UI/region_grid_selector.png", 0, Vec2f(96, 96), (proxy.ul + proxy.lr) / 2 - _serverIconSize / 2 + Vec2f(-24.0f, -25.0f), 0.5f);
			else
				GUI::DrawIcon("Sprites/UI/region_grid_notop_selector.png", 0, Vec2f(96, 96), (proxy.ul + proxy.lr) / 2 - _serverIconSize / 2 + Vec2f(-24.0f, -25.0f), 0.5f);
		}
	}
}

void GridRenderCaption(UI::Proxy@ proxy)
{
	if (proxy.control !is null)
	{
		Vec2f dim, pos;
		string players;
		string caption, caption2;

		// playres count

		if (!GUI::isFontLoaded("grid_pcount"))
		{
			GUI::LoadFont("grid_pcount", "GUI/Fonts/grid/pcount.ttf", 8, true);
		}
		if (!GUI::isFontLoaded("grid_pcount_big"))
		{
			GUI::LoadFont("grid_pcount_big", "GUI/Fonts/grid/pcount_big.ttf", 12, true);
		}

	/*	proxy.control.vars.get("players", players);
		if (players != "")
		{
			caption = "" + players;
			GUI::GetTextDimensions(caption, dim);
			pos.x = (proxy.ul.x + proxy.lr.x) / 2 - 2;
			pos.y = proxy.ul.y - 5;

			if (proxy.selected)
			{
				GUI::SetFont("grid_pcount_big");
				pos.y -= 2;
			}
			else
			{
				GUI::SetFont("grid_pcount");
			}

			GUI::DrawTextCentered(caption, pos, proxy.disabled ? UI::CAPTION_DISABLE_COLOUR : proxy.selected ? UI::CAPTION_HOVER_COLOR : UI::CAPTION_COLOR);
		}*/

		// server name
		GUI::SetFont("grid_pcount_big");

		proxy.control.vars.get("caption1", caption);
		proxy.control.vars.get("caption2", caption2);

		GUI::GetTextDimensions(proxy.caption, dim);
		pos = proxy.lr;
		pos.x = (proxy.ul.x + proxy.lr.x) / 2 - 2;
		pos.y -= dim.y / 2;
		GUI::DrawTextCentered(caption, pos, proxy.disabled ? UI::CAPTION_DISABLE_COLOUR : proxy.selected ? UI::CAPTION_HOVER_COLOR : UI::CAPTION_COLOR);

		pos.y += dim.y - 4;
		GUI::DrawTextCentered(caption2, pos, proxy.disabled ? UI::CAPTION_DISABLE_COLOUR : proxy.selected ? UI::CAPTION_HOVER_COLOR : UI::CAPTION_COLOR);

		// description
		if (proxy.selected)
		{
			string description;
			proxy.control.vars.get("description", description);
			pos.x = getDriver().getScreenWidth() / 2;
			pos.y = 5.0f;
			GUI::DrawTextCentered(description, pos, UI::CAPTION_HOVER_COLOR);
		}
	}
}

void AddGridBrowser(APIServer@[]@ servers)
{
	UI::AddGroup("multigrid", Vec2f(0.05f, 0.4f), Vec2f(0.95f, 0.6f), _gridIcons, _gridIconSize);
	UI::SetFont("intro");
	UI::Grid(_rankedServers.length, 1);
	UI::SetNoSelector();

	// count servers

	RankedServer@[] found_servers;

	// find servers from testservers in downloaded servers

	for (uint i = 0; i < servers.length; i++)
	{
		APIServer@ server = servers[i];
		string address_and_port = server.serverIPv4Address + ":" + server.serverPort;
		printf(i + " " + address_and_port + " " + server.gameMode + " " + server.serverName + " | " + server.description);

		// filter from testservers
		RankedServer @rankedServer;
		for (uint i = 0; i < _rankedServers.length; i++)
		{
			RankedServer @test = _rankedServers[i];
			if (test.address_and_port == address_and_port
			        && (_region == "" || test.region == "" || _region == test.region)) // region match
			{
				@rankedServer = test;
				break;
			}
		}

		if (rankedServer is null)
			continue;

		// players count
		string playersStr = server.description.substr(server.description.find("PLAYERS: ") + 9, server.description.length);

		rankedServer.players = playersStr;

		found_servers.push_back(rankedServer);
	}

	//no servers ?  add labels
	if (found_servers.length() == 0)
	{
		UI::AddGroup("no servers", Vec2f(0.1f, 0.0), Vec2f(1, 0.2));
		UI::Grid(1, 1);
		UI::Label::Add("There are currently no servers in this region. Try again later.");
	}

	// push servers from testservers on to the grid

	while (!found_servers.empty())
	{
		// select in order of testservers
		RankedServer @rankedServer = null;
		for (uint i = 0; i < _rankedServers.length && rankedServer is null; i++)
		{
			RankedServer @aim = _rankedServers[i];
			for (uint j = 0; j < found_servers.length && rankedServer is null; j++)
			{
				RankedServer @test = found_servers[j];
				if (test.address_and_port == aim.address_and_port)
				{
					@rankedServer = test;
					found_servers.removeAt(j);
				}
			}
		}

		if (rankedServer is null)
			break;

		UI::Control@ serverButton = UI::Button::Add("", rankedServer.selectFunc, GridButtonRender, GridRenderCaption, false, 0.5f, rankedServer.background);

		serverButton.vars.set("address", rankedServer.address_and_port);

		serverButton.vars.set("caption1", rankedServer.caption1);
		serverButton.vars.set("caption2", rankedServer.caption2);

		serverButton.vars.set("icon", rankedServer.icon);
		serverButton.vars.set("description", rankedServer.description);

		serverButton.vars.set("players", rankedServer.players);
	}

	UI::Transition(Vec2f(0.0f, 1.0f));
}

void SelectServer(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	print("Browser join: " + control.caption);
	control.vars.get("address", _joinAddress);
	@group.data.escape_func = ExitAndConnect;
}

void ShowConnectTo(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	@_backCallback = ShowGridBrowserInit;
	Vec2f select_area_tl(0.2f, 0.4f);
	Vec2f select_area_br(0.8f, 0.9f);
	UI::Transition(group, Vec2f(-1.0f, 0.0f));
	UI::Transition(control, Vec2f(1.0f, 0.0f));
	UI::Clear();
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

bool ExitAndConnect(CRules@ this)
{
	CNet@ net = getNet();
	cl_joinaddress = _joinAddress;
	return net.SafeConnect(_joinAddress);
}


// AUTHENTICATION MENUS

void Login(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	UI::Clear();

	@_backCallback = LocalOrOnline;
	AddBackLabel(this);

	UI::AddGroup("login options", Vec2f(0.1f, 0.03f), Vec2f(0.9f, 0.3f));
	UI::SetThinSelector();
	UI::Grid(2, 5);
	UI::SetFont("gui");


	UI::Button::Add("New Account", SelecNewAccount);
	UI::Label::Add("no TR, KAG or THD account?");
	UI::Button::Add("Forgot?", SelectForgot);
	UI::Label::Add("reset password or remind name");
	UI::Toggle::Add("Remember me", SetRememberMe, auth_remember);
	UI::Label::Add("save credentials for next time");
	UI::Label::Add("");
	UI::Label::Add("");
	UI::Label::Add("Use your Trench Run, King Arthur's Gold or THD account credentials");
	UI::Label::Add("");

	UI::Transition(Vec2f(0.0f, 1.0f));


	UI::AddGroup("login", Vec2f(0.1f, 0.4f), Vec2f(0.9f, 0.85f));
	UI::SetFont("menu");
	UI::SetBigSelector();
	UI::Grid(2, 3);

	UI::TextInput::Add(auth_login, SetAuthLogin, false, 30);
	UI::Label::Add("your account name");
	UI::TextInput::Add(Engine::getAuthPasswordDummy(), SetAuthPassword, true, 30);
	UI::Label::Add("your account password");
	UI::Button::Add("OK", SelectLogin);
	UI::Label::Add("login");

	UI::Transition(Vec2f(-1.0f, 0.0f));
	UI::SetSelection(-1);
}

string SetAuthLogin(const string &in caption)
{
	auth_login = caption;
	return caption;
}

string SetAuthPassword(const string &in caption)
{
	Engine::SetAuthPassword(caption);
	return caption;
}

void SelectLogin(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	UI::Clear();
	UI::AddGroup("authenticating", Vec2f(0.1f, 0.0), Vec2f(1, 0.2));
	UI::Grid(1, 1);
	UI::Label::Add("");


	@_failCallback = Login;
	Engine::Authenticate();
}

void SelectForgot(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	Engine::GoToForgot();
}

void SelecNewAccount(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	Engine::GoToNewAccount();
}

bool isRankedServer(APIServer@ server)
{
	return server.description.find("RANKED") != -1;
}

string getServerIPandPort(APIServer@ server)
{
	return server.serverIPv4Address + ":" + server.serverPort;
}

uint getUnrankedPlayersCount()
{
	uint players = 0;
	for (uint i = 0; i < _servers.length; i++)
	{
		APIServer@ server = _servers[i];
		string ipport = getServerIPandPort(server);
		if (!isRankedServer(server))
		{
			players += server.currentPlayers;
		}
	}
	return players;
}

uint getRankedPlayersCount(const string &in region)
{
	uint players = 0;
	for (uint i = 0; i < _servers.length; i++)
	{
		APIServer@ server = _servers[i];
		string ipport = getServerIPandPort(server);
		for (uint ii = 0; ii < _rankedServers.length; ii++)
		{
			RankedServer@ ranked = _rankedServers[ii];
			if (ranked.region == region && ranked.address_and_port == ipport)
			{
				players += server.currentPlayers;
				break;
			}
		}
	}
	return players;
}
