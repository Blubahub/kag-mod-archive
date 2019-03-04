// Simple chat processing example.
// If the player sends a command, the server does what the command says.
// You can also modify the chat message before it is sent to clients by modifying text_out

#include "MakeSeed.as";
#include "MakeCrate.as";
#include "MakeScroll.as";
#include "MagicCommon.as";

bool onServerProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if (player is null)
		return true;


	CBlob@ blob = player.getBlob();

	if (blob is null)
	{
		return true;
	}

	//commands that don't rely on sv_test
	if(blob.getName() == "kagician")
	{
		//Setting magical attack.
		string[] tokens = text_in.split(" ");
		if(tokens[0] == "Cast")
		{
			//They wanna spell
			string[] scripts; //Need to switch this to storing indexes rather than strings?
			
			//Default / placeholder scripts. Counts only if there's nothing replacing it.
/* 			for(int i = 0; i < 3; i++)
			{
				string[][] list = allwords[i];
				string[] listpart = list[XORRandom(list.length)];
				
				scripts.push_back(listpart[listpart.length - 1]);
			} */
			scripts.push_back("Gravity");
			scripts.push_back("Bounce");
			scripts.push_back("Harm"); //Experimenting with random base casts.
			blob.set_u8("firestyle", 0);
			blob.set_u8("stylepower", 0);
			blob.Sync("firestyle", true);
			blob.Sync("stylepower", true);
			for(int i = 1; i < tokens.length; i++)
			{
				int endex;
				int power; //The power level of that particular spell. This is only used with fire-styles.
				int spellindex = getSpellIndex(tokens[i], endex, power);
				//Define default stuff
				if(spellindex != -1) //if it wasn't a spell.
				{
					string[] list = allwords[spellindex][endex];
					string word = list[list.length - 1]; //The string on the very end is the script name.
					if(spellindex < 3) //If it's one of the three must-have parts of spells.
					{
						scripts[spellindex] = word;
					}
					else if(spellindex == 4) //Attack style thingies get special thingums
					{
						blob.set_u8("firestyle", endex);
						//print("Power: "+  power);
						blob.set_u8("stylepower", power);
						blob.Sync("firestyle", true);
						blob.Sync("stylepower", true);
					}
					else
					{
						scripts.push_back(word);
					}
				}
			}
			for(int i = 0; i < scripts.length; i++)
			{
				print(scripts[i]);
			}
			blob.set("scripts", scripts);
		}
		else if(tokens[0] == "AltCast")
		{
			for(int i = 0; i < Abilities.length; i++)
			{
				if(Abilities[i] == tokens[1])
				{
					blob.set_u8("abilityindex", i);
					blob.getSprite().PlaySound("snes_coin.ogg");
					return true;
				}
			}
		}
	}
	if (text_in == "!killme")
	{
		blob.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 100.0f, 0);
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

	//spawning things

	//these all require sv_test - no spawning without it
	//some also require the player to have mod status
	if (sv_test)
	{
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
			CBlob@ b = server_CreateBlob('mat_stone', -1, pos);
		}
		else if (text_in == "!arrows")
		{
			for (int i = 0; i < 3; i++)
			{
				CBlob@ b = server_CreateBlob('mat_arrows', -1, pos);
			}
		}
		else if (text_in == "!bombs")
		{
			for (int i = 0; i < 3; i++)
			{
				CBlob@ b = server_CreateBlob('mat_bombs', -1, pos);
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
	if(text_in == "help")
	{
		for(int i = 0; i < 2; i++)
		{
			int index = XORRandom(allwords.length);
			string[][] list = allwords[index];
			string[] listpart = list[XORRandom(list.length)];
			string word = listpart[0];
			if(index == 4)
			{
				for(int i = 1; i < listpart.length - 1; i++)
				{
					if(XORRandom(4) == 1)
					{
						word += "," + listpart[i];
					}
					else
					{
						break;
					}
				}
			}
			client_AddToChat("A word of power for the wise kagician: " + word, SColor(255, 255, 0, 0));
		}
		return false;
	}

	return true;
}

