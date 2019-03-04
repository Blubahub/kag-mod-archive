#include "TDM_Structs.as";
#include "ScoreboardCommon.as";

/*
void onTick( CRules@ this )
{
    //see the logic script for this
}
*/

void onInit(CRules@ this)
{
	CBitStream stream;
	stream.write_u16(0xDEAD);
	this.set_CBitStream("tdm_serialised_team_hud", stream);
}

void onRenderScoreboard(CRules@ this)
{
	//sort players
	CPlayer@[] sortedplayers;
	CPlayer@[] spectators;
	for (u32 i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ p = getPlayer(i);
		f32 kdr = getKDR(p);
		bool inserted = false;
		if (p.getTeamNum() == this.getSpectatorTeamNum())
		{
			spectators.push_back(p);
			continue;
		}
		for (u32 j = 0; j < sortedplayers.length; j++)
		{
			if (getKDR(sortedplayers[j]) < kdr)
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

	f32 stepheight = 16;
	Vec2f topleft(100, 150);
	Vec2f bottomright(getScreenWidth() - 100, topleft.y + (sortedplayers.length + (spectators.length == 0 ? 0 : 2) + 3.5) * stepheight);
	GUI::DrawPane(topleft, bottomright, SColor(0xffc0c0c0));

	//offset border

	topleft.x += stepheight;
	bottomright.x -= stepheight;
	topleft.y += stepheight;

	//draw spectators

	GUI::SetFont("menu");

	if (spectators.length > 0)
	{
		f32 specy = bottomright.y - stepheight * 2;
		GUI::DrawLine2D(Vec2f(topleft.x, specy), Vec2f(bottomright.x, specy), SColor(0xff404040));

		Vec2f textdim;
		string s = "Spectators:";
		GUI::GetTextDimensions(s, textdim);

		GUI::DrawText(s, Vec2f(topleft.x, specy), SColor(0xffaaaaaa));

		f32 specx = topleft.x + textdim.x + 10;
		for (u32 i = 0; i < spectators.length; i++)
		{
			CPlayer@ p = spectators[i];
			if (specx < bottomright.x - 100)
			{
				string name = p.getCharacterName();
				if (i != spectators.length - 1)
					name += ",";
				GUI::GetTextDimensions(name, textdim);
				SColor namecolour = getNameColour(p);
				GUI::DrawText(name, Vec2f(specx, specy), namecolour);
				specx += textdim.x + 10;
			}
			else
			{
				GUI::DrawText("and more ...", Vec2f(specx, specy), SColor(0xffaaaaaa));
				break;
			}
		}
	}

	//draw player table header

	GUI::DrawText("Player", Vec2f(topleft.x, topleft.y), SColor(0xffffffff));
	GUI::DrawText("Ping", Vec2f(bottomright.x - 400, topleft.y), SColor(0xffffffff));
	GUI::DrawText("Kills", Vec2f(bottomright.x - 300, topleft.y), SColor(0xffffffff));
	GUI::DrawText("Deaths", Vec2f(bottomright.x - 200, topleft.y), SColor(0xffffffff));
	GUI::DrawText("KDR", Vec2f(bottomright.x - 100, topleft.y), SColor(0xffffffff));

	topleft.y += stepheight * 0.5f;

	CControls@ controls = getControls();
	Vec2f mousePos = controls.getMouseScreenPos();

	//draw players
	for (u32 i = 0; i < sortedplayers.length; i++)
	{
		CPlayer@ p = sortedplayers[i];

        bool playerHover = mousePos.y > topleft.y + stepheight && mousePos.y < topleft.y + stepheight*2;
        if(playerHover && controls.mousePressed1)
        {
            setSpectatePlayer(p.getUsername());

        }

		topleft.y += stepheight;
		bottomright.y = topleft.y + stepheight;

		Vec2f lineoffset = Vec2f(0, -2);

		u32[] teamcolours = {0xff6666ff, 0xffff6666};
		u32 playercolour = (p.getBlob() is null || p.getBlob().hasTag("dead")) ? 0xffaaaaaa :
		                   teamcolours[p.getBlob().getTeamNum() % teamcolours.length];
        if(playerHover)
        {
            playercolour = 0xffffffff;

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
		if (tex != "")
		{
			GUI::DrawIcon(tex, frame, framesize, topleft, 0.5f, p.getTeamNum());
		}

		string playername = "";
		if (playerHover)
		{
			playername = p.getUsername();
		}
		else
		{
			playername = p.getCharacterName();
			string clantag = p.getClantag();
			if (clantag.length > 0)
			{
				playername = clantag + " " + playername;
			}
		}

		//have to calc this from ticks
		s32 ping_in_ms = s32(p.getPing() * 1000.0f / 30.0f);


		//render the player + stats
		SColor namecolour = getNameColour(p);
		
		string username = p.getUsername();		
		if (username == "Koi_" || username == "Bunnie" || username == "merser433") 
		{
			f32 hue = getGameTime() % 360;
			f32 saturation = 1.0f;
			f32 value = 1.0f;
			
			f32 hh = hue / 60.0f;
			u32 i = hh;
			f32 ff = hh - i;
			
			f32 p = (1.0f - saturation);
			f32 q =	(1.0f - (saturation * ff));
			f32 t = (1.0f - (saturation * (1.0f - ff)));

			f32 r;
			f32 g;
			f32 b;
			
			if(i == 0)
			{
				r = value;
				g = t;
				b = p;
			}
			else if(i == 1)
			{
				r = q;
				g = value;
				b = p;
			}
			else if(i == 2)
			{
				r = p;
				g = value;
				b = t;
			}
			else if(i == 3)
			{
				r = p;
				g = q;
				b = value;
			}
			else if(i == 4)
			{
				r = t;
				g = p;
				b = value;
			}
			else
			{
				r = value;
				g = p;
				b = q;
			}
			
			namecolour = SColor(255, uint(r * 255.0f), uint(g * 255.0f), uint(b * 255.0f));
		}

		GUI::DrawText(playername, topleft + Vec2f(20, 0), namecolour);

		GUI::DrawText("" + ping_in_ms, Vec2f(bottomright.x - 400, topleft.y), SColor(0xffffffff));
		GUI::DrawText("" + p.getKills(), Vec2f(bottomright.x - 300, topleft.y), SColor(0xffffffff));
		GUI::DrawText("" + p.getDeaths(), Vec2f(bottomright.x - 200, topleft.y), SColor(0xffffffff));
		GUI::DrawText("" + formatFloat(getKDR(p), "", 3, 1), Vec2f(bottomright.x - 100, topleft.y), SColor(0xffffffff));
	}
}

void onRender(CRules@ this)
{
	CPlayer@ p = getLocalPlayer();

	if (p is null || !p.isMyPlayer()) { return; }

	GUI::SetFont("menu");

	CBitStream serialised_team_hud;
	this.get_CBitStream("tdm_serialised_team_hud", serialised_team_hud);

	if (serialised_team_hud.getBytesUsed() > 10)
	{
		serialised_team_hud.Reset();
		u16 check;

		if (serialised_team_hud.saferead_u16(check) && check == 0x5afe)
		{
			const string gui_image_fname = "Rules/TDM/TDMGui.png";

			while (!serialised_team_hud.isBufferEnd())
			{
				TDM_HUD hud(serialised_team_hud);
				Vec2f topLeft = Vec2f(8, 8 + 64 * hud.team_num);
				GUI::DrawIcon(gui_image_fname, 0, Vec2f(128, 32), topLeft, 1.0f, hud.team_num);
				int team_player_count = 0;
				int team_dead_count = 0;
				int step = 0;
				Vec2f startIcons = Vec2f(64, 8);
				Vec2f startSkulls = Vec2f(160, 8);
				string player_char = "";
				int size = int(hud.unit_pattern.size());

				while (step < size)
				{
					player_char = hud.unit_pattern.substr(step, 1);
					step++;

					if (player_char == " ") { continue; }

					if (player_char != "s")
					{
						int player_frame = 1;

						if (player_char == "a")
						{
							player_frame = 2;
						}

						GUI::DrawIcon(gui_image_fname, 12 + player_frame, Vec2f(16, 16), topLeft + startIcons + Vec2f(team_player_count * 8, 0) , 1.0f, hud.team_num);
						team_player_count++;
					}
					else
					{
						GUI::DrawIcon(gui_image_fname, 12 , Vec2f(16, 16), topLeft + startSkulls + Vec2f(team_dead_count * 16, 0) , 1.0f, hud.team_num);
						team_dead_count++;
					}
				}

				if (hud.spawn_time != 255)
				{
					string time = "" + hud.spawn_time;
					GUI::DrawText(time, topLeft + Vec2f(196, 42), SColor(255, 255, 255, 255));
				}

				string kills = getTranslatedString("WARMUP");

				if (hud.kills_limit > 0)
				{
					kills = getTranslatedString("KILLS") + ": " + hud.kills + "/" + hud.kills_limit;
				}
				else if (hud.kills_limit == -2)
				{
					kills = getTranslatedString("SUDDEN DEATH");
				}

				GUI::DrawText(kills, topLeft + Vec2f(64, 42), SColor(255, 255, 255, 255));
			}
		}

		serialised_team_hud.Reset();
	}

	string propname = "tdm spawn time " + p.getUsername();
	if (p.getBlob() is null && this.exists(propname))
	{
		u8 spawn = this.get_u8(propname);

		if (spawn != 255)
		{
			if (spawn == 254)
			{
				GUI::DrawText(getTranslatedString("In Queue to Respawn...") , Vec2f(getScreenWidth() / 2 - 70, getScreenHeight() / 3 + Maths::Sin(getGameTime() / 3.0f) * 5.0f), SColor(255, 255, 255, 55));
			}
			else if (spawn == 253)
			{
				GUI::DrawText(getTranslatedString("No Respawning - Wait for the Game to End.") , Vec2f(getScreenWidth() / 2 - 180, getScreenHeight() / 3 + Maths::Sin(getGameTime() / 3.0f) * 5.0f), SColor(255, 255, 255, 55));
			}
			else
			{
				GUI::DrawText(getTranslatedString("Respawning in:") + " " + spawn , Vec2f(getScreenWidth() / 2 - 70, getScreenHeight() / 3 + Maths::Sin(getGameTime() / 3.0f) * 5.0f), SColor(255, 255, 255, 55));
			}
		}
	}
}
