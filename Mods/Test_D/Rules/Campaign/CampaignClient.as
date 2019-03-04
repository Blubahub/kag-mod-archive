#define CLIENT_ONLY

#include "DrawScores.as"
#include "Menus.as"
#include "Timers.as"
#include "GamemodeCommon.as"
#include "DrawScores.as"
#include "CampaignCommon.as"

void onStateChange( CRules@ this, const u8 oldState )
{
	const u8 state = this.getCurrentState();

	for (uint i=0; i < getPlayersCount(); i++)
	{
    	CPlayer@ player = getPlayer(i);
    	Menus::Clear(player);
    }
}

void onTick(CRules@ this)
{
	// ping sound 10,9,8,...

	Game::Timer@ timer = Game::getTimer("timeout");
	if (timer !is null)
	{
		const u32 time = getGameTime();
		if (time % getTicksASecond() == 18 && timer.endTime - time < 6 * getTicksASecond())
		{
			if (timer.endTime - time > 29)
				Sound::Play("TimePing");
			else
				Sound::Play("TimeoutPing");
		}
	}

	// status

	string status = "";
	if (this.hasTag("use_backend"))
	{
		if (this.isIntermission())
		{
			if (this.hasTag("backend_game_started"))
			{
				status = "Waiting for all players to load the map";
			}
			else
			{
				//status = "Waiting for all players to join";
				status ="";
			}
		}
	}
	this.set_string("scrolling text", status);
}

void onRender(CRules@ this)
{
	if (this.get_s16("in menu") != 0)
		return;

	if (this.isGameOver())
	{
		Campaign::Data@ data = Campaign::getCampaign(this);
		if (data.battleIndex < 0 || data.battleIndex > data.battles.length - 1)
		{
			DrawCampaignScores(this, this.getTeamWon(), true );
			return;
		}
	}
}
