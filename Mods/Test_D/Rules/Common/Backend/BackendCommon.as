///////////////////////////////////////
// TR backend interface
// for the crimson servers

namespace Backend
{
	//constants
	const u32 DRINK_DECAY_TIME_SECONDS = 60 * 5;

	//function defs
	funcdef void PARSE_FUNCTION(Request@ request, const string &in response);
	funcdef void CALLBACK_FUNCTION(CRules@ rules, Request@ req);

	shared class Request
	{
		string destination;
		PARSE_FUNCTION@ parse;
		CALLBACK_FUNCTION@ callback;
		CALLBACK_FUNCTION@ timeout;
		u32 timeout_time;
		dictionary parsed_data;
	};

	//specific parsed responses

	shared class ServerResponse
	{
		bool found;
		string address;
		bool connected;
		string[] status;
	};

	shared class PlayerResponse
	{
		string username;
		int coins;
		int skin;
		int pet;
		int drunk_amount;
		int drunk_timer;
		string stats_raw;
	};

	//overall backend data

	shared class Data
	{
		Request[] requests;
	};

	Data@ InitBackend(CRules@ this)
	{
		Data b;
		this.set("backend", @b);
		return getBackend(this);
	}

	Data@ getBackend(CRules@ this)
	{
		Data@ b;
		this.get("backend", @b);
		return b;
	}



	///////////////////////////////////////
	// raw input

	void SendToBackend(const string &in s)
	{
		tcpr("|TR LOBBY|" + s);
	}

	///////////////////////////////////////
	// queries

	void QueryList(const string &in into, CALLBACK_FUNCTION@ callback, CALLBACK_FUNCTION@ timeout)
	{
		SetupRequest(into, @ParseListQuery, @callback, @timeout);
		SendToBackend("query list " + into);
	}

	void QueryList(const string &in into, CALLBACK_FUNCTION@ callback)
	{
		QueryList(into, @callback, @DefaultTimeoutCallback);
	}

	void QueryServer(const string &in address, const string &in into, CALLBACK_FUNCTION@ callback, CALLBACK_FUNCTION@ timeout)
	{
		SetupRequest(into, @ParseServerQuery, @callback, @timeout);
		SendToBackend("query server " + address + " " + into);
	}

	void QueryServer(const string &in address, const string &in into, CALLBACK_FUNCTION@ callback)
	{
		QueryServer(address, into, @callback, @DefaultTimeoutCallback);
	}

	void QueryPlayer(CPlayer@ player, const string &in into, CALLBACK_FUNCTION@ callback, CALLBACK_FUNCTION@ timeout)
	{
		SetupRequest(into, @ParsePlayerQuery, @callback, @timeout);
		SendToBackend("query player " + player.getUsername() + " " + into);
	}

	void QueryPlayer(CPlayer@ player, const string &in into, CALLBACK_FUNCTION@ callback)
	{
		QueryPlayer(player, into, @callback, @DefaultTimeoutCallback);
	}

	u32 queryGen = 0;
	string TemporaryQueryString()
	{
		queryGen = (queryGen + 1) % 100;
		return "tr_query_" + queryGen;
	}

	///////////////////////////////////////
	// transactions

	void PlayerCoinTransaction(CPlayer@ player, int change)
	{
		if (player is null || change == 0)
		{
			return;
		}
		player.server_setCoins(player.getCoins() + change);
		string action = change > 0 ? "give" : "take";
		change = Maths::Abs(change);
		SendToBackend(getTransactionString(player.getUsername(), "coins", action, change));
	}

	void SetPlayerSkin(CPlayer@ player, int skin)
	{
		if (player is null)
		{
			return;
		}

		SendToBackend(getTransactionString(player.getUsername(), "skin", "set", skin));
	}

	void SetPlayerPet(CPlayer@ player, int pet)
	{
		if (player is null)
		{
			return;
		}

		SendToBackend(getTransactionString(player.getUsername(), "pet", "set", pet));
	}

	void SetPlayerDrunk(CPlayer@ player, int amount)
	{
		if (player is null)
		{
			return;
		}

		SendToBackend(getTransactionString(player.getUsername(), "drunk_amount", "set", amount));
		SendToBackend(getTransactionString(player.getUsername(), "drunk_timer", "set", (amount == 0 ? 0 : Time() + DRINK_DECAY_TIME_SECONDS)));
	}

	void PlayerMetric(CPlayer@ player, string metric)
	{
		if (player is null)
		{
			return;
		}
		SendToBackend(getMetricString(player.getUsername(), metric));
	}

	//DO NOT store anything with commas or double-bars here!
	void PlayerUserdata(CPlayer@ player, string name, string value)
	{
		if (player is null)
		{
			return;
		}
		SendToBackend(getStoreString(player.getUsername(), name, value));
	}

	///////////////////////////////////////
	// mirror direct commands

	void Mirror(const string &in s, const string &in addrto = "")
	{
		if (addrto != "")
		{
			SendToBackend("mirrorto " + addrto + " " + s);
		}
		else
		{
			SendToBackend("mirror " + s);
		}
	}

	///////////////////////////////////////
	// write custom server status

	void SetServerStatus(const string &in status)
	{
		SendToBackend("status " + status);
	}

	///////////////////////////////////////
	// helpers

	string getTransactionString(const string &in username, const string &in field, const string &in action, int amount = -1)
	{
		return "transact player " + username + " " + field + " " + action + (amount == -1 ? "" : " " + amount);
	}

	string getMetricString(const string &in username, const string &in field)
	{
		return "metric " + username + " " + field;
	}

	string getStoreString(const string &in username, const string &in field, const string &in val)
	{
		return "store " + username + " " + field + " " + val;
	}

	void DefaultTimeoutCallback(CRules@ rules, Request@ req)
	{
		warn("request " + req.destination + " timed out");
	}

	void SetupRequest(const string &in into, PARSE_FUNCTION@ parser, CALLBACK_FUNCTION@ callback, CALLBACK_FUNCTION@ timeout)
	{
		CRules@ rules = getRules();
		rules.set_string(into, "");

		Request req;
		req.destination = into;
		req.parse = @parser;
		req.callback = @callback;
		req.timeout = @timeout;
		req.timeout_time = Time() + 10; //seconds to timeout

		Data@ backend = getBackend(rules);
		if (backend !is null)
		{
			backend.requests.push_back(req);
		}
		else
		{
			warn("SetupRequest: Backend data not found");
		}
	}

	///////////////////////////////////////
	// parsing utilities

	void ParseListQuery(Request@ request, const string &in response)
	{
		//special string for empty list
		if(response != "(no_servers)")
		{
			//list response is just CSV of all servers
			string[] servers = response.split(",");
			request.parsed_data.set("servers", servers);
		}
	}

	void ParseServerQuery(Request@ request, const string &in response)
	{
		string trimmedResponse = trim(response);

		ServerResponse s;

		//was the server found at all?
		s.found = (trimmedResponse != "not found");
		if (!s.found)
		{
			return;
		}

		//successfully found server response is CSV with multiple values
		string[] chunks = trimmedResponse.split(",");

		//read and remove the server address
		string address = chunks[0]; chunks.removeAt(0);
		s.address = address;

		//read and remove the connected indicator
		string connected_rep = chunks[0]; chunks.removeAt(0);
		s.connected = false;
		if (connected_rep == "true")
		{
			s.connected = true;
		}

		//dump the rest of the chunks as the status
		s.status = chunks;

		request.parsed_data.set("server", s);
	}

	s32 parseIntClamped(string v, s32 low, s32 high)
	{
		return s32(Maths::Clamp(float(parseInt(v)), float(low), float(high)));
	}

	void ParsePlayerQuery(Request@ request, const string &in response)
	{
		PlayerResponse p;
		//player response is CSV of username,coins,skin,pet,drunk_amount,drunk_timer,stats
		string[] chunks = response.split(",");
		if (chunks.length >= 7)
		{
			p.username = chunks[0];
			p.coins = parseIntClamped(chunks[1], 0, 100000);
			p.skin = parseInt(chunks[2]);
			p.pet = parseInt(chunks[3]);
			p.drunk_amount = parseIntClamped(chunks[4], 0, 100);
			p.drunk_timer = parseInt(chunks[5]);
			p.stats_raw = chunks[6];
		}
		else
		{
			warn("[BACKEND] wrong-length player response encountered");
		}
		request.parsed_data.set("player", p);
	}
}
