//#include "TDM_Structs.as";
#include "ScoreboardCommon.as";
#include "Survival_Structs.as";

const string kagdevs = "geti;mm;flieslikeabrick;furai;jrgp;";
const string tcdevs = "tflippy;pirate-rob;merser433;goldenguy;koi_;";
const string contributors = "cesar0;sylw;sjd360;";

void onRenderScoreboard(CRules@ this)
{
	//sort players
	CPlayer@[] sortedplayers;
	for (u32 i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ p = getPlayer(i);
		int team = p.getTeamNum();
		bool inserted = false;
		for (u32 j = 0; j < sortedplayers.length; j++)
		{
			if (sortedplayers[j].getTeamNum() < team)
			{
				sortedplayers.insert(j, p);
				inserted = true;
				break;
			}
		}
		if (!inserted)
			sortedplayers.push_back(p);
	}

	//draw board

    drawServerInfo(40);

	f32 stepheight = 20;
	f32 playerList_yOffset = (sortedplayers.length + 3.5) * stepheight;
	
	// player scoreboard
	{
		
		Vec2f topleft(100, 150);
		Vec2f bottomright(getScreenWidth() - 100, topleft.y + playerList_yOffset);
		GUI::DrawPane(topleft, bottomright, SColor(0xffc0c0c0));
			
		//offset border

		topleft.x += stepheight;
		bottomright.x -= stepheight;
		topleft.y += stepheight;

		GUI::SetFont("menu");

		//draw player table header

		GUI::DrawText("Character Name", Vec2f(topleft.x, topleft.y), SColor(0xffffffff));
		GUI::DrawText("User Name", Vec2f(topleft.x + 250, topleft.y), SColor(0xffffffff));
		// GUI::DrawText("Coins", Vec2f(bottomright.x - 600, topleft.y), SColor(0xffffffff));
		// GUI::DrawText("Team Status", Vec2f(bottomright.x - 550, topleft.y), SColor(0xffffffff));
		GUI::DrawText("Wealth", Vec2f(bottomright.x - 550, topleft.y), SColor(0xffffffff));
		GUI::DrawText("Ping", Vec2f(bottomright.x - 450, topleft.y), SColor(0xffffffff));
		GUI::DrawText("Kills", Vec2f(bottomright.x - 350, topleft.y), SColor(0xffffffff));
		GUI::DrawText("Deaths", Vec2f(bottomright.x - 250, topleft.y), SColor(0xffffffff));
		GUI::DrawText("Title", Vec2f(bottomright.x - 150, topleft.y), SColor(0xffffffff));
		// GUI::DrawText("Flag Caps", Vec2f(bottomright.x - 100, topleft.y), SColor(0xffffffff));

		topleft.y += stepheight * 0.5f;

		CControls@ controls = getControls();
		Vec2f mousePos = controls.getMouseScreenPos();

		CSecurity@ security = getSecurity();
		
		//draw players
		for (u32 i = 0; i < sortedplayers.length; i++)
		{
			CPlayer@ p = sortedplayers[i];

			bool playerHover = mousePos.y > topleft.y + 20 && mousePos.y < topleft.y + 40;
			
			if (p is null) continue;

			topleft.y += stepheight;
			bottomright.y = topleft.y + stepheight;

			Vec2f lineoffset = Vec2f(0, -2);

			u32[] teamcolours = {0xff6666ff, 0xffff6666, 0xff33660d, 0xff621a83, 0xff844715, 0xff2b5353, 0xff2a3084, 0xff647160};
			u32 playercolour = teamcolours[p.getTeamNum() % teamcolours.length];
			u32 color_gray = 0xffbfbfbf;
			
			if (p.getTeamNum() >= 100)
			{
				playercolour = 0xffbfbfbf;
			}
			
			if (playerHover)
			{
				playercolour = 0xffffffff;
				color_gray = 0xffffffff;
			}
			
			GUI::DrawLine2D(Vec2f(topleft.x, bottomright.y + 1) + lineoffset, Vec2f(bottomright.x, bottomright.y + 1) + lineoffset, SColor(0xff404040));
			GUI::DrawLine2D(Vec2f(topleft.x, bottomright.y) + lineoffset, bottomright + lineoffset, SColor(playercolour));

			string tex = "";
			u16 frame = 0;
			Vec2f framesize;
			if (p.isMyPlayer())
			{
				tex = "ScoreboardIcons.png";
				frame = 4;
				framesize.Set(16, 16);
			}
			else
			{
				tex = p.getScoreboardTexture();
				frame = p.getScoreboardFrame();
				framesize = p.getScoreboardFrameSize();
			}
			if (tex != "") GUI::DrawIcon(tex, frame, framesize, topleft, 0.5f, p.getTeamNum());

			// string playername = (p.getClantag().length > 0 ? p.getClantag() + " " : "") + p.getCharacterName();
			// string username = p.getUsername();
			
			bool dev = false;
			string rank = getRank(p, dev);
			s32 ping_in_ms = s32(p.getPing() * 1000.0f / 30.0f);
			u16 coins = p.getCoins();
			
			
			
			GUI::DrawText((p.getClantag().length > 0 ? p.getClantag() + " " : "") + p.getCharacterName(), topleft + Vec2f(20, 0), playercolour);
			GUI::DrawText(p.getUsername(), topleft + Vec2f(250, 0), color_gray);
			
			// string team_status = "";
			
			// if (p.getTeamNum() < 7)
			// {
				// TeamData@ team_data;
				// GetTeamData(p.getTeamNum(), @team_data);
			
				// bool isLeader = p.getUsername() == team_data.leader_name;
				// if (isLeader)
				// {
					// team_status = "Leader";
				// }
				// else
				// {
					// team_status = "Member";
				// }
			// }
			
			GUI::DrawText("" + coins + " coins", Vec2f(bottomright.x - 550, topleft.y), color_gray);
			// GUI::DrawText(team_status, Vec2f(bottomright.x - 550, topleft.y), color_gray);
			GUI::DrawText("" + ping_in_ms + " ms", Vec2f(bottomright.x - 450, topleft.y), color_gray);
			GUI::DrawText("" + p.getKills(), Vec2f(bottomright.x - 350, topleft.y), color_gray);
			GUI::DrawText("" + p.getDeaths(), Vec2f(bottomright.x - 250, topleft.y), color_gray);
			GUI::DrawText(rank, Vec2f(bottomright.x - 150, topleft.y), color_gray);
			
			// p.drawAvatar(Vec2f(bottomright.x, topleft.y), 1.00f / 4.00f);
		}
	}
	
	// team scoreboard
	{
		TeamData[]@ team_list;

		this.get("team_list", @team_list);
		u8 maxTeams = team_list.length;
		
		if (team_list !is null)
		{
			u32 team_len = 0;
			for (u32 i = 0; i < team_list.length; i++)
			{
				if (team_list[i].player_count > 0) team_len++;
				// team_len++;
			}
		
			if (team_len == 0) return;
		
			f32 stepheight = 20;
			Vec2f topleft(100, 175 + playerList_yOffset);
			Vec2f bottomright(getScreenWidth() - 100, topleft.y + ((team_len + 3.5) * stepheight));
			GUI::DrawPane(topleft, bottomright, SColor(0xffc0c0c0));
				
			//offset border

			topleft.x += stepheight;
			bottomright.x -= stepheight;
			topleft.y += stepheight;

			GUI::SetFont("menu");

			//draw player table header

			GUI::DrawText("Team Name", Vec2f(topleft.x, topleft.y), SColor(0xffffffff));
			GUI::DrawText("Leader", Vec2f(topleft.x + 250, topleft.y), SColor(0xffffffff));
			// GUI::DrawText("Coins", Vec2f(bottomright.x - 600, topleft.y), SColor(0xffffffff));
			GUI::DrawText("Members", Vec2f(bottomright.x - 750, topleft.y), SColor(0xffffffff));
			GUI::DrawText("Upkeep", Vec2f(bottomright.x - 650, topleft.y), SColor(0xffffffff));
			GUI::DrawText("Wealth", Vec2f(bottomright.x - 550, topleft.y), SColor(0xffffffff));
			GUI::DrawText("Recruiting", Vec2f(bottomright.x - 450, topleft.y), SColor(0xffffffff));
			GUI::DrawText("Murder Tax", Vec2f(bottomright.x - 350, topleft.y), SColor(0xffffffff));
			GUI::DrawText("Lockdown", Vec2f(bottomright.x - 250, topleft.y), SColor(0xffffffff));
			GUI::DrawText("Land Owned", Vec2f(bottomright.x - 150, topleft.y), SColor(0xffffffff));
			// GUI::DrawText("Flag Caps", Vec2f(bottomright.x - 100, topleft.y), SColor(0xffffffff));

			topleft.y += stepheight * 0.5f;

			CControls@ controls = getControls();
			Vec2f mousePos = controls.getMouseScreenPos();

			CSecurity@ security = getSecurity();
			
			//draw teams
			
			u16 total_capturables = this.get_u16("total_capturables");
			
			for (u32 i = 0; i < team_list.length; i++)
			{
				TeamData@ team = team_list[i];
				if (team.player_count == 0) continue;
				
				CTeam@ cTeam = this.getTeam(i);
				
				bool hover = mousePos.y > topleft.y + 20 && mousePos.y < topleft.y + 40;
				
				if (team is null) continue;

				topleft.y += stepheight;
				bottomright.y = topleft.y + stepheight;

				Vec2f lineoffset = Vec2f(0, -2);

				u32[] teamcolours = {0xff6666ff, 0xffff6666, 0xff33660d, 0xff621a83, 0xff844715, 0xff2b5353, 0xff2a3084, 0xff647160};
				// u32 color = teamcolours[i];

				u32 color_gray = 0xffbfbfbf;
				u32 color = teamcolours[i];
				
				if (hover)
				{
					color_gray = 0xffffffff;
					color = 0xffffffff;
				}
				
				GUI::DrawLine2D(Vec2f(topleft.x, bottomright.y + 1) + lineoffset, Vec2f(bottomright.x, bottomright.y + 1) + lineoffset, SColor(0xff404040));
				GUI::DrawLine2D(Vec2f(topleft.x, bottomright.y) + lineoffset, bottomright + lineoffset, color);

				// string tex = "";
				// u16 frame = 0;
				// Vec2f framesize;
				// if (p.isMyPlayer())
				// {
					// tex = "ScoreboardIcons.png";
					// frame = 4;
					// framesize.Set(16, 16);
				// }
				// else
				// {
					// tex = p.getScoreboardTexture();
					// frame = p.getScoreboardFrame();
					// framesize = p.getScoreboardFrameSize();
				// }
				// if (tex != "") GUI::DrawIcon(tex, frame, framesize, topleft, 0.5f, p.getTeamNum());

				// // string playername = (p.getClantag().length > 0 ? p.getClantag() + " " : "") + p.getCharacterName();
				// // string username = p.getUsername();
				
				// bool dev = false;
				// string rank = getRank(p, dev);
				// s32 ping_in_ms = s32(p.getPing() * 1000.0f / 30.0f);
				// // u32 coins = p.getCoins();
				
				// GUI::DrawText((p.getClantag().length > 0 ? p.getClantag() + " " : "") + p.getCharacterName(), topleft + Vec2f(20, 0), playercolour);
				// GUI::DrawText(p.getUsername(), topleft + Vec2f(300, 0), playercolour);
				
				// string team_status = "";
				
				// if (p.getTeamNum() < 7)
				// {
					// TeamData@ team_data;
					// GetTeamData(p.getTeamNum(), @team_data);
				
					// bool isLeader = p.getUsername() == team_data.leader_name;
					// if (isLeader)
					// {
						// team_status = "Leader";
					// }
					// else
					// {
						// team_status = "Member";
					// }
				// }
				
				// // GUI::DrawText("" + coins + " c", Vec2f(bottomright.x - 600, topleft.y), SColor(0xffffffff));
				
				GUI::DrawText(cTeam.getName(), topleft + Vec2f(0, 0), color);
				GUI::DrawText(team.leader_name == "" ? "N/A" : team.leader_name, topleft + Vec2f(250, 0), color_gray);
				GUI::DrawText("" + team.player_count, Vec2f(bottomright.x - 750, topleft.y), color_gray);
				GUI::DrawText("" + team.upkeep + " / " + team.upkeep_cap, Vec2f(bottomright.x - 650, topleft.y), color_gray);
				GUI::DrawText("" + team.wealth + " coins", Vec2f(bottomright.x - 550, topleft.y), color_gray);
				GUI::DrawText(team.recruitment_enabled ? "Yes" : "No", Vec2f(bottomright.x - 450, topleft.y), color_gray);
				GUI::DrawText(team.tax_enabled ? "Yes" : "No", Vec2f(bottomright.x - 350, topleft.y), color_gray);
				GUI::DrawText(team.lockdown_enabled ? "Yes" : "No", Vec2f(bottomright.x - 250, topleft.y), color_gray);
				GUI::DrawText("" + Maths::Round((f32(team.controlled_count) / f32(total_capturables)) * 100.00f) + "%", Vec2f(bottomright.x - 150, topleft.y), color_gray);
				
				// GUI::DrawText(cTeam.getName(), Vec2f(bottomright.x - 650, topleft.y), SColor(0xffffffff));
				// GUI::DrawText("" + ping_in_ms, Vec2f(bottomright.x - 500, topleft.y), SColor(0xffffffff));
				// GUI::DrawText("" + p.getKills(), Vec2f(bottomright.x - 400, topleft.y), SColor(0xffffffff));
				// GUI::DrawText("" + p.getDeaths(), Vec2f(bottomright.x - 300, topleft.y), SColor(0xffffffff));
				// GUI::DrawText(rank, Vec2f(bottomright.x - 200, topleft.y), SColor(0xffffffff));
			}
		}
	}
	
	
	// Vec2f offset = Vec2f(0, bottomright.y - topleft.y + 64);
	// GUI::DrawPane(topleft + offset, bottomright + offset + Vec2f(0, 64), SColor(0xffc0c0c0));
}

string getRank(CPlayer@ p, bool &out dev)
{
	string username = p.getUsername().toLower() + ";";
	string seclev = getSecurity().getPlayerSeclev(p).getName();
	dev = false;
	
	if (kagdevs.find(username) != -1) return "KAG Developer";
	else if (tcdevs.find(username) != -1)
	{	
		dev = true;
		return (username == "tflippy;" ? "Head " : "") + "TC Developer";
	}
	else if (contributors.find(username) != -1) return "Contributor";
	else if (username == "vamist;") return "Glorious Server Host";
	else if (seclev != "Normal") seclev;
	
	return "";
}