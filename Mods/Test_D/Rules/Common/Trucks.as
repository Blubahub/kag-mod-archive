#define SERVER_ONLY

#include "ClassesCommon.as"
#include "GamemodeCommon.as"
#include "BackendCommon.as"
#include "LobbyCommon.as"
#include "BackendHelper.as"
#include "InterServerPlayerSync.as"
#include "LobbyStatsCommon.as"
#include "TrucksCommon.as"

void onTick(CRules@ this)
{
	bool _hasSkirmishTruck = false;
	bool _hasBlueTruck = false;
	bool _hasRedTruck = false;

	CBlob@[] trucks;
	getBlobsByName("truck", @trucks);

	int skirmish_needed = this.get_u32("players_required_skirmish");
	CBlob@ skirmishtruck = null;

	int campaign_needed = this.get_u32("players_required_perteam_campaign");
	CBlob@ campaign_beer = null;
	CBlob@ campaign_wine = null;

	//find the respective trucks
	for (uint i = 0; i < trucks.length; i++)
	{
		CBlob@ truck = trucks[i];
		if (truck.getTeamNum() == 255)
		{
			_hasSkirmishTruck = true;
			@skirmishtruck = truck;
		}
		if (truck.getTeamNum() == 0)
		{
			_hasRedTruck = true;
			@campaign_beer = truck;
		}
		if (truck.getTeamNum() == 1)
		{
			_hasBlueTruck = true;
			@campaign_wine = truck;
		}
	}

	//spawn them if needed
	if (!_hasSkirmishTruck)
	{
		@skirmishtruck = SpawnTruck("skirmish truck", 255);
	}
	if (!_hasRedTruck)
	{
		@campaign_beer = SpawnTruck("red truck", 0);
	}
	if (!_hasBlueTruck)
	{
		@campaign_wine = SpawnTruck("blue truck", 1, 80.0f);
	}

	//check each gamemode's ready
	//skirmish
	if (skirmishtruck !is null)
	{
		if (skirmishtruck.hasTag("riding away") && !skirmishtruck.hasTag("started game"))
		{
			Vec2f pos = skirmishtruck.getPosition();
			CMap@ map = getMap();
			if (pos.x < 5.0f || pos.x > map.tilesize * map.tilemapwidth - 5.0f) // HACK
			{
				Lobby::Server@ freeServer = getFreeServerFor(skirmishtruck, true);
				if (freeServer !is null)
				{
					CPlayer@[] queuedPlayers;
					GetPlayersFromTruck(skirmishtruck, queuedPlayers);
					StartGameAt(this, queuedPlayers, freeServer);
				}
				skirmishtruck.Tag("started game");
			}
		}
		else if (skirmishtruck.getAttachments().getOccupiedCount() >= skirmish_needed)
		{
			skirmishtruck.Tag("ready");

			Lobby::Server@ freeServer = getFreeServerFor(skirmishtruck);

			if (freeServer is null)
			{
				skirmishtruck.Tag("waiting_server");
				skirmishtruck.Untag("ready");

				if(isWarningTime())
				{
					NoGame(this, skirmishtruck, true);
				}
			}
			else if(countdownGame(skirmishtruck))
			{
				skirmishtruck.Untag("waiting_server");

				string gamemode = skirmishtruck.get_string("gamemode");
				printf("Truck drove off to " + gamemode);

				// redirect players in the queue
				RideAway(skirmishtruck);
			}

			if (sv_test && skirmishtruck.getAttachments().getOccupiedCount() >= 4){
				skirmishtruck.Untag("waiting_server");
				RideAway(skirmishtruck);	
			}
		}
		else
		{
			skirmishtruck.Untag("waiting_server");
			skirmishtruck.Untag("ready");
		}
	}

	//campaign
	if (campaign_beer !is null && campaign_wine !is null)
	{
		if (campaign_beer.hasTag("riding away") && !campaign_beer.hasTag("started game"))
		{
			Vec2f pos1 = campaign_beer.getPosition();
			Vec2f pos2 = campaign_wine.getPosition();
			CMap@ map = getMap();
			if (pos1.x < 5.0f || pos1.x > map.tilesize * map.tilemapwidth - 5.0f ||
			    pos2.x < 5.0f || pos2.x > map.tilesize * map.tilemapwidth - 5.0f) // HACK
			{
				print("campaign drove off");
				Lobby::Server@ freeServer = getFreeServerFor(campaign_beer, true);
				if (freeServer !is null)
				{
					print("free server found");
					CPlayer@[] queuedPlayers;
					GetPlayersFromTruck(campaign_beer, queuedPlayers);
					GetPlayersFromTruck(campaign_wine, queuedPlayers);
					StartGameAt(this, queuedPlayers, freeServer);
				}
				campaign_beer.Tag("started game");
			}
		}
		else if (campaign_beer.getAttachments().getOccupiedCount() + campaign_wine.getAttachments().getOccupiedCount() >= campaign_needed)
		{
			campaign_beer.Tag("ready");
			campaign_wine.Tag("ready");

			Lobby::Server@ freeServer = getFreeServerFor(campaign_beer);
			if (freeServer is null)
			{
				campaign_beer.Tag("waiting_server");
				campaign_wine.Tag("waiting_server");

				campaign_beer.Untag("ready");
				campaign_wine.Untag("ready");

				if(isWarningTime())
				{
					NoGame(this, campaign_beer, false);
					NoGame(this, campaign_wine, true);
				}
			}
			else if (countdownGame(campaign_wine) || countdownGame(campaign_beer))
			{
				campaign_beer.Untag("waiting_server");
				campaign_wine.Untag("waiting_server");

				string gamemode = campaign_beer.get_string("gamemode");
				printf("Trucks drove off to " + gamemode);

				RideAway(campaign_beer);
				RideAway(campaign_wine);
			}

			if (sv_test && campaign_beer.getAttachments().getOccupiedCount() >= 5){
				campaign_beer.Untag("waiting_server");
				campaign_wine.Untag("waiting_server");
				RideAway(campaign_beer);
				RideAway(campaign_wine);
			}

		}
		else
		{
			campaign_beer.Untag("waiting_server");
			campaign_wine.Untag("waiting_server");

			campaign_beer.Untag("ready");
			campaign_wine.Untag("ready");
		}
	}

	//iterate for not-ready trucks to reset timer
	for (uint i = 0; i < trucks.length; i++)
	{
		CBlob@ truck = trucks[i];
		if (!truck.hasTag("ready") && !truck.hasTag("riding away"))
		{
			truck.set_u32("leave_time", 0);
		}
		truck.Sync("leave_time", true);
	}
}

CBlob@ SpawnTruck(const string &in name, const int team, f32 shiftX = 0.0f)
{
	CMap@ map = getMap();
	Vec2f spawn;
	const f32 mapwidth = map.tilesize * map.tilemapwidth;
	if (map.getMarker(name, spawn))
	{
		const bool toLeft = spawn.x < mapwidth / 2.0f;
		CBlob@ truck = server_CreateBlobNoInit("truck");
		if (truck !is null)
		{
			printf("spawned " + name);
			truck.server_setTeamNum(team);
			truck.setPosition(Vec2f((toLeft ? mapwidth : 0.0f) + shiftX, spawn.y - 4.0f));
			truck.set_Vec2f("target", spawn);
			truck.set_bool("to left", toLeft);

			//set gamemode
			//todo: maybe find a nicer way to do this?
			u8 in_cap = 5;
			string gamemode = "Campaign";
			if (name.find("skirmish") != -1)
			{
				gamemode = "Skirmish";
				in_cap = 4;
			}

			truck.set_string("gamemode", gamemode);
			truck.set_u8("in_cap", in_cap);
			truck.Init();
		}
		return truck;
	}
	else
	{
		warn("missing spawn for " + name);
		return null;
	}
}

bool countdownGame(CBlob@ truck)
{
	if (truck.hasTag("riding away"))
		return false;

	u32 leave_time = truck.get_u32("leave_time");
	if (leave_time == 0)
	{
		leave_time = Time() + getRules().get_u32("launch_secs");
		truck.set_u32("leave_time", leave_time);
	}
	return (Time() >= leave_time);
}

bool isWarningTime()
{
	u32 seconds = 30;
	return (getGameTime() % (seconds * 30)) == 0;
}

void NoGame(CRules@ this, CBlob@ truck, bool driverChat)
{
	printf("NO FREE SERVER FOUND");

	//so we dont keep spamming cmds
	truck.Untag("ready");

	CBitStream params;
	params.write_bool(driverChat);
	truck.SendCommand(truck.getCommandID("no game"), params);
}

void StartGameAt(CRules@ this, CPlayer@[] queuedPlayers, Lobby::Server@ freeServer)
{
	printf("LAUNCH TO " + freeServer.address /*+ " | bets: " + Lobby::getPlayerBets(queuedPlayers) */);

	//send shit to the server
	Lobby::SyncStringToServer(freeServer, "class_picks", BuildPlayerSyncStringFrom(queuedPlayers));
	Lobby::SyncU32ToServer(freeServer, "winner_reward", this.get_u32("winner_reward") );
	Lobby::SyncU32ToServer(freeServer, "entry_cost", this.get_u32("game_entry_cost"));
	//Lobby::RemoveBets(queuedPlayers);

	//stats
	getStats().gameStarted();
	getStats().GameWithPlayers(queuedPlayers, Lobby::serverHasInStatus(freeServer, "Campaign"));

	//flag it used
	Lobby::RecentlyUsedServers@ rus = Lobby::getRecentlyUsedServers();
	if(rus !is null)
	{
		rus.Add(freeServer.address, queuedPlayers);
	}

	//redirect players
	for (uint i = 0; i < queuedPlayers.length; i++)
	{
		Backend::RedirectPlayer(this, queuedPlayers[i], freeServer.address);
	}
}

void RideAway(CBlob@ truck)
{
	CBitStream params;
	truck.SendCommand(truck.getCommandID("ride away"), params);
}

Lobby::Server@ getFreeServerFor(CBlob@ blob, bool print_debug = false)
{
	string gamemode = blob.get_string("gamemode");
	Lobby::Server[]@ servers = Lobby::getServers();
	Lobby::RecentlyUsedServers@ rus = Lobby::getRecentlyUsedServers();

	if(servers is null || rus is null) return null;

	for (uint i = 0; i < servers.length; i++)
	{
		Lobby::Server@ server = servers[i];
		bool compatible = Lobby::serverHasInStatus(server, gamemode);
		bool isFree = Lobby::serverHasInStatus(server, "free");
		bool used = rus.contains(server.address);

		if (print_debug)
		{
			print("server " + server.address + " " +
			      (server.connectable ? "online" : "offline") + " " +
			      (compatible ? "compatible" : "wrong gamemode") + " " +
			      (isFree ? "free" : "busy") + " " +
			      (used ? "used" : "not used"));
		}

		if (server.connectable && compatible && isFree && !used)
		{
			return server;
		}
	}
	return null;
}
