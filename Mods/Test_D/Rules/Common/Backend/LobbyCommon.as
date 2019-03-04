//Common lobby functionality and datatypes

namespace Lobby
{
	//backend server information required in lobby
	shared class Server
	{
		string address;
		bool connectable;
		string[] status;
	};

	//
	Server[]@ getServers()
	{
		Server[]@ servers = null;
		getRules().get("lobby servers", @servers);
		return servers;
	}

	//add or retrieve server
	Server@ getServerFromAddress(string addr)
	{
		Server[]@ servers = getServers();
		Server@ ret = null;
		for (uint i = 0; i < servers.length; i++)
		{
			Server@ current = servers[i];
			if (current.address == addr)
			{
				@ret = current;
				break;
			}
		}
		if (ret is null)
		{
			Server s;
			s.address = addr;
			s.connectable = false;
			servers.push_back(s);
			@ret = servers[servers.length - 1];
		}
		return ret;
	}

	//backend player information required in lobby
	shared class PlayerRecord
	{
		string username;

		u32 coins;

		int skin;
		int pet;

		int drunk_amount;
		int drunk_timer;

		//unoptimised "dictionary" - no handle issues though :) - lol
		string[] stat_names;
		int[] stat_values;
		int getStat(string s)
		{
			for(u32 i = 0; i < stat_names.length; i++)
			{
				if(stat_names[i] == s)
				{
					return stat_values[i];
				}
			}
			return 0;
		}

		//convenience functions
		CPlayer@ player()
		{
			return getPlayerByUsername(username);
		};
	};

	//
	PlayerRecord[]@ getPlayers()
	{
		PlayerRecord[]@ players = null;
		getRules().get("lobby players", @players);
		return players;
	}

	//add or retrieve player
	PlayerRecord@ getPlayerRecordFromUsername(string username)
	{
		PlayerRecord[]@ players = getPlayers();
		PlayerRecord@ ret = null;
		for (uint i = 0; i < players.length; i++)
		{
			PlayerRecord@ current = players[i];
			if (current.username == username)
			{
				@ret = current;
				break;
			}
		}
		if (ret is null)
		{
			PlayerRecord s;
			s.username = username;
			s.coins = 0;
			s.skin = -1;
			s.pet = -1;
			players.push_back(s);
			@ret = players[players.length - 1];
		}
		return ret;
	}

	bool hasPlayerRecord(string username)
	{
		PlayerRecord[]@ players = getPlayers();
		for (uint i = 0; i < players.length; i++)
		{
			PlayerRecord@ current = players[i];
			if (current.username == username)
			{
				return true;
			}
		}
		return false;
	}

	void removePlayerRecord(string username)
	{
		PlayerRecord[]@ players = getPlayers();
		for (uint i = 0; i < players.length; i++)
		{
			PlayerRecord@ current = players[i];
			if (current.username == username)
			{
				players.removeAt(i--);
			}
		}
	}


	//collection of rencently used servers,
	//with expiry times
	shared class RecentlyUsedServers
	{

		string[] server_names;
		int[] server_times;
		string[] server_players;

		void Add(string name, CPlayer@[] queuedPlayers)
		{
			server_names.push_back(name);
			server_times.push_back(Time() + 45);
			string playersString;
			for (uint i = 0; i < queuedPlayers.length; i++)
			{
				CPlayer@ p = queuedPlayers[i];
				if (p !is null && p.isBot())
				{
					playersString += p.getCharacterName();
					if (i < queuedPlayers.length-1){
						playersString += "\n";
					}
				}
			}			
			server_players.push_back(playersString);
		}

		bool contains(string s)
		{
			for(u32 i = 0; i < server_names.length; i++)
			{
				//remove anything stale
				if(server_times[i] < Time())
				{
					server_names.removeAt(i);
					server_times.removeAt(i);
					server_players.removeAt(i);
					i--;
					continue;
				}

				if(server_names[i] == s)
				{
					return true;
				}
			}
			return false;
		}
	};

	RecentlyUsedServers@ getRecentlyUsedServers()
	{
		RecentlyUsedServers@ rus = null;
		getRules().get("lobby rus", @rus);
		return rus;
	}

	//convencience functions

	PlayerRecord@ getPlayerRecordFromCPlayer(CPlayer@ p)
	{
		return getPlayerRecordFromUsername(p.getUsername());
	}

	bool serverHasInStatus(Server@ server, const string &in s)
	{
		for (uint i = 0; i < server.status.length; i++)
		{
			if (server.status[i] == s)
			{
				return true;
			}
		}
		return false;
	}

	//warning: string cant contain " or '
	// possibly needs to be <~800b as well.
	void SyncStringToServer(Server@ server, const string &in into, const string &in s)
	{
		Backend::Mirror("getRules().set_string('"+into+"', '"+s+"');", server.address);
	}

	void SyncU32ToServer(Server@ server, const string &in into, const u32 v)
	{
		Backend::Mirror("getRules().set_u32('"+into+"', "+v+");", server.address);
	}

	void SyncTagToServer(Server@ server, const string &in tag)
	{
		Backend::Mirror("getRules().Tag('"+tag+"');", server.address);
	}

	//(re)initialise the lobby data store
	void init()
	{
		Server[] servers;
		getRules().set("lobby servers", servers);
		PlayerRecord[] players;
		getRules().set("lobby players", players);
		RecentlyUsedServers rus;
		getRules().set("lobby rus", rus);
	}

/*	u32 getPlayerBets(CPlayer@[]@ players)
	{		
		u32 sum = 0;
		for (uint i = 0; i < players.length; i++)
		{
			CPlayer@ p = players[i];
			CBlob@ blob = p.getBlob();
			if (blob is null) continue;
			sum += blob.get_u32("bet");
		}
		return sum;
	}	

	void RemoveBets(CPlayer@[]@ players)
	{		
		for (uint i = 0; i < players.length; i++)
		{
			CPlayer@ p = players[i];
			CBlob@ blob = p.getBlob();
			if (blob is null) continue;
			Backend::PlayerCoinTransaction(p, -blob.get_u32("bet"));
			blob.set_u32("bet", 0);
		}
	}	*/

}
