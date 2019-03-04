#include "CampaignCommon.as"
#include "GameColours.as"
#include "Timers.as"
#include "RulesCommon.as"
#include "RadioCharacters.as"
#include "ClassesCommon.as"
#include "PlayerStatsCommon.as"

const f32 SCALE = 1.0f;
Vec2f ICON_SIZE(SCALE * 32, SCALE * 32);
Vec2f ICON_DISPLAY_SIZE(ICON_SIZE.x + SCALE * 8, ICON_SIZE.y + SCALE * 8);
string _locations_file = "Sprites/UI/location_icons.png";

void onInit(CRules@ this)
{
	AddIconToken("$location_none$", _locations_file, Vec2f(32, 32), 0);
	AddIconToken("$location_trenches$", _locations_file, Vec2f(32, 32), 1);
	AddIconToken("$location_forest$", _locations_file, Vec2f(32, 32), 2);
	AddIconToken("$location_desert$", _locations_file, Vec2f(32, 32), 3);
	AddIconToken("$location_swamp$", _locations_file, Vec2f(32, 32), 4);
	AddIconToken("$location_village$", _locations_file, Vec2f(32, 32), 5);
	AddIconToken("$location_city$", _locations_file, Vec2f(32, 32), 6);
	AddIconToken("$location_mountain$", _locations_file, Vec2f(32, 32), 7);
	AddIconToken("$location_test$", _locations_file, Vec2f(32, 32), 0);
	AddIconToken("$location_done$", _locations_file, Vec2f(32, 32), 8);
}


f32 getTimerPercentage(Game::Timer@ timer, const f32 start, const f32 end = -1.0f)
{
	if (timer !is null)
	{
		const u32 time = getGameTime();
		int duration = timer.duration * getTicksASecond();
		f32 timerStartTime = f32(timer.endTime - duration);
		f32 timeStart = f32(timerStartTime + start * duration) / f32(duration);
		f32 timeEnd = f32(timerStartTime + end * duration) / f32(duration);
		f32 timeCurrent = f32(time - timerStartTime) / f32(duration);
		if (timeCurrent < timeStart)
			return 0.0f;
		if (timeCurrent > timeEnd)
			return 1.0f;
		if ((end - start) > 0.0f && end > 0.0f)
			return (timeCurrent - start) / (end - start);
		else
			return 0.0f;
	}
	return 1.0f;
}

void onRender(CRules@ this)
{
	if (this.get_s16("in menu") != 0)
		return;

	Campaign::Data@ data = Campaign::getCampaign(this);

	Driver@ driver = getDriver();
	Vec2f screenDim = driver.getScreenDimensions();
	Vec2f screenCenter = driver.getScreenCenterPos();
	const u32 time = getGameTime();

	s32 local_team = -1;
	if (getLocalPlayer() !is null)
	{
		local_team = getLocalPlayer().getTeamNum();
		//range limit - specs are "invalid"
		if (local_team > 1)
			local_team = -1;
	}

	float draw_scale = 0.5f;

	// TEAM PRESENTATION

	if (this.isIntermission())
	{
		Game::Timer@ timer = Game::getTimer("teams");

		//ClearScreen( this );
		DrawTRGuiFrame(Vec2f(screenDim.x / 3, 0), Vec2f(2 * screenDim.x / 3, screenDim.y));

		GUI::SetFont("menu");
		Vec2f teamNamePos(screenDim.x * 0.5f, screenDim.y * 0.2f);
		Vec2f scorePos = screenCenter;
		const bool seriesEnded = Campaign::isSeriesEnded(data);

		// team names or win msg

		if (seriesEnded) // win msg
		{
			const int team1score = Campaign::getTeamScore(data, 0);
			const int team2score = Campaign::getTeamScore(data, 1);
			SColor color = color_white;
			string win_l1 = "It's a tie!";
			string win_l2 = "";

			bool tie = (team1score == team2score);
			bool paid_tie = (team1score > 0 && team2score > 0 && tie);

			bool winner = false;

			if (team1score > team2score)
			{
				win_l1 = "Beer Republic";
				win_l2 = "WINS!";
				color = Colours::TEAM1;

				if (local_team == 0)
					winner = true;
			}
			else if (team1score < team2score)
			{
				win_l1 = "Wine Nation";
				win_l2 = "WINS!";
				color = Colours::TEAM2;

				if (local_team == 1)
					winner = true;
			}

			GUI::DrawTextCentered(win_l1, Vec2f(screenDim.x * 0.5f, teamNamePos.y - 24 + Maths::Sin(1.5f * time * 5) * 2.5f), getTimerPercentage(timer, 0.0f, 0.02f) < 1.0f ? color_black : color);
			GUI::DrawTextCentered(win_l2, Vec2f(screenDim.x * 0.5f, teamNamePos.y + Maths::Sin(1.5f * time * 5) * 2.5f), getTimerPercentage(timer, 0.0f, 0.02f) < 1.0f ? color_black : color);

			if (local_team != -1 && this.hasTag("use_backend"))
			{
				string _score_spritesheet = "Sprites/UI/hud_scores.png";

				Vec2f coin_tl(screenDim.x / 3 - 10, teamNamePos.y + 20);
				Vec2f coin_br(2 * screenDim.x / 3 + 10, teamNamePos.y + 40);

				Vec2f coinpos = (coin_br + coin_tl) * 0.5f + Vec2f(20, -8);

				DrawTRGuiFrame(coin_tl, coin_br);

				s32 cost = s32(this.get_u32("entry_cost"));
				s32 reward = s32(this.get_u32("winner_reward"));

				bool outcome = (winner || paid_tie);

				s32 mycoinchange = (outcome ? reward - cost : -cost);
				//coin icon
				GUI::DrawIcon(_score_spritesheet, 24, Vec2f(16, 16),
				              coinpos,
				              draw_scale);
				//coin count
				GUI::SetFont("gui");
				GUI::DrawText(tie ? (paid_tie ? "WELL FOUGHT!" : "STALEMATE!") :
				              (winner ? "HOORAY! YOU WON!" : "SORRY! YOU LOST!"),
				              coinpos + Vec2f(-112, -3), outcome ? Colours::GREEN : Colours::RED);
				GUI::DrawText((outcome ? "+" : (mycoinchange < 0 ? "" : " ")) + mycoinchange + " coin" + (Maths::Abs(mycoinchange) == 1 ? "" : "s"),
				              coinpos + Vec2f(16, -3), outcome ? Colours::GREEN : Colours::RED);
			}
		}
		else // names
		{
			//teamNamePos.y += -getTimerPercentage(timer, 0.4f, 0.6f) * screenDim.y;
			GUI::DrawTextCentered("BEER", Vec2f(screenDim.x * 0.4f, teamNamePos.y), getTimerPercentage(timer, 0.0f, 0.025f) < 1.0f ? color_black : Colours::TEAM1);
			GUI::DrawTextCentered("WINE", Vec2f(screenDim.x * 0.6f, teamNamePos.y), getTimerPercentage(timer, 0.0f, 0.05f) < 1.0f ? color_black : Colours::TEAM2);
		}

		// score

		if (getTimerPercentage(timer, 0.0f, 0.1f) >= 1.0f)
		{
			GUI::SetFont("menu");

			const int team1score = Campaign::getTeamScore(data, 0);
			const int team2score = Campaign::getTeamScore(data, 1);
			//scorePos.y += getTimerPercentage(timer, 0.2f, 0.5f) * screenDim.y;
			GUI::DrawTextCentered(":", scorePos, color_white);
			GUI::DrawTextCentered("" + Maths::Floor(getTimerPercentage(timer, 0.1f, 0.15f) * f32(team1score)), Vec2f(scorePos.x - 50, scorePos.y), Colours::TEAM1);
			GUI::DrawTextCentered("" + Maths::Floor(getTimerPercentage(timer, 0.15f, 0.2f) * f32(team2score)), Vec2f(scorePos.x + 50, scorePos.y), Colours::TEAM2);
		}

		// maps


		if (getTimerPercentage(timer, 0.0f, 0.2f) >= 1.0f)
		{
			const uint battlesCount = data.battles.length;
			const int middleOffset = 0;
			Vec2f dimensions(battlesCount * ICON_DISPLAY_SIZE.x, ICON_DISPLAY_SIZE.y);
			Vec2f ul = Vec2f(0.0f, screenCenter.y * 0.8f) + screenCenter - dimensions / 2.0f + Vec2f(middleOffset * ICON_DISPLAY_SIZE.x, 0.0f);
			Vec2f lr = ul + dimensions;
			Vec2f battlePos(ul.x + ICON_DISPLAY_SIZE.x / 2.0f, (ul.y + lr.y) / 2.0f);

			DrawTRGuiFrame(ul - Vec2f(8, 8), lr + Vec2f(8, 8));

			for (uint locIt = 0; locIt < battlesCount; locIt++)
			{
				const string token = getLocationToken(data.battles[locIt]);
				SColor color = data.team[locIt] == -1 ? SColor(0) : (data.team[locIt] == 0 ? Colours::TEAM1 : Colours::TEAM2);
				if (data.battleIndex == locIt && time % 40 < 21)
				{
					color = Colours::WHITE;
					if (seriesEnded)
					{
						color = color_black;
					}
				}

				GUI::DrawRectangle(battlePos - ICON_SIZE / 1.6f, battlePos + ICON_SIZE / 1.6f, color);
				GUI::DrawIconByName(token, battlePos - ICON_SIZE / 2.0f, SCALE / 2.0f);

				// mark as done
				if (locIt < data.battleIndex || seriesEnded)
				{
					GUI::DrawIconByName("$location_done$", battlePos - ICON_SIZE / 2.0f, SCALE / 2.0f);
				}
				battlePos.x += ICON_DISPLAY_SIZE.x;
			}
		}

	}

	// BRIEFING

	if (this.isWarmup())
	{
		const uint battlesCount = data.battles.length;
		const int middleOffset = data.battles.length > (screenDim.x / ICON_SIZE.x) ? Maths::Floor(data.battles.length / 2) - data.battleIndex : 0;

		Vec2f dimensions(battlesCount * ICON_DISPLAY_SIZE.x, ICON_DISPLAY_SIZE.y);
		Vec2f ul = Vec2f(0.0f, screenCenter.y * 0.8f) + screenCenter - dimensions / 2.0f + Vec2f(middleOffset * ICON_DISPLAY_SIZE.x, 0.0f);
		Vec2f lr = ul + dimensions;

		Vec2f iconPos(ul.x + ICON_DISPLAY_SIZE.x / 2.0f, (ul.y + lr.y) / 2.0f);

		// letterbox
		DrawLetterbox(this);

		//printf("locationsCount " + locationsCount);
		/*	for (uint locIt = 0; locIt < battlesCount; locIt++)
			{
				const string token = getLocationToken(data.battles[locIt]);
				SColor color = data.team[locIt] == -1 ? SColor(0) : (data.team[locIt] == 0 ? Colours::TEAM1 : Colours::TEAM2);
				if (this.isWarmup() && data.battleIndex == locIt && time % 40 < 21)
				{
					color = Colours::WHITE;
				}

				GUI::DrawRectangle(iconPos - ICON_SIZE / 1.6f, iconPos + ICON_SIZE / 1.6f, color);
				GUI::DrawIconByName(token, iconPos - ICON_SIZE / 2.0f, SCALE / 2.0f);
				iconPos.x += ICON_DISPLAY_SIZE.x;
			} */

		// ready text

		GUI::SetFont("menu");
		GUI::DrawTextCentered("RUN TO THE EDGE!",
		                      Vec2f(getScreenWidth() / 2, 40),
		                      color_white);

		Vec2f[] spawns;
		CPlayer@ player = getLocalPlayer();
		if (player !is null)
		{
			if (getMap().getMarkers(getTeamMarkerString(player.getTeamNum()), spawns))
			{
				GUI::SetFont("gui");
				GUI::DrawTextCentered("START HERE",
				                      Vec2f(getDriver().getScreenPosFromWorldPos(spawns[0]).x, getMap().tilemapheight * getMap().tilesize * 0.4f + Maths::Sin(getGameTime() * 0.25f) * 2.0f) ,
				                      player.getTeamNum() == 0 ? Colours::TEAM1 : Colours::TEAM2);
				spawns.clear();
			}
			if (getMap().getMarkers(getTeamMarkerString((player.getTeamNum() + 1) % 2), spawns))
			{
				GUI::SetFont("gui");
				GUI::DrawTextCentered("REACH THE EDGE",
				                      Vec2f(getDriver().getScreenPosFromWorldPos(spawns[0]).x, getMap().tilemapheight * getMap().tilesize * 0.4f + Maths::Sin(getGameTime() * 0.25f) * 2.0f) ,
				                      player.getTeamNum() == 0 ? Colours::TEAM1 : Colours::TEAM2);
				spawns.clear();
			}
		}
	}

	// GAME

	if (this.isMatchRunning())
	{
		Game::Timer@ timer = Game::getTimer("timeout");
		if (timer !is null && this.get_s16("in menu") > 0 &&
		        timer.duration - Game::getTimerSecondsLeft(timer) < 3)
		{
			GUI::SetFont("menu");
			GUI::DrawTextCentered("RUN!",
			                      Vec2f(getScreenWidth() / 2, 40),
			                      color_white);
		}
	}

	if (this.isGameOver())
	{
		DrawLetterbox(this);


		GUI::SetFont("menu");
		SColor color;
		string text = this.get_string("win msg");
		if (this.getTeamWon() == 0)
		{
			color = Colours::TEAM1;
		}
		else if (this.getTeamWon() == 1)
		{
			color = Colours::TEAM2;
		}
		else
		{
			color = Colours::WHITE;
		}

		GUI::DrawTextCentered(text,
		                      Vec2f(getScreenWidth() / 2, 40 + Maths::Sin(getGameTime() * 0.25f) * 8.0f),
		                      color);
	}
}

void DrawLetterbox(CRules@ this)
{
	Driver@ driver = getDriver();
	Vec2f screenDim = driver.getScreenDimensions();

	// letterbox
	DrawTRGuiFrame(Vec2f(0, 0), Vec2f(screenDim.x, 70));
	DrawTRGuiFrame(Vec2f(0, screenDim.y - 70), screenDim);
}

void ClearScreen(CRules@ this, SColor color = color_black)
{
	Driver@ driver = getDriver();
	Vec2f screenDim = driver.getScreenDimensions();

	GUI::DrawRectangle(Vec2f(0, 0), screenDim, color);
}


string getLocationToken(const string &in name)
{
	return "$location_" + name + "$";
}
