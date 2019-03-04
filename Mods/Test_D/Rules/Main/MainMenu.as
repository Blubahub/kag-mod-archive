#define ALWAYS_ONRELOAD
#include "MainMenuCommon.as"
#include "Timers.as"
#include "FirstSetup.as"

enum GameMusicTags
{
	main_menu = 0
};

float TITLE_SEC = 1.8f;
int _showTitle = 0;
string[] _TITLES =
{
	"GUI/Title/thd_logo.png",
	"GUI/Title/max_and_michal.png",
	"GUI/Title/title.png"
};

void onInit(CRules@ this)
{
	printf("MAIN INIT");
	LoadMapCycle("Rules/Main/mapcycle.cfg");
	if (getNet().isServer())
	{
		LoadNextMap();
	}
	Reset(this);

	CMixer@ mixer = getMixer();
	if (mixer is null)
		return;

	this.set_string("biome", "default");
	this.set_bool("initialized game", false);
}

void onReload(CRules@ this)
{
	Reset(this);
}

void Reset(CRules@ this)
{
	getDriver().SetShaderFloat("drunk", "amount", 0);

	@_backCallback = FirstSetupEscape;

	if (!_onLocalOrOnlineScreen)
	{
		Game::CreateTimer("title", TITLE_SEC + 0.5f, @TitleEnd, false);
	}

	getHUD().HideCursor();
}

void TitleEnd(Game::Timer@ this)
{
	_showTitle++;
	if (isShowingTitles())
	{
		Game::CreateTimer("title" + _showTitle, TITLE_SEC, @TitleEnd, false);
	}
}

bool isShowingTitles()
{
	return (_showTitle < _TITLES.length);
}

void onShowMenu(CRules@ this)
{
	UI::Data@ data = UI::getData();
	if (data !is null && _backCallback !is null && data.activeGroup !is null)
	{
		_backCallback(this, data.activeGroup, data.activeGroup.activeControl );
	}
}

void OnCloseMenu(CRules@ this)
{
	onShowMenu( this );
}

void onTick(CRules@ this)
{
	// turn music on/of

	CMixer@ mixer = getMixer();
	if (mixer is null)
		return;

	if (s_gamemusic && s_musicvolume > 0.0f)
	{
		if (!this.get_bool("initialized game"))
		{
			this.set_bool("initialized game", true);
			mixer.ResetMixer();
			mixer.AddTrack("Sounds/Music/TR01-Theme.ogg", main_menu);
		}

		if (mixer.getPlayingCount() == 0)
		{
			mixer.FadeInRandom(main_menu, 0.0f);
		}
	}
	else
	{
		mixer.FadeOutAll(0.0f, 2.0f);
	}

	// skip titles

	CControls@ controls = getControls();
	if (isShowingTitles() &&
			(controls.isKeyJustPressed(KEY_SPACE) ||
				controls.isKeyJustPressed(KEY_RETURN) ||
				controls.isKeyJustPressed(KEY_ESCAPE) ||
				controls.ActionKeyPressed(AK_ACTION1) ||
				controls.ActionKeyPressed(AK_ACTION2)))
	{
		_showTitle = 255;
		Game::ClearAllTimers();
	}

	// show menu if its clear

	if (!isShowingTitles() && !UI::hasAnyGroup() && UI::getData() !is null && !controls.ActionKeyPressed(AK_ACTION1) && !Engine::isLoginWindow())
	{
		if (isFirstGameLaunch())
		{
			AskForName(this);
		}
		else
		{
			LocalOrOnline(this);
		}

		HandleFailMessage();
	}
}

void onRender(CRules@ this)
{
	Driver@ driver = getDriver();
	Vec2f screenDim = driver.getScreenDimensions();

	if (isShowingTitles())
	{
		GUI::DrawIcon(_TITLES[_showTitle], 0, Vec2f(568, 320), Vec2f(0, 0), 0.5f);
	}

	if(UI::hasAnyGroup() && (UI::hasGroup( "firstsetup expired" ) || UI::hasGroup( "firstsetup askforname" )) )
	{
		GUI::DrawIcon("TitleScreen.png", 0, Vec2f(512, 128), Vec2f((getScreenWidth()-512)/2,24), 0.5f);
	}
}

