#define CLIENT_ONLY

#include "DrawScores.as"
#include "Menus.as"
#include "Timers.as"
#include "GamemodeCommon.as"
#include "PlayerStatsCommon.as"

int _gameOverTime = 0;

void onStateChange(CRules@ this, const u8 oldState)
{
	const u8 state = this.getCurrentState();

	// local clear menus
	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		Menus::Clear(player);
	}

	/*_gameOverTime = 0;
	
	if (state == GAME_OVER)
	{
		if (isScoreReached(this.get_u32("score_cap"))) 
		{
			_gameOverTime = getGameTime(); // show awards
		}
	}*/
}

void onTick(CRules@ this)
{
	// check deaths

	int count, deadcount;
	CalcPlayerCounts(count, deadcount);

	// all dead or one survivor

	if (count > 1 && deadcount >= count - 1)
	{
	}
	else
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
	else
	{
		if (!this.isIntermission())
		{
			CPlayer@ player = getLocalPlayer();
			if (player !is null)
			{
				if (player.getBlob() is null)
				{
					status = "Waiting for round end to join";
				}
			}
		}
	}
	this.set_string("scrolling text", status);

	// scroll awards

	if (this.isGameOver())
	{
		_awardsPos -= _awardScrollSpeed;
	}
}

string[] _WARMUP_STRINGS =
{
	"GO!",
	"STEADY",
	"READY"
};


void onRender(CRules@ this)
{
	if (this.isGameOver())
	{
		const u32 score_cap = this.get_u32("score_cap");

		DrawScores(this, score_cap, isScoreReached(score_cap));
		return;
	}

	if (this.isWarmup())
	{
		Game::Timer@ timer = Game::getTimer("warmup");
		if (timer !is null && this.get_s16("in menu") == 0)
		{
			GUI::SetFont("menu");
			const s32 secsLeft = Maths::Min(Game::getTimerSecondsLeft(timer), _WARMUP_STRINGS.length);
			//print("secsLeft " + secsLeft);
			GUI::DrawTextCentered(_WARMUP_STRINGS[secsLeft - 1],
			                      Vec2f(getScreenWidth() / 2, 120),
			                      color_white);
		}
	}
}

