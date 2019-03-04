#include "UI.as"
#include "DebugButton.as"
#include "SoldierCommon.as"
#include "ClassesCommon.as"
#include "Timers.as"

const string DEBUGMENU = "debugmenu";
Vec2f debugMenuOffset = Vec2f(0.9f, 0.75f);

void onInit(CRules@ this)
{
}

void onReload(CRules@ this)
{
	UI::Clear(DEBUGMENU);
}

void onTick(CRules@ this)
{
	CBlob@ blob = getLocalPlayerBlob();
	CControls@ controls = getControls();

	if (blob !is null)
	{
		DebugBlog(this, blob, controls);
	}

	// menu

	if (controls.isKeyJustPressed(KEY_BACK))
	{
		if (UI::hasAnyGroup())  // refacotr?
		{
			UI::Clear(DEBUGMENU);
			UI::Clear(DEBUGMENU);
		}
		else
		{
			Show(this);
		}
	}
}

void DebugBlog(CRules@ this, CBlob@ blob, CControls@ controls)
{
	Soldier::Data@ data = Soldier::getData(blob);

	if (controls.isKeyJustPressed(KEY_KEY_R))
	{
		data.grenades = data.initialGrenades;
		data.ammo = data.initialAmmo;
		printf("reload");
	}

	if (controls.isKeyJustPressed(KEY_KEY_K))
	{
		blob.Damage(1.0f, blob);
	}
}


void Show(CRules@ this)
{
	UI::AddGroup(DEBUGMENU, debugMenuOffset, Vec2f(1, 1));
	UI::Grid(1, 5);
	UI::Debug::AddButton("Fill bots", FillBotsMenu);
	UI::Debug::AddButton("Blue bot", AddBotMenu);
	UI::Debug::AddButton("Red bot", AddBotMenu);
	UI::Debug::AddButton("Player", ShowPlayerMenu);
	//UI::Debug::AddButton("Campaign", CampaignMenu);
	UI::Debug::AddButton("Close", Close);
}

void BackToDebugMenu(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	UI::Clear(group.name);
	Show(this);
}

void Close(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	UI::Clear(DEBUGMENU);
}

void FillBotsMenu(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	// 1
	AddBot(ENGLISH_NAMES[ _namesrandom.NextRanged(ENGLISH_NAMES.length) ], 0, 2);

	// 2
	AddBot(ENGLISH_NAMES[ _namesrandom.NextRanged(ENGLISH_NAMES.length) ], 1, 0);
	AddBot(ENGLISH_NAMES[ _namesrandom.NextRanged(ENGLISH_NAMES.length) ], 1, 2);
}

void AddBotMenu(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	const u8 team = button.caption == "Blue bot" ? 0 : 1;
	AddBotMenu(this, team);
}

void AddBotMenu(CRules@ this, const u8 team)
{
	UI::Clear(DEBUGMENU);
	UI::AddGroup("addbot" + team, debugMenuOffset, Vec2f(1, 1));
	UI::Grid(1, CLASS_COUNT + 1);
	for (uint i = 0; i < CLASS_COUNT; i++)
	{
		UI::Debug::AddButton(CLASS_NAMES[i], Class);
	}
	UI::Debug::AddButton("Back", BackToDebugMenu);
	UI::SetSelection(-1);
}

void Class(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	CPlayer@ bot = AddBot(ENGLISH_NAMES[ _namesrandom.NextRanged(ENGLISH_NAMES.length) ],
	                      group.name == "addbot0" ? 0 : 1, getClassIndexByName(button.caption));
	UI::Clear(group.name);
	UI::Clear(DEBUGMENU);
}

void ShowPlayerMenu(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	UI::Clear(group.name);
	UI::AddGroup(DEBUGMENU, debugMenuOffset, Vec2f(1, 1));
	UI::Grid(1, 3);
	UI::Debug::AddButton("Respawn", Respawn);
	UI::Debug::AddButton("Suicide", Suicide);
	UI::Debug::AddButton("Back", BackToDebugMenu);
	UI::SetSelection(-1);
}

void Suicide(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	UI::Clear(group.name);
	CBlob@ blob = getLocalPlayerBlob();
	if (blob !is null)
	{
		blob.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), blob.getInitialHealth(), 0);
	}
}

void Respawn(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	UI::Clear(group.name);
	CBlob@ blob = getLocalPlayerBlob();
	if (blob !is null)
	{
		blob.server_Die();
	}
}
/*
void CampaignMenu(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	const bool match = this.isMatchRunning();
	UI::Clear(group.name);
	UI::AddGroup(DEBUGMENU, debugMenuOffset, Vec2f(1, 1));
	UI::Grid(1, match ? 4 : 2);
	if (match)
	{
		UI::Debug::AddButton("Red win", RedWin);
		UI::Debug::AddButton("Blue win", BlueWin);
	}
	UI::Debug::AddButton("Next map", NextMap);
	UI::Debug::AddButton("Back", BackToDebugMenu);
	UI::SetSelection(-1);
}

*/
void TeamWin(CRules@ this, const int team)   // REFACTOR also in frontline.as
{
	this.SetTeamWon(team);   //game over!
	this.set_u8("won team", team);
	this.SetCurrentState(GAME_OVER);
}

void NextMap(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	if (this.isWarmup())
	{
		Game::FireTimer("game");
	}
	else if (this.isIntermission())
	{
		Game::FireTimer("intermission");
	}
	else if (this.isGameOver())
	{
		Game::FireTimer("gameover");
	}
	else if (this.isMatchRunning())
	{
		Game::FireTimer("timeout");
	}
}

void RedWin(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	TeamWin(this, 1);
}

void BlueWin(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	TeamWin(this, 0);
}