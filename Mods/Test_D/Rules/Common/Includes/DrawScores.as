#include "GameColours.as"

string _score_spritesheet = "Sprites/UI/hud_scores.png";

CPlayer@ getPlayerWithTeam(int team)
{
	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ p = getPlayer(i);
		if (p.getTeamNum() == team)
		{
			return p;
		}
	}
	return null;
}

void DrawScores(CRules@ this, const int score_cap, bool is_end = false)
{
	if (this.get_s16("in menu") > 0)
		return;

	const u32 time = getGameTime();
	uint player_count = getPlayersCount();
	float per_line_offset = 1.5f;

	float camera_scaling = getCamera().targetDistance;
	float pixel_scale = camera_scaling * 2.0f;

	Vec2f upperleft = Vec2f( getScreenWidth() / 2 - ((score_cap + 1) / 2) * 16.0f * pixel_scale,
	                        getScreenHeight() / 3 + (-player_count / 3) * 16.0f * pixel_scale);

	Vec2f totalsize = Vec2f(score_cap + 1, (1 + getPlayersCount()) * per_line_offset) * 16.0f * pixel_scale;

	//expand for "final" moment
	float extra_width = 100.0f;
	if (is_end)
	{
		totalsize.x += extra_width;
		upperleft.x -= extra_width / 2.0f;
	}

	//background frame
	GUI::DrawRectangle(upperleft - Vec2f(18, 10), upperleft + totalsize + Vec2f(18, 10), Colours::BLACK);
	GUI::DrawRectangle(upperleft - Vec2f(17, 9), upperleft + totalsize + Vec2f(17, 9), Colours::DARK);
	GUI::DrawRectangle(upperleft - Vec2f(16, 8), upperleft + totalsize + Vec2f(16, 8), Colours::BLACK);

	float draw_scale = 0.5f;

	//header icon
	if (is_end)
	{
		//"GAME OVER"
		GUI::DrawIcon(_score_spritesheet, 4,
		              Vec2f(128, 16), upperleft + Vec2f(totalsize.x / 2 - 128 * draw_scale, 0), draw_scale);
	}
	else
	{
		//"KILLS"
		GUI::DrawIcon(_score_spritesheet, 1,
		              Vec2f(64, 16), upperleft + Vec2f(totalsize.x / 2 - 64 * draw_scale, 0), draw_scale);
	}

	//draw each player row
	for (uint i = 0; i < player_count; i++)
	{
		CPlayer@ p = getPlayerWithTeam(i);
		if (p is null) continue;

		const uint score = p.getKills();
		CControls@ controls = p.getControls();
		// blink if action button pressed
		const bool actionPressed = (controls !is null ? (controls.ActionKeyPressed(AK_ACTION1) || controls.ActionKeyPressed(AK_ACTION2)) : false);

		Vec2f local_upperleft = upperleft + Vec2f(0, (i + 1) * per_line_offset * 16.0f * pixel_scale);

		f32 p_bounce_amount = (Maths::Sin(1.0f * (time + i*13)) * 5) * draw_scale;

		//player counter icon
		GUI::DrawIcon(_score_spritesheet, i,
		              Vec2f(16, 16), local_upperleft + Vec2f(-pixel_scale, actionPressed ? (-p_bounce_amount) : 0), draw_scale);

		const u16 lastScore = p.getScore();

		Random _framerandom(i + score * 977);
		for (uint j = 0; j < score_cap; j++)
		{
			const int frame = _framerandom.NextRanged(8);
			const bool isScore = j < score;
			const int bounce = (isScore && j >= lastScore) ? (-2 + (Maths::Sin(1.0f * (time + i + j)) * 4)) : 0;
			//skulls for kill
			GUI::DrawIcon(_score_spritesheet, frame + (isScore ? 8 : 16), Vec2f(16, 16),
			              local_upperleft + Vec2f(4, bounce) + (Vec2f(16, 0) * (j + 1) * pixel_scale),
			              draw_scale);
		}

		if (is_end)
		{
			//draw winner
			bool winner = score >= score_cap;
			if (winner)
			{
				GUI::SetFont("gui");
				Vec2f textpos = local_upperleft + (Vec2f(16 * (score_cap + 1) * pixel_scale + extra_width * 0.5f, p_bounce_amount + 5));
				GUI::DrawTextCentered("WINNER!", textpos, Colours::WHITE);
			}

			//draw coin amounts
			if (!isFreeBuild() && this.hasTag("use_backend"))
			{
				Vec2f coinpos = local_upperleft + (Vec2f(16 * (score_cap + 1) * pixel_scale + extra_width * 0.8f, -p_bounce_amount*0.5f));

				s32 cost = s32(this.get_u32("entry_cost"));
				s32 reward = s32(this.get_u32("winner_reward"));

				s32 mycoinchange = (winner ? reward - cost : -cost);
				//coin icon
				GUI::DrawIcon(_score_spritesheet, 24, Vec2f(16, 16),
				              coinpos,
				              draw_scale);
				//coin count
				GUI::SetFont("gui");
				GUI::DrawText("" + mycoinchange, coinpos + Vec2f(12, 4), winner ? Colours::GREEN : Colours::RED);
			}

			//TODO: draw funny titles :)
		}
	}
}


void DrawCampaignScores(CRules@ this, const u8 teamwin, bool is_end = false)
{
	if (this.get_s16("in menu") > 0)
		return;

	const u32 time = getGameTime();
	uint player_count = getPlayersCount();
	float per_line_offset = 1.5f;
	const int score_cap = 15;

	float camera_scaling = getCamera().targetDistance;
	float pixel_scale = camera_scaling * 2.0f;

	Vec2f upperleft = Vec2f(getScreenWidth() / 2 - ((score_cap + 1) / 2) * 16.0f * pixel_scale,
	                        getScreenHeight() / 4 + (-player_count / 3) * 16.0f * pixel_scale);

	Vec2f totalsize = Vec2f(score_cap + 1, (1 + getPlayersCount()) * per_line_offset) * 16.0f * pixel_scale;

	//expand for "final" moment
	float extra_width = 100.0f;
	//if (is_end)
	{
		totalsize.x += extra_width;
		upperleft.x -= extra_width / 2.0f;
	}

	//background frame
	GUI::DrawRectangle(upperleft - Vec2f(118, 10), upperleft + totalsize + Vec2f(18, 10), Colours::BLACK);
	GUI::DrawRectangle(upperleft - Vec2f(117, 9), upperleft + totalsize + Vec2f(17, 9), Colours::DARK);
	GUI::DrawRectangle(upperleft - Vec2f(116, 8), upperleft + totalsize + Vec2f(16, 8), Colours::BLACK);

	float draw_scale = 0.5f;

	//header icon
	if (is_end)
	{
		//"GAME OVER"
		GUI::DrawIcon(_score_spritesheet, 4,
		              Vec2f(128, 16), upperleft + Vec2f(totalsize.x / 2 - 128 * draw_scale, 0), draw_scale);
	}
	else
	{
		//"KILLS"
		//GUI::DrawIcon(_score_spritesheet, 1,
		//              Vec2f(64, 16), upperleft + Vec2f(totalsize.x / 2 - 64 * draw_scale, 0), draw_scale);
	}

	//draw each player row
	for (uint i = 0; i < player_count; i++)
	{
		CPlayer@ p = getPlayer(i);
		if (p is null) continue;

		const uint score = p.getKills();
		CControls@ controls = p.getControls();
		// blink if action button pressed
		const bool actionPressed = (controls !is null ? (controls.ActionKeyPressed(AK_ACTION1) || controls.ActionKeyPressed(AK_ACTION2)) : false);

		Vec2f local_upperleft = upperleft + Vec2f(0, (i + 1) * per_line_offset * 16.0f * pixel_scale);

		f32 p_bounce_amount = (Maths::Sin(1.0f * (time + i*13)) * 5) * draw_scale;

		//player counter icon
		//GUI::DrawIcon(_score_spritesheet, i,
		//              Vec2f(16, 16), local_upperleft + Vec2f(-pixel_scale, actionPressed ? (-p_bounce_amount) : 0), draw_scale);
		Vec2f dim;
		GUI::SetFont("gui");
		GUI::GetTextDimensions(p.getCharacterName(), dim);
		GUI::DrawText(p.getCharacterName(), local_upperleft + Vec2f(-dim.x -pixel_scale, actionPressed ? (-p_bounce_amount) : 0), Colours::WHITE);

		const u16 lastScore = p.getScore();

		Random _framerandom(i + score * 977);
		for (uint j = 0; j < score_cap; j++)
		{
			const int frame = _framerandom.NextRanged(8);
			const bool isScore = j < score;
			const int bounce = (isScore && j >= lastScore) ? (-2 + (Maths::Sin(1.0f * (time + i + j)) * 4)) : 0;
			//skulls for kill
		//	if (isScore){
				GUI::DrawIcon(_score_spritesheet, frame + (isScore ? 8 : 16), Vec2f(16, 16),
				              local_upperleft + Vec2f(4, bounce) + (Vec2f(16, 0) * (j + 1) * pixel_scale),
				              draw_scale);
			//}
		}

		if (is_end)
		{
			//draw winner
			bool winner = teamwin == p.getTeamNum();
			if (winner)
			{
				GUI::SetFont("hud");
				Vec2f textpos = local_upperleft + (Vec2f(16 * (score_cap + 1) * pixel_scale + extra_width * 0.5f, p_bounce_amount + 6));
				GUI::DrawTextCentered("WINNER!", textpos, Colours::WHITE);
			}

			//draw coin amounts
			if (this.hasTag("use_backend"))
			{
				Vec2f coinpos = local_upperleft + (Vec2f(16 * (score_cap + 1) * pixel_scale + extra_width * 0.8f, -p_bounce_amount*0.5f));

				s32 cost = s32(this.get_u32("entry_cost"));
				s32 reward = s32(this.get_u32("winner_reward"));

				s32 mycoinchange = (winner ? reward - cost : -cost);
				//coin icon
				GUI::DrawIcon(_score_spritesheet, 24, Vec2f(16, 16),
				              coinpos,
				              draw_scale);
				//coin count
				GUI::SetFont("hud");
				GUI::DrawText("" + mycoinchange, coinpos + Vec2f(12, 4), winner ? Colours::TEAM2 : Colours::TEAM1);
			}

			//TODO: draw funny titles :)
		}
	}
}
