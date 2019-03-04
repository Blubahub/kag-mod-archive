// SERVERS BROWSER
// requires GridBrowser.as

uint _maxServers = 20;
uint _maxFilterPlayers = 32;


/*
void ShowBrowser(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	if (!sv_test && !Engine::isAuthenticated())
	{
		UI::Clear();
		Engine::ShowLoginWindow();
		getHUD().ShowCursor();
		return;
	}

	CScriptedBrowser@ browser = getBrowser();
	browser.ping = true;
	browser.filter = "";
	browser.RequestList();

	if (group !is null)
	{
		UI::Transition(group, Vec2f(-1.0f, 0.0f));
		UI::Transition(control, Vec2f(1.0f, 0.0f));
		UI::Clear(group.name);
	}
	UI::Clear("title");
	UI::Clear("multigrid");
	UI::SetFont("hud");

	UI::AddGroup("servers downloading", Vec2f(0.0f, 0.0), Vec2f(1, 1));
	UI::Grid(1, 1);
	UI::Label::Add("Downloading servers list...");
}

void CloseBrowser(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	getBrowser().Close();
	_backCallback(this, group, control);
}

uint _maxServers = 20;
uint _maxFilterPlayers = 32;
APIServer@[] servers;

void OnRequestList(CRules@ this)
{
	CScriptedBrowser@ browser = getBrowser();
	servers.clear();
	browser.getServersList(servers);

	ListServers(this, servers);
}
*/
void ListServers(CRules@ this, APIServer@[]@ servers)
{
	// create menu

	UI::Clear("servers downloading");
	UI::Clear("browser options");
	UI::Clear("browser sort");
	UI::Clear("browser mode");
	UI::Clear("browser");
	UI::Clear("browser menu");
	UI::Clear("filters");

	f32 x = 0.01f;
	f32 x2 = 1.06f;
	f32 y = 0.02f;
	f32 yHeight = 0.035f;
	f32 detailsOffsetScale = 1.701333111145f;

	UI::AddGroup("browser labels", Vec2f(x, y), Vec2f(x2, y + yHeight));
		UI::Grid(1, 1);
		UI::Label::Add("Name:");
	UI::AddGroup("browser labels 2", Vec2f(x2/detailsOffsetScale, y), Vec2f(x2, y + yHeight)); 
		UI::Grid(3, 1);
		UI::Label::Add("Players:");
		UI::Label::Add("Gamemode:");
		UI::Label::Add("Ping:");

	y += 1 * yHeight;		

	UI::Group@ serversGroup = UI::AddGroup("browser", Vec2f(x, y), Vec2f(x2/detailsOffsetScale, 0.85f));
		UI::Grid(1, _maxServers);
		UI::SetThinSelector();
		ListServersAdd(serversGroup, servers, 0);

	UI::Group@ detailsGroup = UI::AddGroup("browser details", Vec2f(x2/detailsOffsetScale, y), Vec2f(x2, 0.85f));
		UI::Grid(3, _maxServers);
		ListServersDetailsAdd(detailsGroup, servers, 0);

	// back

	const bool requiresScrolling = servers.length > _maxServers;

	UI::AddGroup("browser menu", Vec2f(x, 0.85f + yHeight), Vec2f(x2, 0.99f));
		UI::Grid(1, 2 + (requiresScrolling ? 1 : 0));
		UI::SetSmallSelector();

		//UI::Button::Add("FILTERS", FilterServersMenu, UI::Button::SmallRender, UI::Button::RenderCaption);
		if (requiresScrolling)
		{
			UI::Slider::Add("BROWSE ", UpdateServers, UI::Slider::SmallRender, UI::Slider::RenderCaption, 0, 1, 0, servers.length - 1, "/");
		}
		UI::Button::Add("BACK", _backCallback, UI::Button::SmallRender, UI::Button::RenderCaption);

	UI::SetSelection(-1);
}

void ListServersAdd(UI::Group@ group, APIServer@[]@ servers, const int index)
{
	UI::Group@ oldGroup = group.data.activeGroup;
	@group.data.activeGroup = group;

	// add servers
	for (uint i = index; i < index + _maxServers; i++)
	{
		if (i < servers.length)
		{
			APIServer@ server = servers[i];
			string name = server.serverName;
			name.resize(Maths::Min(name.length, 45));
			UI::Control@ serverButton = UI::Button::Add(name, SelectBrowserServer);
			serverButton.vars.set( "address", server.serverIPv4Address + ":" + server.serverPort );
		}
		else
		{
			UI::Label::Add("-");
		}
	}
	UI::Transition(Vec2f(-1.0f, 0.0f));
	@group.data.activeGroup = oldGroup;
}

void ListServersDetailsAdd(UI::Group@ group, APIServer@[]@ servers, const int index)
{
	UI::Group@ oldGroup = group.data.activeGroup;
	@group.data.activeGroup = group;

	// add servers
	for (uint i = index; i < index + _maxServers; i++)
	{
		if (i < servers.length)
		{
			APIServer@ server = servers[i];
			UI::Label::Add("" + server.currentPlayers + "/" + server.maxPlayers);
			UI::Label::Add(server.gameMode);
			UI::Label::Add("" + server.ping);
		}
		else
		{
			UI::Label::Add("-");
			UI::Label::Add("-");
			UI::Label::Add("-");
		}
	}
	UI::Transition(Vec2f(-1.0f, 0.0f));
	@group.data.activeGroup = oldGroup;
}

void SelectBrowserServer(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	print("Browser join: " + control.caption);
	CNet@ net = getNet();
	net.DisconnectClient();
	net.DisconnectServer();
	string address;
	control.vars.get( "address", address );
	net.Connect(address);
}

float UpdateServers(float value)
{
	/*CScriptedBrowser@ browser = getBrowser();
	_servers.clear();
	browser.getServersList(servers);*/

	UI::Data@ data = UI::getData();
	const int index = value * _servers.length;
	//printf( "index " + index +" / " + servers.length);
	UI::Group@ group = UI::getGroup(data, "browser");
	UI::ClearGroup(group);
	ListServersAdd(group, _servers, index);

	@group = UI::getGroup(data, "browser details");
	UI::ClearGroup(group);
	ListServersDetailsAdd(group, _servers, index);

	return value;
}

float SetMinPlayers(float value)
{
	g_filterplayerlower = Maths::Round(value * _maxFilterPlayers);
	return value;
}

float SetMaxPlayers(float value)
{
	g_filterplayerupper = Maths::Round(value * _maxFilterPlayers);
	return value;
}

int SetModded(int option)
{
	g_filtergold = option;
	return option;
}

int SetPassworded(int option)
{
	g_filterpass = option;
	return option;
}
/*
void FilterServersMenu(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	UI::Clear("browser labels");
	UI::Clear("browser menu");
	UI::Clear("browser");

	CControls@ controls = getControls();
	UI::Transition(group, Vec2f(-1.0f, 0.0f));
	UI::Transition(control, Vec2f(1.0f, 0.0f));
	UI::Clear(group.name);

	UI::AddGroup("filters", select_area_tl, select_area_br);
		UI::Grid(2, 5);

		UI::Option::Add("Modded|Unmodded|N/A", SetModded, g_filtergold);
		UI::Label::Add("show vanilla/modded]");
		UI::Option::Add("Passworded|Non passworded|N/A", SetPassworded, g_filterpass);
		UI::Label::Add("show passworded]");
		UI::Slider::Add("Min Players", SetMinPlayers, g_filterplayerlower, 1, 0, _maxFilterPlayers);
		UI::Label::Add("show only with mininum players]");
		UI::Slider::Add("Max Players", SetMaxPlayers, g_filterplayerupper, 1, 0, _maxFilterPlayers);
		UI::Label::Add("show only with maximum players]");

		UI::Button::Add("BACK", ShowBrowser);
		UI::Label::Add("to browser]");

	UI::SetLastSelection();
}*/