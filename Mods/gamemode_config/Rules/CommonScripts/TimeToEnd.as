//Rules timer!
#include "TeamColour.as";
// Requires game_end_time set originally

void onInit(CRules@ this)
{
	if (!this.exists("no timer"))
		this.set_bool("no timer", false);
	if (!this.exists("game_end_time"))
		this.set_u32("game_end_time", 0);
	if (!this.exists("gametime"))
		this.set_u32("gametime", 0);
		
	this.set_u8("num_extensions", 0);
}

void onRestart(CRules@ this)
{
	onInit(this);
}

void onTick(CRules@ this)
{
	if (!getNet().isServer() || !this.isMatchRunning() || this.get_bool("no timer"))
	{
		return;
	}

	u32 gameEndTime = this.get_u32("game_end_time");
	u8 num_extensions = this.get_u8("num_extensions");

	if (gameEndTime == 0) return; //-------------------- early out if no time.

	if (getGameTime() > gameEndTime)
	{
		bool hasWinner = false;
		s8 team_wins_on_end = -1;
		s8 team_wins_by_ticks = -1;

		if (this.exists("team_wins_on_end"))
		{
			team_wins_on_end = this.get_s8("team_wins_on_end");
		}

		if (this.exists("team_wins_by_ticks"))
		{
			team_wins_by_ticks = this.get_s8("team_wins_by_ticks");
		}

		if(team_wins_on_end >= 0)
		{
			this.SetTeamWon(team_wins_on_end);
			CTeam@ teamWon = this.getTeam(team_wins_on_end);

			if (teamWon !is null)
			{
				hasWinner = true;
				u32 ticksittooktotakethelead = team_wins_on_end == 0 ? this.get_u32("blue_ticksittooktotakethelead") : this.get_u32("red_ticksittooktotakethelead");
				u32 otherticksittooktotakethelead = team_wins_on_end == 1 ? this.get_u32("blue_ticksittooktotakethelead") : this.get_u32("red_ticksittooktotakethelead");
				
				this.SetGlobalMessage("Time is up!\n" + teamWon.getName() + " wins the game!");
				getNet().server_SendMsg(teamWon.getName() + " won the game in " + u32((getGameTime()/30.0f)/60.0f) + " minutes and " + u32((getGameTime()/30.0f)%60) + " seconds. (" + getGameTime() + " ticks)");
				//if(otherticksittooktotakethelead != 0)
					getNet().server_SendMsg("It took " + teamWon.getName() + " " + ticksittooktotakethelead + " ticks it to take the lead");
				getNet().server_SendMsg(teamWon.getName() + " also had " + (team_wins_on_end == 0 ? this.get_u32("blueticks") : this.get_u32("redticks")) + " ticks past middle.");
			}
		}
		else if (team_wins_by_ticks >= 0 && num_extensions == 2)
		{
			//ends the game and sets the winning team
			this.SetTeamWon(team_wins_by_ticks);
			CTeam@ teamWon = this.getTeam(team_wins_by_ticks);

			if (teamWon !is null)
			{
				hasWinner = true;
				this.SetGlobalMessage("Time is up!\n" + teamWon.getName() + " wins the game!");
				getNet().server_SendMsg(teamWon.getName() + " won the game with " + (team_wins_by_ticks == 0 ? this.get_u32("blueticks") : this.get_u32("redticks")) + " ticks past middle.");
			}
		}
		else
		{
			getNet().server_SendMsg("10 minutes will be added to the timer. There are " + (1-num_extensions) + " time extensions left.");
			if(sv_test)
				this.set_u32("game_end_time", gameEndTime+(1*60*30));
			else
				this.set_u32("game_end_time", gameEndTime+(10*60*30));
			
			this.set_u8("num_extensions", num_extensions+1);
		}
		
		if(hasWinner)
			this.SetCurrentState(3);
	}
	else if(getGameTime() % 29 == 0)
	{
		this.set_u32("gametime", getGameTime());
		this.set_u32("game_end_time", gameEndTime);
		this.Sync("gametime", true);
		this.Sync("game_end_time", true);
	}
}

void onRender(CRules@ this)
{
	if (!this.isMatchRunning()) return;

	u32 gameEndTime = this.get_u32("game_end_time");
	u32 currentTime = this.get_u32("gametime");

	if (gameEndTime > 0 && gameEndTime > currentTime)
	{
		s32 timeToEnd = s32(gameEndTime - currentTime) / 30;

		s32 secondsToEnd = timeToEnd % 60;
		s32 MinutesToEnd = timeToEnd / 60;
		drawRulesFont("Time left: " + ((MinutesToEnd < 10) ? "0" + MinutesToEnd : "" + MinutesToEnd) + ":" + ((secondsToEnd < 10) ? "0" + secondsToEnd : "" + secondsToEnd),
		              SColor(255, 255, 255, 255), Vec2f(10, 140), Vec2f(getScreenWidth() - 20, 180), true, false);
	}

	GUI::DrawText( "Total Seconds Past Middle:", Vec2f(345,getScreenHeight()-100), color_white );
	GUI::DrawText( ""+u32(this.get_u32("redticks")/30.0f), Vec2f(430,getScreenHeight()-80), getTeamColor(1) );
	GUI::DrawText( ""+u32(this.get_u32("blueticks")/30.0f), Vec2f(380,getScreenHeight()-80), getTeamColor(0) );
}
