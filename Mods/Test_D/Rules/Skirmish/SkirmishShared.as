#include "ClassesCommon.as"
#include "Timers.as"
#include "GamemodeCommon.as"
#include "SkipScreenCommon.as"

void onInit(CRules@ this)
{
	ClearClasses(this);
	AddClass(this, Soldier::ASSAULT);
	AddClass(this, Soldier::SNIPER);
	AddClass(this, Soldier::ENGINEER);
	AddClass(this, Soldier::COMMANDO);

	this.set_bool("fog of war", false);
	this.set_bool("respawning", false);
	this.set_bool("infinite ammo", false);
	this.set_bool("infinite grenades", false);

	this.set_string("gamemode", "Skirmish");

	this.addCommandID("force start");
	this.addCommandID("force end");

	string[] timers = {
		"scores",
		"warmup",
		"new round"
	};
	SkipScreen::AddSkippable( this, timers );
}

void onStateChange(CRules@ this, const u8 oldState)
{
	const u8 state = this.getCurrentState();

	// start warmup timer

	if (state == WARMUP)
	{
		Game::CreateTimer("warmup", this.get_u32("warmup_secs"), @WarmupEnd, false);
		this.Tag("pause movement");
	}

	if (state == GAME && getPlayersCount() > 0)
	{
		Game::CreateTimer("timeout", this.get_u32("timeout_secs"), @TimeOut, true);
		this.Untag("pause movement");

		// re-enable keys
		// for (uint i = 0; i < getPlayersCount(); i++)
		// {
		// 	CPlayer@ player = getPlayer(i);
		// 	CBlob@ blob = player.getBlob();
		// 	if (blob !is null)
		// 	{
		// 		blob.DisableKeys(0);
		// 	}
		// }
	}

	if (state == GAME_OVER)
	{
		// remove timeout timer if present

		Game::ClearTimer("timeout");

		// disable fire

		// if (!getNet().isServer())
		// {
		// 	for (uint i = 0; i < getPlayersCount(); i++)
		// 	{
		// 		CPlayer@ player = getPlayer(i);
		// 		CBlob@ blob = player.getBlob();
		// 		if (blob !is null)
		// 		{
		// 			blob.DisableKeys(key_action1 | key_action2);
		// 		}
		// 	}
		// }

		// play jingle

		int count, deadcount;
		CalcPlayerCounts(count, deadcount);
	}
}


void WarmupEnd(Game::Timer@ this)
{
	if (getNet().isServer())
	{
		printf("GAME");
		this.rules.SetCurrentState(GAME);
	}
}

void TimeOut(Game::Timer@ this)
{
	if (getNet().isServer())
	{
		printf("GAME_OVER");
		this.rules.SetCurrentState(GAME_OVER);
	}
}
