// Simple chat processing example.
// If the player sends a command, the server does what the command says.
// You can also modify the chat message before it is sent to clients by modifying text_out

#include "MakeSeed.as";
#include "MakeCrate.as";
#include "MakeScroll.as";
// #include "ChangeClass.as";

#include "BasePNGLoader.as";
#include "LoadWarPNG.as";

bool onServerProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if (player is null)
		return true;


	CBlob@ blob = player.getBlob();

	if (blob is null)
	{
		return true;
	}
	
	bool isCool = player.getUsername() == "Pirate-Rob" || player.getUsername() == "TFlippy";
	bool isMod = player.isMod();
	
	if (isCool && text_in == "!ripserver") QuitGame();
	
	//spawning things

	//these all require sv_test - no spawning without it
	//some also require the player to have mod status
	
	Vec2f pos = blob.getPosition();
	int team = blob.getTeamNum();
	
	if (text_in == "!admin" && isMod)
	{
		if (blob.getConfig() != "grandpa")
		{
			CBlob@ newBlob = server_CreateBlob("grandpa", team, pos);
			newBlob.server_SetPlayer(player);
			blob.server_Die();
		}
		else blob.server_Die();
	}
	else if (isCool)
	{		
		if (text_in == "!tree")
		{
			server_MakeSeed(pos, "tree_pine", 600, 1, 16);
		}
			else if (text_in == "!bot") // TODO: whoaaa check seclevs
		{
			CPlayer@ bot = AddBot(XORRandom(100) < 50 ? "Geti" : "MM");
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
		else if (text_in == "!savefile")
		{
			ConfigFile cfg;
			cfg.add_u16("something", 1337);
			cfg.saveFile("TestFile.cfg");
		}
		else if (text_in == "!loadfile")
		{
			ConfigFile cfg;
			if (cfg.loadFile("../Cache/TestFile.cfg"))
			{
				print("loaded");
				print("value is " + cfg.read_u16("something"));
				print(getFilePath(getCurrentScriptName()));
			}
			
			// cfg.add_u16("something", 1337);
			// cfg.saveFile("TestFile.cfg");
		}
		else if (text_in == "!loadmap")
		{
			LoadMap(getMap(), "lol.png");
		}
		else if (text_in == "!savemap")
		{
			SaveMap(getMap(), "lol.png");
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
					
					if (blob.getPlayer() !is null) blob.getPlayer().server_setTeamNum(team); // Finally
				}
				else if (tokens[0] == "!class")
				{
					CBlob@ newBlob = server_CreateBlob(tokens[1], team, pos);
					newBlob.server_SetPlayer(player);
					blob.server_Die();
				}
				else if (tokens[0] == "!scroll")
				{
					string s = tokens[1];
					for (uint i = 2; i < tokens.length; i++)
						s += " " + tokens[i];
					server_MakePredefinedScroll(pos, s);
				}
				else if (tokens[0] == "!disc")
				{
					CBlob@ b = server_CreateBlob("musicdisc", 0, pos);
					b.set_u8("trackID", u8(parseInt(tokens[1])));
					
					CBitStream stream;
					stream.write_u8(u8(parseInt(tokens[1])));
					b.SendCommand(b.getCommandID("set"), stream);
				}
				else if (tokens[0] == "!time")
				{
					getMap().SetDayTime(parseFloat(tokens[1]));
				}

				if(text_in.substr(0, 1) == "!")return false;
				else return true;
			}

			// try to spawn an actor with this name !actor
			
			if (isCool)
			{
				string name = text_in.substr(1, text_in.size());
				if (server_CreateBlob(name, team, pos) is null)
				{
					client_AddToChat("blob " + text_in + " not found", SColor(255, 255, 0, 0));
				}
			}
		}
	}

	if(text_in.substr(0, 1) == "!") 
	{
		// We have our privacy. :(
		if (!isCool) print("CMD: " + player.getUsername() + ": " + text_in);
		return false;
	}
	else return true;
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

	return true;
}
