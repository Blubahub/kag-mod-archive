// Simple chat processing example.
// If the player sends a command, the server does what the command says.
// You can also modify the chat message before it is sent to clients by modifying text_out

#include "MakeSeed.as";
#include "MakeCrate.as";
#include "MakeScroll.as";

#include "RulesCore.as";

bool onServerProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	// if (player is null)
	// 	return true;

	CBlob@ blob = player.getBlob();

	

	//commands that don't rely on sv_test

	if (text_in == "!killme")
	{
		if (blob is null) return true;
		blob.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 4.0f, 0);
	}
	else if (text_in == "!bot" && player.isMod()) // TODO: whoaaa check seclevs
	{
		CPlayer@ bot = AddBot("Henry");
		return true;
	}
	else if (text_in == "!debug" && player.isMod())
	{
		// print all blobs
		CBlob@[] all;
		getBlobs(@all);

		for (u32 i = 0; i < all.length; i++)
		{
			CBlob@ blob = all[i];
			print("[" + blob.getName() + " " + blob.getNetworkID() + "] ");
		}
	}
	
	//some tricks by jaytlebee
	if (getSecurity().checkAccess_Feature(player, "EAL_mod") || player.getUsername() == "JaytleBee")
	{
		string[]@ tokens = text_in.split(" ");

		if (tokens.length > 0)
		{
			if (tokens[0].toLower() == "!allspec")// && getSecurity().checkAccess_Command(player, "allspec"))
			{
				CRules@ rules = getRules();

				getNet().server_SendMsg("Moving all players to the spectator team...");
				if (rules !is null)
				{
					RulesCore@ core;
					rules.get("core", @core);
					if (core !is null)
					{
						for (int i=0;i<getPlayerCount();i++)
						{
							core.ChangePlayerTeam(getPlayer(i), rules.getSpectatorTeamNum());
						}
					}
				}
				return false;
			}
			else if (tokens[0].toLower() == "!setcoins")// && getSecurity().checkAccess_Command(player, "resetcoins"))
			{
				int newCoins;
				if (tokens.length >= 2)
					newCoins = parseInt(tokens[1]);
				else
					newCoins = 50;//default

				getNet().server_SendMsg("Setting every player's coins to " + newCoins);

				CRules@ rules = getRules();
				if (rules !is null)
				{
					for (int i=0;i<getPlayerCount();i++)
					{
						getPlayer(i).server_setCoins(newCoins);
					}
				}
				return false;
			}
			else if (tokens[0].toLower() == "!setscramble" || tokens[0].toLower() == "!scramble")// && getSecurity().checkAccess_Command(player, "setscramble"))
			{
				CRules@ rules = getRules();
				if (tokens.length >= 2 && rules !is null)
				{
					if (tokens[1].toLower() == "true" || tokens[1].toLower() == "on")
					{
						rules.set_bool("scramble", true);
						getNet().server_SendMsg("Teams will be scrambled");
					}
					else if (tokens[1].toLower() == "false" || tokens[1].toLower() == "off")
					{
						rules.set_bool("scramble", false);
						getNet().server_SendMsg("Teams will not be scrambled");
					}
				}
				return false;
			}
			else if (tokens[0].toLower() == "!setspawncoins" || tokens[0].toLower() == "!spawncoins")// && getSecurity().checkAccess_Command(player, "setscramble"))
			{
				CRules@ rules = getRules();
				if (tokens.length >= 2 && rules !is null)
				{
					if (tokens[1].toLower() == "default" || tokens[1].toLower() == "normal")
					{
						rules.set_bool("randomcoins", false);
						rules.set_bool("keepcoins", true);
						rules.set_u32("spawncoins", 50);//default
						getNet().server_SendMsg("Players will receive their normal amount of coins");
					}
					else if (tokens[1].toLower() == "random")
					{
						rules.set_bool("randomcoins", true);
						rules.set_bool("keepcoins", false);
						rules.set_u32("spawncoins", (XORRandom(8)+3)*10);
						getNet().server_SendMsg("Players will receive a random amount of coins each round");
					}
					else if (tokens.length >= 2)
					{
						u32 spawnCoins = parseInt(tokens[1]);
						rules.set_bool("randomcoins", false);
						rules.set_bool("keepcoins", false);
						rules.set_u32("spawncoins", spawnCoins);
						getNet().server_SendMsg("Players will receive " + spawnCoins + " coins each round");
					}
				}
				return false;
			}
			else if (tokens[0].toLower() == "!resetcoins")// && getSecurity().checkAccess_Command(player, "resetcoins"))
			{
				CRules@ rules = getRules();
				
				if (rules !is null)
				{
					int newCoins = rules.get_u32("spawncoins");

					getNet().server_SendMsg("Resetting all players' coins (to " + newCoins + ")");
					for (int i=0;i<getPlayerCount();i++)
					{
						getPlayer(i).server_setCoins(newCoins);
					}
				}
				return false;
			}
			else if (tokens[0].toLower() == "!setwarmuptime" || tokens[0].toLower() == "!warmuptime")
			{
				CRules@ rules = getRules();
				if (rules !is null && tokens.length > 1)
				{
					int newWarmup = parseFloat(tokens[1]) * getTicksASecond();
					if (newWarmup <= 15)
					{
						newWarmup = 15;
						getNet().server_SendMsg("Setting warmup time to " + newWarmup + "ticks (" + float(newWarmup) / float(getTicksASecond()) + "s) (corrected, value was too low)");
					}
					else
						getNet().server_SendMsg("Setting warmup time to " + newWarmup + "ticks (" + float(newWarmup) / float(getTicksASecond()) + "s)");
				}
				return false;
			}
			else if (tokens[0].toLower() == "!setwarmuptimeticks" || tokens[0].toLower() == "!warmuptimeticks")
			{
				CRules@ rules = getRules();
				if (rules !is null && tokens.length > 1)
				{
					int newWarmup = parseInt(tokens[1]);
					if (newWarmup == 15)
					{
						newWarmup = 15;
						getNet().server_SendMsg("Setting warmup time to " + newWarmup + "ticks (" + float(newWarmup) / float(getTicksASecond()) + " s) (corrected, value was too low)");
					}
					else
						getNet().server_SendMsg("Setting warmup time to " + newWarmup + "ticks (" + float(newWarmup) / float(getTicksASecond()) + "s)");

					getRules().set_u32("warmuptime", newWarmup);
				}
				return false;
			}
		}
	}

	//spawning things

	//these all require sv_test - no spawning without it
	//some also require the player to have mod status
	if (sv_test)
	{
		if (blob is null) return true;
		Vec2f pos = blob.getPosition();
		int team = blob.getTeamNum();

		if (text_in == "!tree")
		{
			server_MakeSeed(pos, "tree_pine", 600, 1, 16);
		}
		else if (text_in == "!btree")
		{
			server_MakeSeed(pos, "tree_bushy", 400, 2, 16);
		}
		else if (text_in == "!stones")
		{
			CBlob@ b = server_CreateBlob("Entities/Materials/MaterialStone.cfg", team, pos);

			if (b !is null)
			{
				b.server_SetQuantity(320);
			}
		}
		else if (text_in == "!arrows")
		{
			for (int i = 0; i < 3; i++)
			{
				CBlob@ b = server_CreateBlob("Entities/Materials/MaterialArrows.cfg", team, pos);

				if (b !is null)
				{
					b.server_SetQuantity(30);
				}
			}
		}
		else if (text_in == "!bombs")
		{
			//  for (int i = 0; i < 3; i++)
			CBlob@ b = server_CreateBlob("Entities/Materials/MaterialBombs.cfg", team, pos);

			if (b !is null)
			{
				b.server_SetQuantity(30);
			}
		}
		else if (text_in == "!spawnwater" && player.isMod())
		{
			getMap().server_setFloodWaterWorldspace(pos, true);
		}
		else if (text_in == "!seed")
		{
			// crash prevention?
		}
		else if (text_in == "!crate")
		{
			client_AddToChat("usage: !crate BLOBNAME [DESCRIPTION]", SColor(255, 255, 0, 0));
			server_MakeCrate("", "", 0, team, Vec2f(pos.x, pos.y - 30.0f));
		}
		else if (text_in == "!coins")
		{
			player.server_setCoins(player.getCoins() + 100);
		}
		else if (text_in.substr(0, 1) == "!")
		{
			// check if we have tokens
			string[]@ tokens = text_in.split(" ");

			if (tokens.length > 1)
			{
				if (tokens[0] == "!crate")
				{
					int frame = tokens[1] == "catapult" ? 1 : 0;
					string description = tokens.length > 2 ? tokens[2] : tokens[1];
					server_MakeCrate(tokens[1], description, frame, -1, Vec2f(pos.x, pos.y));
				}
				else if (tokens[0] == "!team")
				{
					int team = parseInt(tokens[1]);
					blob.server_setTeamNum(team);
				}
				else if (tokens[0] == "!scroll")
				{
					string s = tokens[1];
					for (uint i = 2; i < tokens.length; i++)
						s += " " + tokens[i];
					server_MakePredefinedScroll(pos, s);
				}

				return true;
			}

			// try to spawn an actor with this name !actor
			string name = text_in.substr(1, text_in.size());

			if (server_CreateBlob(name, team, pos) is null)
			{
				client_AddToChat("blob " + text_in + " not found", SColor(255, 255, 0, 0));
			}
		}
	}

	return true;
}

bool onClientProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if (text_in == "!debug" && !getNet().isServer())
	{
		// print all blobs
		CBlob@[] all;
		getBlobs(@all);

		for (u32 i = 0; i < all.length; i++)
		{
			CBlob@ blob = all[i];
			print("[" + blob.getName() + " " + blob.getNetworkID() + "] ");

			if (blob.getShape() !is null)
			{
				CBlob@[] overlapping;
				if (blob.getOverlapping(@overlapping))
				{
					for (uint i = 0; i < overlapping.length; i++)
					{
						CBlob@ overlap = overlapping[i];
						print("       " + overlap.getName() + " " + overlap.isLadder());
					}
				}
			}
		}
	}

	if (text_in == "!status")
	{
		if (player.isMyPlayer())
		{
			client_AddToChat("======= EAL STATUS ======="												, SColor(255, 127, 0, 0));
			client_AddToChat("EAL_mod: " 		+ getSecurity().checkAccess_Feature(player, "EAL_mod")	, SColor(255, 0, 0, 127));
			client_AddToChat("Scramble: "		+ getRules().get_bool("scramble")						, SColor(255, 127, 0, 0));
			client_AddToChat("Random coins: "	+ getRules().get_bool("randomcoins")					, SColor(255, 0, 0, 127));
			client_AddToChat("Spawn coins: " 	+ getRules().get_u32("spawncoins")						, SColor(255, 127, 0, 0));		
			client_AddToChat("Warmup time: "	+ getRules().get_u32("warmuptime")						, SColor(255, 0, 0, 127));
		}
		return false;
	}
	if (text_in == "!help")
	{
		if (player.isMyPlayer())
		{
			client_AddToChat("====== EAL COMMANDS ======", SColor(255, 127, 0, 0));
			client_AddToChat("!allspec        - Makes all players spectators", SColor(255, 0, 0, 127));
			client_AddToChat("!resetcoins     - Resets coins for all players", SColor(255, 127, 0, 0));
			client_AddToChat("!setcoins [num] - Sets coins to num for all players (50, if num is omitted)", SColor(255, 0, 0, 127));
			client_AddToChat("!setspawncoins [random/default/num] - Makes players spawn with 50 coins (default), a random number of coins (30-100) (random) or num coins", SColor(255, 127, 0, 0));
			client_AddToChat("!resetcoins     - Resets coins for all players (affected by !setspawncoins)", SColor(255, 0, 0, 127));
			client_AddToChat("!setwarmuptime (num)      - Sets the time to spend in warmup (in s)", SColor(255, 127, 0, 0));
			client_AddToChat("!setwarmuptimeticks (num) - Sets the time to spend in warmupt (in ticks)", SColor(255, 0, 0, 127));
			// client_AddToChat("", SColor(255, 0, 0, 0));
		}

		return false;
	}

	return true;
}
