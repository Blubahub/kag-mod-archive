
/*
	required includes (not included here to avoid multiple inclusions which are hard to debug):

	#include "BackendCommon.as"
	#include "BackendHelper.as"
	#include "LobbyCommon.as"
	#include "InterServerPlayerSync.as"

REQUIRES A FEW DEFINITIONS:

	void SpawnPlayers(CRules@ this)
		spawn all players (called at the start of each match 3s after the game has started)

	void NextMap(CRules@ this)
		do everything required on nextmap and actually load the next map

	string[] getWinners()
		get the names of all the winners (used for coin allocations)
*/

namespace BackendGame
{
	u32 init_time = 0;

	string[] players;

	string _lastServerStatus = "";
	string _lastPlayerPicks = "";

	int disconnectedPlayers;

	CRules@ rules;

	enum GameState
	{
		state_uninitialised,
		state_prematch,
		state_match,
		state_postmatch
	};

	GameState state = state_uninitialised;

	//initialise the backend game info
	//only do this when a new game
	//is going to start because we've
	//got players - dont call it every map!
	void init()
	{
		print("backend gamemode initialised.");

		@rules = getRules();
		init_time = Time();
		state = state_prematch;
		disconnectedPlayers = 0;

		set_synced_started(false);

	}

	//update internal state
	//(check ready etc afterwards if we're still in the prematch)
	void update()
	{
		@rules = getRules();
		//keep backend synced stuff up to date
		{
			if(state != state_postmatch) //dont re-send state after end of game
			{
				string status = BuildServerStatus();
				if (status != _lastServerStatus || ((getGameTime() % (30 * 60)) == 0))
				{
					UpdateServerStatus(status);
					printf("update: state " + state + " _lastPlayerPicks " + _lastPlayerPicks + " can_start_game() " + can_start_game() + " players " + human_players() + "/" + countPlayersInSyncString(_lastPlayerPicks) );
					printf(" Time() " + Time() + " init_time " + init_time + " disconnectedplayers " + disconnectedPlayers );
				}
			}

			string class_picks = rules.get_string("class_picks");
			if (class_picks != _lastPlayerPicks)
			{
				print("picks changed");

				//start the game
				init();

				_lastPlayerPicks = class_picks;
				ApplyPlayersSyncString(_lastPlayerPicks);
			}
		}

		//printf("state " + state + " " + state_prematch + " _lastPlayerPicks " + _lastPlayerPicks);

		if (state == state_prematch) //waiting for players
		{
			if (_lastPlayerPicks != "")
			{
				string timer_name = "start_game";

				if (can_start_game())
				{
					//print("ready!");
					ApplyPlayersSyncString(_lastPlayerPicks);

					if (Game::getTimer(timer_name) is null)
					{
						if (!rules.hasTag("backend_game_started"))
						{
							Game::CreateTimer(timer_name, 1, @Callback_NewGame, false);
						}
						else
						{
							Game::CreateTimer(timer_name, 3, @Callback_StartGame, false);
						}
					}
				}
				else
				{
					//print("not ready!");
					//clear start game timer
					Game::ClearTimer(timer_name);
					//check failure to connect automagically
					if (failed_to_connect())
					{
						cancel();
					}
				}
			}
		}
		else if (state == state_match) //definitely had players, playing
		{
			//force teams + dc any sneaks
			if(_lastPlayerPicks != "")
			{
				ApplyPlayersSyncString(_lastPlayerPicks);
			}

			//no winners in a DC game, fuckers.
			if (all_disconnected())
			{
				cancel();
			}
			//end of a game (not the match), check for extra or missing players and balance with bots
			else if (rules.isGameOver())
			{
				handle_bots();
			}
		}
		else if (state == state_postmatch)
		{
			//nothing to do for now, we're done with the match!
		}
	}

	//status functions throughout the game
	//if the game is ready to start (everyone connected + teams applied)
	bool ready()
	{
		u32 currentplayers = human_players();
		u32 intendedplayers = countPlayersInSyncString(_lastPlayerPicks) - disconnectedPlayers;
		return currentplayers > 0 && currentplayers >= intendedplayers; //(not sure how we'd get more, but don't break if it happens)
	}

	//if the game can still start after ready timeout (we just lost one motherfucker)
	bool mostly_ready()
	{
		u32 currentplayers = human_players();
		return currentplayers >= 2 || ready();
	}

	//some players didn't make it within 20s, bail
	bool failed_to_connect()
	{
		return Time() >= init_time + 20;
	}

	//
	bool can_start_game()
	{
		return ready() || (mostly_ready() && failed_to_connect());
	}

	//if all the players quit
	bool all_disconnected()
	{
		return human_players() == 0;
	}

	//cancel the game if noone showed up or if everyone dc'd
	//(doesn't pay anyone, resets the server to free status,
	// and tells the backend we're ready to go again)
	void cancel()
	{
		print("cancelled the game...");

		sendPlayersHome();

		_clear_postgame();
	}

	//start the game
	//(takes coins from players)
	void start()
	{
		print("start the game!");

		ApplyPlayersSyncString(_lastPlayerPicks);

		state = state_match;
		{
			//take the entry cost coins
			s32 entry_cost = 0;
			if (rules.exists("entry_cost"))
			{
				entry_cost = s32(rules.get_u32("entry_cost"));

				//sync; assume we got the other one too
				rules.Sync("entry_cost", true);
				rules.Sync("winner_reward", true);
			}

			print("(handling player coins)");
			for (uint i = 0; i < getPlayersCount(); i++)
			{
				CPlayer@ player = getPlayer(i);
				if (!player.isBot())
				{
					Backend::PlayerCoinTransaction(player, -entry_cost);
					Backend::PlayerMetric(player, "play_game");
				}
			}
		}

		print("(handling bots)");

		handle_bots();

		set_synced_started(true);

		print("(nextmap)");

		NextMap(rules);

		print("(done!)");
	}

	//end the game
	void end()
	{
		print("ending the game!");

		string[] winner_names = getWinners();
		//give coins on backend to winners
		{
			u32 winner_reward = 1;
			if (rules.exists("winner_reward"))
			{
				winner_reward = rules.get_u32("winner_reward");
			}

			for (uint i = 0; i < getPlayersCount(); i++)
			{
				CPlayer@ player = getPlayer(i);
				if (player.isBot()) continue;

				print("checking winner: " + player.getUsername());

				//check if we're a winner :)
				for (u32 name_iter = 0; name_iter < winner_names.length; name_iter++)
				{
					u32 bet = player.get_u32("bet");

					if (player.getUsername() == winner_names[name_iter])
					{
						u32 this_reward = winner_reward;

						// check if he placed bets
						if (bet > 0)
						{
							for (uint ii = 0; ii < getPlayersCount(); ii++)
							{
								CPlayer@ p2 = getPlayer(ii);
								this_reward += p2.get_u32("bet") % (bet + 1);
							}
						}

						Backend::PlayerCoinTransaction(player, this_reward);
						Backend::PlayerMetric(player, "win_game");

						player.server_setCoins(this_reward - bet);
						print("is winner! " + this_reward + " bet " + bet);
						break;
					}
					else
					{
						Backend::PlayerMetric(player, "lose_game");
						player.server_setCoins(bet);
						print("lost " + bet);
					}
				}
			}
		}

		_clear_postgame();
	}

	//

	bool matchRunning()
	{
		return state == state_match;
	}

	//

	void handle_bots()
	{
		//add bots up to player count
		for (u32 i = getPlayersCount(); i < sv_maxplayers; i++)
		{
			AddBot("CPU", 255, 255);
		}
		//some player joined "late" - remove bots down to player count
		if (getPlayersCount() > sv_maxplayers)
		{
			u32 toremove = sv_maxplayers - getPlayersCount();
			print("attempting to remove bots.. have "+toremove+" too many players.");

			bool found = false;
			CPlayer@[] removeplayers;
			//disconnect a bot if there is one
			for (uint i = 0; i < getPlayersCount() && toremove > 0; i++)
			{
				CPlayer@ player = getPlayer(i);
				if (player.isBot())
				{
					removeplayers.push_back(player);
					toremove--;
				}
			}
			for(u32 i = 0; i < removeplayers.length; i++)
			{
				KickPlayer(removeplayers[i]);
			}
			//(player management from script is a mess)
		}
	}

	void _clear_postgame()
	{
		init_time = 0;
		disconnectedPlayers = 0;
		//clear out the class picks
		_lastPlayerPicks = "";
		rules.set_string("class_picks", "");

		// kick bots
		for (uint i = 0; i < getPlayersCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			if (player.isBot())
			{
				KickPlayer(player);
			}
		}

		set_synced_started(false);

		state = state_postmatch;
		UpdateServerStatus(BuildServerStatus(true));
	}

	void sendPlayersHome()
	{
		Backend::RedirectBackToLobby(rules);
	}

//timer callbacks

	void Callback_NewGame(Game::Timer@ this)
	{
		print("start match");
		start();
	}

	void Callback_StartGame(Game::Timer@ this)
	{
		print("start game");
		SpawnPlayers(this.rules);

		//import drunk amount for all players that its avilable for
		Lobby::PlayerRecord[]@ players = Lobby::getPlayers();
		for(u32 i = 0; i < players.length; i++)
		{
			CPlayer@ p = players[i].player();
			if(p is null) continue;
			CBlob@ b = p.getBlob();
			if(b is null) continue;

			b.set_u8("drunk_amount", players[i].drunk_amount);
			b.Sync("drunk_amount", true);
		}

		this.rules.SetCurrentState(WARMUP);
	}

//helper functions
	void set_synced_started(bool started)
	{
		if (started)
		{
			rules.Tag("backend_game_started");
		}
		else
		{
			rules.Untag("backend_game_started");
		}

		rules.Sync("backend_game_started", true);
	}

	u32 human_players()
	{
		u32 humans = 0;
		for (s32 i = 0; i < getPlayersCount(); i++)
		{
			if (!getPlayer(i).isBot())
			{
				humans++;
			}
		}
		return humans;
	}

	bool isServerFree()
	{
		return human_players() == 0;
	}

	string BuildServerStatus(bool forcefree = false)
	{
		return sv_gamemode + "," +
		       ((isServerFree() || forcefree) ? "free" : "busy") + "," +
		       human_players();
	}

	void UpdateServerStatus(string status)
	{
		print("New status: " + status);
		Backend::SetServerStatus(status);
		_lastServerStatus = status;

		//update the central server
		Lobby::Server[]@ servers = Lobby::getServers();
		if (servers is null)
		{
			warn("Can't fetch any lobby servers");
			return;
		}
		for (uint i = 0; i < servers.length; i++)
		{
			Lobby::SyncTagToServer(servers[i], "force_lobby_update");
		}
	}

	void AddDisconnectedPlayer()
	{
		disconnectedPlayers++;
	}

}

// status maintenance even without ticking

void onTCPRConnect(CRules@ this)
{
	if (this.hasTag("use_backend"))
	{
		BackendGame::UpdateServerStatus(BackendGame::BuildServerStatus());
	}
}


// HACK: shouldnt be aproblem for now
void onPlayerLeave( CRules@ this, CPlayer@ player )
{
	BackendGame::AddDisconnectedPlayer();
}
