#include "ChallengesCommon.as"

bool myPlayerGotToTheEnd = false;
int checkpointCount = 0;
string endGameText = "Everyone has completed the course!";
const float END_DIST = 16.0f;

void Reset(CRules@ this)
{
	myPlayerGotToTheEnd = false;
	checkpointCount = 0;
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

		if (rules.isGameOver())
		{
			// sync stats

			if (!rules.get_bool(synced_stats_tag))
			{
				ConfigFile stats;
				if (stats.loadFile("../Cache/" + g_statsFile))
				{
					string output;
					output += Stats_Begin_Output();
					output += Stats_Output_TeamTimeMeasures(stats);

					Stats_Send(rules, output);
				}
				rules.set_bool(synced_stats_tag, true);
				rules.Sync(synced_stats_tag, true);
			}

			return;
		}

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

						Stats_Mark_IndividualTime(stats, playerName, currentTime);

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
