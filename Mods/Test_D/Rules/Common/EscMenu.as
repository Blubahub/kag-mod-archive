#include "MainMenuCommon.as"
#include "Timers.as"
#include "FirstSetup.as"

void onShowMenu(CRules@ this)
{
//	getHUD().ShowCursor();
	ShowEscMenu(this);
	printf("OPEN MENU");
}

void OnCloseMenu(CRules@ this)
{
	getHUD().HideCursor();
	UI::Clear();
	printf("CLOSE MENU");
}

// -- menus

void BackToEscMenu(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	UI::Transition(group, Vec2f(-1.0f, 0.0f));
	UI::Transition(control, Vec2f(1.0f, 0.0f));
	ShowEscMenu(this);
}

void ShowEscMenu(CRules@ this)
{
	select_area_tl.y = 0.1;

	//bool showNextMap = getNet().isServer() && sv_gamemode != "Lobby";

	UI::Clear();

	AddBackLabel(this);


	UI::SetFont("menu");
	UI::AddGroup("title", Vec2f(0, 0), Vec2f(1.0f, 0.4));
	UI::Grid(1, 1);
	UI::Image::Add("TitleScreen.png");
	UI::AddGroup("escmenu", Vec2f(0.2f, 0.4), Vec2f(0.8, 0.9));

	/*if (sv_gamemode == "Lobby")
	{
		@_backCallback = BackToMainMenu;
		ShowMultiplayerMenu(this, null, null);
	}
	else*/
	{
		@_backCallback = BackToEscMenu;
		//UI::Grid(2, showNextMap ? 3 : 2);
		UI::Grid(2, 2);

		/*if (showNextMap)
		{
			UI::Button::Add("NEXT MAP", NextMapMenu);
	    	 UI::Label::Add("skip current map");
	 	}*/
		UI::Button::Add("OPTIONS", ShowSetupMenu);
		 UI::Label::Add("change settings");
		UI::Button::Add("EXIT TO MENU", NewGame);
		 UI::Label::Add("");
		//UI::Button::Add("QUIT", SelectQuitGame);
		// UI::Label::Add("exit to desktop");
		UI::Transition(Vec2f(-1.0f, 0.0f));
		UI::SetLastSelection(0);
	}
}

void NewGame(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	sv_max_localplayers = 1;
	Reconnect("Main");
}

void BackToFreeBuildEscMenu(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	UI::Transition(group, Vec2f(-1.0f, 0.0f));
	UI::Transition(control, Vec2f(1.0f, 0.0f));
	ShowFreeBuildEscMenu(this);
}

void ShowFreeBuildEscMenu(CRules@ this)
{
	UI::Clear();
	UI::SetFont("menu");
	UI::AddGroup("title", Vec2f(0, 0), Vec2f(1.0f, 0.4));
	UI::Grid(1, 1);
	UI::Image::Add("TitleScreen.png");
	UI::AddGroup("escmenu", Vec2f(0.2f, 0.4), Vec2f(0.8, 1));

	@_backCallback = BackToFreeBuildEscMenu;
	UI::Grid(2, 2);
	UI::Button::Add("RESUME", ResumeGame);
	 UI::Label::Add("keep playing");
	//UI::Button::Add("RETURN TO LOBBY", LaunchGame);
	// UI::Label::Add("");
	UI::Button::Add("QUIT GAME", SelectQuitGame);
	 UI::Label::Add("");
	UI::Transition(Vec2f(-1.0f, 0.0f));
	UI::SetLastSelection(0);
}

void NextMapMenu(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	Game::ClearAllTimers();
	UI::Clear();
	this.SetCurrentState(GAME_OVER);
}


void ShowAdminMenu(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	UI::Transition(group, Vec2f(-1.0f, 0.0f));
	UI::Transition(control, Vec2f(1.0f, 0.0f));
	UI::Clear(group.name);
	UI::AddGroup("admin", Vec2f(0.25f, 0.4), Vec2f(0.75, 1));
	UI::Grid(1, 3);
	UI::Button::Add("Players", ExitToMainMenu);
	UI::Button::Add("Maps", ExitToMainMenu);
	UI::Button::Add("Back", BackToEscMenu);
	UI::Transition(Vec2f(-1.0f, 0.0f));
	UI::SetLastSelection();
}

void ExitToMainMenu(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	@group.data.escape_func = ExitFunction;
}

void ResumeGame(CRules@ this, UI::Group@ group, UI::Control@ control)
{
	UI::Clear();
}

bool ExitFunction( CRules@ this )
{
	CNet@ net = getNet();
	setGameState(GameState::game);
	return net.SafeConnect("localhost:"+sv_port, "Rules/Main/gamemode.cfg");
}

void Website( CRules@ this, UI::Group@ group, UI::Control@ control )
{
	OpenWebsite("https://trenchrun.thd.vg/");
}
