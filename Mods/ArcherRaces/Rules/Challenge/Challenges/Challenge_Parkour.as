#include "ChallengesCommon.as"
#include "HSVToRGB.as"

bool myPlayerGotToTheEnd = false;
int checkpointCount = 0;
string endGameText = "Everyone has completed the course!";
const float END_DIST = 16.0f;

void Reset(CRules@ this)
{
	myPlayerGotToTheEnd = false;
	checkpointCount = 0;

	// reset last times
	ConfigFile stats;
	if (stats.loadFile("../Cache/" + g_statsFile))
	{
		for (uint i = 0; i < getPlayerCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			if (player !is null)
			{
				const string name = player.getUsername();
				stats.add_u32(name + "_last", -1);

				if(stats.exists(name + "_best"))
				{
					stats.add_u32(name + "_prevbest", stats.read_u32(name + "_best"));
				}
			}
		}

		stats.saveFile(g_statsFile);
	}

	this.addCommandID("end_confetti");
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void onInit(CRules@ this)
{
	Reset(this);
}

void onInit(CMap@ this)
{
	CRules@ rules = getRules();
	SetIntroduction(rules, "Parkour");

	if (getNet().isServer())
	{
		//rules.set_bool("repeat if dead", true);

		Vec2f endPoint;
		if (!this.getMarker("checkpoint", endPoint))
		{
			warn("End game checkpoint not found on map");
		}
		rules.set_Vec2f("endpoint", endPoint);
		rules.Sync("endpoint", true);

		// make stats file
		Stats_MakeFile(rules, "parkour");
		ConfigFile stats;
		if (!stats.loadFile("../Cache/" + g_statsFile))
		{
			stats.saveFile(g_statsFile);
		}
	}

	AddRulesScript(rules);
}

void onTick(CMap@ this)
{
	CRules@ rules = getRules();
	// local player check end

	CBlob@ localBlob = getLocalPlayerBlob();
	if (localBlob !is null)
	{
		Vec2f endPoint = rules.get_Vec2f("endpoint");
		if (!myPlayerGotToTheEnd && (localBlob.getPosition() - endPoint).getLength() < END_DIST)
		{
			myPlayerGotToTheEnd = true;
			Sound::Play("/VehicleCapture");
		}
	}

	// server check

	if (getNet().isServer())
	{
		// server check

		Vec2f endPoint = rules.get_Vec2f("endpoint");
		CBlob@[] blobsNearEnd;
		if (this.getBlobsInRadius(endPoint, END_DIST, @blobsNearEnd))
		{
			for (uint i = 0; i < blobsNearEnd.length; i++)
			{
				CBlob @b = blobsNearEnd[i];
				if (b.getPlayer() !is null && !b.hasTag("checkpoint"))
				{
					b.Tag("checkpoint");
					checkpointCount++;

					CBitStream params;
					params.write_Vec2f(endPoint);
					rules.SendCommand(rules.getCommandID("end_confetti"), params);

					CRules@ rules = getRules();

					// stat time
					ConfigFile stats;
					if (stats.loadFile("../Cache/" + g_statsFile))
					{
						const string playerName = b.getPlayer().getUsername();
						const u32 currentTime = Stats_getCurrentTime(rules);

						CBlob@[] players;
						getBlobsByTag("player", @players);
						int playersCount = 0;

						for (uint i = 0; i < players.length; i++)
						{
							if (players[i].getTeamNum() == 0)
								playersCount++;
						}

						if (checkpointCount == playersCount) // all players
						{
							rules.set_bool("played fanfare", true); //
							DefaultWin(rules);
							rules.SetGlobalMessage(endGameText);
						}

						Stats_Mark_IndividualLastTime(stats, playerName, currentTime);
						Stats_Mark_IndividualBestTime(stats, playerName, currentTime);

						string output;
						output += Stats_Begin_Output();
						output += Stats_Output_TeamTimeMeasures(stats);
						Stats_Send(rules, output);

						stats.saveFile(g_statsFile);
					}
				}
			}
		}
	}
}

// render

void onRender(CRules@ this)
{
	//if (!myPlayerGotToTheEnd)
	{
		Vec2f endPoint = this.get_Vec2f("endpoint");
		//printf("endPoint " + endPoint.x + " " + endPoint.y + " " + myPlayerGotToTheEnd);
		Vec2f pos2d = getDriver().getScreenPosFromWorldPos(endPoint);
		pos2d.x -= 28.0f;
		pos2d.y -= 32.0f + 16.0f * Maths::Sin(getGameTime() / 4.5f);
		GUI::DrawIconByName("$DEFEND_THIS$",  pos2d);
	}

	// show stats

	//stats from rules

	Stats_Draw(this);
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if(cmd == this.getCommandID("end_confetti"))
	{
		Vec2f pos = params.read_Vec2f();

		for(int i = 0; i < 100; i++)
		{
			Vec2f velr = getRandomVelocity(90.0f, 5.0f, 90.0f) * (0.75f + float(XORRandom(100)) / 200.0f);
			//velr.y = -Maths::Abs(velr.y) + Maths::Abs(velr.x) / 3.0f - 2.0f - float(XORRandom(100)) / 100.0f;
			ParticlePixel(pos, velr, HSVToRGB(XORRandom(359), 1.0f, 1.0f), true);
		}
	}
}
