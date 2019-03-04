// Simple chat processing example.
// If the player sends a command, the server does what the command says.
// You can also modify the chat message before it is sent to clients by modifying text_out

#include "MakeSeed.as";
#include "MakeCrate.as";
#include "MakeScroll.as";

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

	if (text_in == "!killme")
	{
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
		else if (text_in == "!invincible" && player.isMod()) 
		{
			blob.server_SetHealth(99999999);
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
				b.server_SetQuantity(4);
			}
		}
		else if (text_in == "!spawnwater" && player.isMod())
		{
			getMap().server_setFloodWaterWorldspace(pos, true);
		}
		else if (text_in == "!clearblobs" && player.isMod()) 
		{
			CBlob@[] allBlobs;
			getBlobs(@allBlobs);
			int deletedCount;
			for (int x = 0; x < allBlobs.length; x++) 
			{
				string blobName = allBlobs[x].getName();
				if (blobName == "mat_stone" && !allBlobs[x].isInInventory()) 
				{
					allBlobs[x].server_Die();
					deletedCount++;
				}
				else if (blobName == "mat_wood" && !allBlobs[x].isInInventory())
				{
					allBlobs[x].server_Die();
					deletedCount++;
				}
				else if (blobName == "mat_bombs" && !allBlobs[x].isInInventory())
				{
					allBlobs[x].server_Die();
					deletedCount++;
				}
				else if (blobName == "mat_arrows" && !allBlobs[x].isInInventory())
				{
					allBlobs[x].server_Die();
					deletedCount++;
				}
				else if (blobName == "mat_waterbombs" && !allBlobs[x].isInInventory())
				{
					allBlobs[x].server_Die();
					deletedCount++;
				}
				else if (blobName == "mat_firearrows" && !allBlobs[x].isInInventory())
				{
					allBlobs[x].server_Die();
					deletedCount++;
				}
				else if (blobName == "mat_bombarrows" && !allBlobs[x].isInInventory())
				{
					allBlobs[x].server_Die();
					deletedCount++;
				}
				else if (blobName == "mat_waterarrows" && !allBlobs[x].isInInventory())
				{
					allBlobs[x].server_Die();
					deletedCount++;
				}
				else if (blobName == "ballista_bolt" && !allBlobs[x].isInInventory())
				{
					allBlobs[x].server_Die();
					deletedCount++;
				}
				else if (blobName == "mat_bolts" && !allBlobs[x].isInInventory())
				{
					allBlobs[x].server_Die();
					deletedCount++;
				}
				else if (blobName == "drill" && !allBlobs[x].isInInventory())
				{
					allBlobs[x].server_Die();
					deletedCount++;
				}
				else if (blobName == "arrow" && !allBlobs[x].isInInventory())
				{
					allBlobs[x].server_Die();
					deletedCount++;
				}
			}
		}
		else if (text_in == "!clearblobs_halls" && player.isMod()) 
		{
			CBlob@[] allBlobs;
			getBlobs(@allBlobs);
			int deletedCount;
			for (int x = 0; x < allBlobs.length; x++) 
			{
				string blobName = allBlobs[x].getName();
				if (blobName == "hall")
				{
					allBlobs[x].server_Die();
					deletedCount++;
				}
			}
		}
		else if (text_in == "!clearblobs_flags" && player.isMod()) 
		{
			CBlob@[] allBlobs;
			getBlobs(@allBlobs);
			int deletedCount;
			for (int x = 0; x < allBlobs.length; x++) 
			{
				string blobName = allBlobs[x].getName();
				if (blobName == "ctf_flag")
				{
					allBlobs[x].server_Die();
					deletedCount++;
				}
				else if (blobName == "flag_base")
				{
					allBlobs[x].server_Die();
					deletedCount++;
				}
			}
		}
		else if (text_in == "!clearblobs_tents" && player.isMod()) 
		{
			CBlob@[] allBlobs;
			getBlobs(@allBlobs);
			int deletedCount;
			for (int x = 0; x < allBlobs.length; x++) 
			{
				string blobName = allBlobs[x].getName();
				if (blobName == "tent")
				{
					allBlobs[x].server_Die();
					deletedCount++;
				}
			}
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
		else if (text_in == "!c")
		{
			player.server_setCoins(player.getCoins() + 100);
		}
		else if (text_in.substr(0, 1) == "!")
		{
			// check if we have tokens
			string[]@ tokens = text_in.split(" ");
			
			if (tokens.length > 1)
			{
				if (tokens[0] == "!tp") 
				{
					Vec2f tpPos = getPlayerByUsername(tokens[1]).getBlob().getPosition();
					blob.setPosition(tpPos);
					blob.setVelocity(Vec2f_zero);
					blob.getShape().PutOnGround();
				}
				if (tokens[0] == "!crate")
				{
					int frame = tokens[1] == "catapult" ? 1 : 0;
					string description = tokens.length > 2 ? tokens[2] : tokens[1];
					server_MakeCrate(tokens[1], description, frame, -1, Vec2f(pos.x, pos.y));
				}
				else if (tokens[0] == "!team" && tokens[1] != "admin")
				{
					int team = parseInt(tokens[1]);
					blob.server_setTeamNum(team);
				}
				else if (tokens[0] == "!team" && tokens[1] == "admin" && player.isMod())
				{
					blob.server_setTeamNum(8135810515);
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
		
		
		if (text_in.substr(0, 1) == "!") 
		{
			
			string[]@ tokens = text_in.split(" ");
			SColor textColor;
			if (tokens.length > 3) 
			{
				if (tokens[0] == "!print") 
				{
					string ttext3 = " ";
					if (tokens[1] == "in") 
					{
						if(tokens[2] == "red") 
						{
							ttext3 = tokens[3];
							textColor = SColor(255, 255, 0, 0);
							client_AddToChat(ttext3, textColor);
						}
					}
				}
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
	
		
	if (text_in.substr(0, 1) == "!") 
		{
			
			string[]@ tokens = text_in.split(".");
			SColor textColor;
			if (tokens[0] == "!print" && player.isMod()) 
			{
				string ttext3 = " ";
				if (tokens[1] == "in" && tokens.length == 4) 
				{
					if(tokens[2] == "red") 
					{
						ttext3 = tokens[3];
						textColor = SColor(255, 255, 0, 0);
						client_AddToChat(ttext3, textColor);
					}
					else if(tokens[2] == "green") 
					{
						ttext3 = tokens[3];
						textColor = SColor(255, 0, 255, 0);
						client_AddToChat(ttext3, textColor);
					}
					else if(tokens[2] == "blue") 
					{
						ttext3 = tokens[3];
						textColor = SColor(255, 0, 0, 255);
						client_AddToChat(ttext3, textColor);
					}
				}
				else if(tokens[1] == "cs" && tokens.length == 6) {
					int R = parseInt(tokens[2]);
					int G = parseInt(tokens[3]);
					int B = parseInt(tokens[4]);
					string text = tokens[5];
					client_AddToChat(text, SColor(255 ,R, G, B));
				}
			}
		}
	return true;
}

