#include "GameColours.as"
#include "LobbyStatsCommon.as"
#include "LobbyCommon.as"
#include "BackendCommon.as"

string[] _ingameNames;

void onInit(CRules@ this)
{
	this.addCommandID("servers");
}

void onTick(CRules@ this)
{
	// periodically renew servers info
	if (getNet().isServer())
	{		
		{
			CBlob@[] players;
			getBlobsByTag("player", @players);
			for (uint i = 0; i < players.length; i++)
			{
				CBlob@ blob = players[i];
				if (!blob.hasTag("sent players") || getGameTime() % 150 == 0)
				{
					SendServersToPlayer( this, blob.getPlayer());
					blob.Tag("sent players");
				}
			}									
		}
	}
}

void SendServersToPlayer( CRules@ this, CPlayer@ player )
{
	if (getNet().isServer() && player !is null)
	{
		LobbyStats@ stats = getStats();

		string[] names;
		for (int i = 0; i < stats._players_times_cache.length; i++)
		{
			string name = stats._players_cache[i];
			if (stats._players_times_cache[i] > Time() - 5 * 60 && name != player.getCharacterName())
			{
				// check if name in lobby
				for (u32 i = 0; i < getPlayersCount(); i++)
				{
					CPlayer@ p = getPlayer(i);
					if (p.getCharacterName() == name){
						continue;
					}
				}
				names.push_back(name);
			}
		}		

		//TEST
		/*names.push_back("1Homer");
		names.push_back("2Lisa");
		names.push_back("mm");
		names.push_back("const");

		names.push_back("1Homer");
		names.push_back("2Lisa");
		names.push_back("fdgdsfgsdf");
		names.push_back("WJAJAJAJ");

		names.push_back("1Homer 1Homer");
		names.push_back("2Lisa 2Lisa");
		names.push_back("3Bart 3Bart");
		names.push_back("const");	*/			

		//TEST

		if(player !is null && !player.isBot())
		{
			CBitStream params;
			params.write_u16(names.length);
			for (uint i=0; i < names.length; i++)
			{
				params.write_string(names[i]);
			}

			this.SendCommand(this.getCommandID("servers"), params, player);			
		}		
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("servers") && getNet().isClient())
	{
		_ingameNames.clear();
		u16 length = params.read_u16();
		for (uint i=0; i < length; i++)
		{
			_ingameNames.push_back( params.read_string() );
		}
	}
}

void onRenderScoreboard(CRules@ this)
{

	//sort players
	CPlayer@[] sortedplayers;
	CPlayer@[] spectators;
	for (u32 i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ p = getPlayer(i);
		f32 kdr = p.getKills();
		bool inserted = false;
		if (p.getTeamNum() == this.getSpectatorTeamNum())
		{
			spectators.push_back(p);
			continue;
		}
		for (u32 j = 0; j < sortedplayers.length; j++)
		{
			if (sortedplayers[j].getKills() < kdr)
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

	f32 stepheight = 16;
	f32 hmargin = 20;
	Vec2f topleft(hmargin, 40);
	Vec2f bottomright(getScreenWidth() - hmargin, topleft.y + (sortedplayers.length + (spectators.length == 0 ? 0 : 2) + 3.5) * stepheight);

	Vec2f old_bottomright = bottomright;
	bottomright.y += stepheight * Maths::Ceil(float(_ingameNames.length) / 5.0f) + 4;

	GUI::DrawPane(topleft, bottomright, SColor(0xffc0c0c0));

	//offset border

	topleft.x += stepheight;
	bottomright.x -= stepheight;
	topleft.y += stepheight;

	//draw _ingameNames

	GUI::SetFont("gui");

	if (_ingameNames.length > 0)
	{
		f32 specy = old_bottomright.y;
		GUI::DrawLine2D(Vec2f(topleft.x, specy), Vec2f(bottomright.x, specy), SColor(0xff404040));

		Vec2f textdim;
		string s = "In-game:";
		GUI::GetTextDimensions(s, textdim);

		GUI::DrawText(s, Vec2f(topleft.x, specy), SColor(0xffaaaaaa));

		f32 specx = topleft.x + textdim.x + 10;
		for (u32 i = 0; i < _ingameNames.length; i++)
		{
			string name = _ingameNames[i];
			if (specx < bottomright.x - 100)
			{
				if (i != _ingameNames.length - 1)
					name += ",";
				GUI::GetTextDimensions(name, textdim);
				GUI::DrawText(name, Vec2f(specx, specy), color_white);
				specx += textdim.x + 10;
			}
			else
			{
				specx = topleft.x + textdim.x + 10;
				specy += stepheight;
			}
		}
	}

	//draw player table header

	const f32 boxwidth = (bottomright.x - topleft.x);
	GUI::DrawText("Player", Vec2f(topleft.x, topleft.y), SColor(0xffffffff));
	GUI::DrawText("Ping", Vec2f(topleft.x + boxwidth * 0.5f, topleft.y), SColor(0xffffffff));
	GUI::DrawText("Kills", Vec2f(topleft.x + boxwidth * 0.7f, topleft.y), SColor(0xffffffff));
	GUI::DrawText("Deaths", Vec2f(topleft.x + boxwidth * 0.9f, topleft.y), SColor(0xffffffff));
//	GUI::DrawText("KDR", Vec2f(bottomright.x - 100, topleft.y), SColor(0xffffffff));

	topleft.y += stepheight * 0.5f;

	CControls@ controls = getControls();
	Vec2f mousePos = controls.getMouseScreenPos();

	//draw players
	for (u32 i = 0; i < sortedplayers.length; i++)
	{
		CPlayer@ p = sortedplayers[i];

		topleft.y += stepheight;
		bottomright.y = topleft.y + stepheight;

		Vec2f lineoffset = Vec2f(0, 0);

		u32[] teamcolours = {0xff6666ff, 0xffff6666};
		u32 playercolour = (p.getBlob() is null || p.getBlob().hasTag("dead")) ? 0xffaaaaaa :
		                   teamcolours[p.getBlob().getTeamNum() % teamcolours.length];

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
			// tex = p.getScoreboardTexture();
			// frame = p.getScoreboardFrame();
			// framesize = p.getScoreboardFrameSize();
			tex = "HoverIcons.png";
			frame = p.getClassNum();
			framesize.Set(16, 16);
		}
		if (tex != "")
		{
			GUI::DrawIcon(tex, frame, framesize, topleft, 0.5f, p.getTeamNum());
		}

		string playername = "";
		if (mousePos.y > topleft.y && mousePos.y < topleft.y + 15)
		{
			playername = " " + p.getUsername();
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
		GUI::DrawText(playername, topleft + Vec2f(20, 0), getTeamColor(p.getTeamNum()));

		if (p.isBot())
			GUI::DrawText("(CPU)", Vec2f(topleft.x + boxwidth * 0.5f, topleft.y), SColor(0xffffffff));
		else
			GUI::DrawText("" + ping_in_ms, Vec2f(topleft.x + boxwidth * 0.5f, topleft.y), SColor(0xffffffff));
		GUI::DrawText("" + p.getKills(), Vec2f(topleft.x + boxwidth * 0.7f, topleft.y), SColor(0xffffffff));
		GUI::DrawText("" + p.getDeaths(), Vec2f(topleft.x + boxwidth * 0.9f, topleft.y), SColor(0xffffffff));
		//GUI::DrawText("" + formatFloat(getKDR(p), "", 3, 1), Vec2f(bottomright.x - 100, topleft.y), SColor(0xffffffff));
	}
}
