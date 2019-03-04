#include "BackendCommon.as"
#include "LobbyCommon.as"
#include "SoldierCommon.as"
#include "Pets.as"

#define SERVER_ONLY

//handle a specific server response, add or update a skirmish lobby server
void HandleServer(CRules@ rules, Backend::Request@ request)
{
	Backend::ServerResponse@ response = null;
	request.parsed_data.get("server", @response);
	if (response is null || !response.found)
		return;

	Lobby::Server@ s = Lobby::getServerFromAddress(response.address);
	s.connectable = response.connected;
	s.status = response.status;

	print("received server status: \n" + s.address +
	      "\n    " + (s.connectable ? "" : "not ") + "connectable" +
	      "\n    " + join(s.status, ","));

	if (s.connectable)
	{
		rules.set_string("last lobby address", s.address);
	}
}

void HandleList(CRules@ rules, Backend::Request@ request)
{
	print("received servers");

	string[]@ recd_servers = null;
	request.parsed_data.get("servers", @recd_servers);
	if (recd_servers is null) return;

	print(join(recd_servers, ", "));

	//chain requests - query all the servers resulting from this list query
	for (uint i = 0; i < recd_servers.length; i++)
	{
		Backend::QueryServer(recd_servers[i], Backend::TemporaryQueryString(), @HandleServer);
	}
}

void UpdateServersList()
{
	Backend::QueryList(Backend::TemporaryQueryString(), @HandleList);
}

void HandlePlayer(CRules@ rules, Backend::Request@ request)
{
	Backend::PlayerResponse@ response = null;
	request.parsed_data.get("player", @response);
	if (response is null)
		return;

	Lobby::PlayerRecord@ p = Lobby::getPlayerRecordFromUsername(response.username);
	//set the coins, skin etc
	p.coins = response.coins;
	p.skin = response.skin;
	p.pet = response.pet;
	p.drunk_amount = response.drunk_amount;
	p.drunk_timer = response.drunk_timer;

	//parse the stat info
	string[] stat_chunks = response.stats_raw.split("||");
	for (u32 i = 0; i < stat_chunks.length; i++)
	{
		string[] stat_chunk = stat_chunks[i].split(":");
		if (stat_chunk.length == 2)
		{
			p.stat_names.push_back(stat_chunk[0]);
			p.stat_values.push_back(parseInt(stat_chunk[1]));
		}
	}

	//ensure player exists
	CPlayer@ player = p.player();
	if (player !is null)
	{
		//do extra lobby stuff - add skins, pets, coins
		if (rules.get_string("gamemode") == "Lobby")
		{
			//setup coins
			player.server_setCoins(p.coins);

			//drunk decay logic
			bool drunk_changed = false;
			while (p.drunk_amount > 0 && p.drunk_timer > 0 && p.drunk_timer < Time())
			{
				p.drunk_timer += Backend::DRINK_DECAY_TIME_SECONDS;
				p.drunk_amount--;
				if (p.drunk_amount == 0)
				{
					p.drunk_timer = 0;
				}
				drunk_changed = true;
			}

			if (drunk_changed)
			{
				//tell backend
				Backend::SetPlayerDrunk(player, p.drunk_amount);
			}

			//set stuff into the blob
			CBlob@ b = player.getBlob();
			if (b !is null && b.getName() == "soldier")
			{
				//load skin
				CBitStream params;
				params.write_u8(p.skin);
				b.SendCommand(Soldier::Commands::CIVILIAN_LOADSKIN, params);

				// spawn pet (if owned and doesn't exist yet)
				if (p.pet >= 0 && !hasPet(b))
				{
					SpawnPet(b, p.pet, b.getPosition(), true);
				}

				//set drunk amount
				b.set_u8("drunk_amount", p.drunk_amount);
				b.Sync("drunk_amount", true);
			}
		}

		print("received player status: \n" + p.username +
		      "\n    coins: " + p.coins +
		      "\n    skin:  " + p.skin +
		      "\n    pet:   " + p.pet);
	}
	//otherwise remove the record
	else
	{
		Lobby::removePlayerRecord(response.username);

		print("received player status: (" + p.username + ") but they've left");
	}
}

void SendPlayerQuery(CPlayer@ p)
{
	//construct our own query string here - we dont want
	//to get wrap-around if theres 100 people in one lobby
	Backend::QueryPlayer(p, "tr_query_" + p.getUsername(), @HandlePlayer);
}

void UpdatePlayersList()
{
	for (int i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ p = getPlayer(i);
		if (p.isBot()) continue;
		SendPlayerQuery(p);
	}
}

void UpdateLobbyStuff()
{
	UpdateServersList();
	UpdatePlayersList();
}

//////////////////////////////////////////
//actual rules hooks

int last_time = Time();
const int update_interval = 30; //interval in seconds for updating both players and servers

int force_countdown = 0;
const int force_countdown_ticks = 30; //interval in ticks to delay a force update (allows >1 force to not spam the api)

void onInit(CRules@ this) { onRestart(this); }
void onReload(CRules@ this) { onRestart(this); }
void onRestart(CRules@ this)
{
	//update as soon as we tick (avoids any weirdness during the restart)
	last_time = 0;
	Lobby::init();
}

void onTick(CRules@ this)
{
	if (!this.hasTag("use_backend"))
	{
		return;
	}

	//every interval, update the server list
	int time_now = Time();
	bool force_update = this.hasTag("force_lobby_update");
	if ((time_now - last_time > update_interval && getPlayersCount() > 0) || // only if players are present
	        (force_update && (--force_countdown) <= 0))
	{
		UpdateLobbyStuff();
		last_time = time_now;
		force_countdown = force_countdown_ticks;
		this.Untag("force_lobby_update");
	}
	else if (!force_update)
	{
		force_countdown = force_countdown_ticks;
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	if (player.isBot())
	{
		return;
	}

	if (!this.hasTag("use_backend"))
	{
		return;
	}

	//shred existing so we dont get old coins
	Lobby::removePlayerRecord(player.getUsername());
	SendPlayerQuery(player);
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	Lobby::removePlayerRecord(player.getUsername());
}

