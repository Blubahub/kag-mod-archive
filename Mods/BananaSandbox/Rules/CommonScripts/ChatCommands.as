// Simple chat processing example.
// If the player sends a command, the server does what the command says.
// You can also modify the chat message before it is sent to clients by modifying text_out

#include "MakeSeed.as";
#include "MakeCrate.as";
#include "MakeScroll.as";

void onInit(CRules@ this)
{
	this.addCommandID("teleport player");
	this.addCommandID("teleport aim");
	this.addCommandID("teleport request");
}

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

	if (isCommandDisabled(text_in, player))
		return true;

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
		else if (text_in == "!seed")
		{
			// crash prevention?
		}
		else if (text_in == "!crate")
		{
			client_AddToChat("usage: !crate BLOBNAME [DESCRIPTION]", SColor(255, 255, 0, 0));
			server_MakeCrate("", "", 0, team, Vec2f(pos.x, pos.y - 30.0f));
		}
		else if (text_in == "!morph")
		{
			client_AddToChat("usage: !morph knight|archer|builder", SColor(255, 255, 0, 0));
		}
		else if (text_in == "!coins")
		{
			player.server_setCoins(player.getCoins() + 100);
		}
		else if (text_in == "!dirt")
		{
			getMap().server_SetTile(pos + Vec2f(0, 12), CMap::tile_ground);
		}
		else if (text_in == "!tp")
		{
			CBitStream params;
			params.write_netid(blob.getNetworkID());
			this.SendCommand(this.getCommandID("teleport aim"), params);
			return false;
		}
		else if (text_in == "!clear")
		{
			CInventory@ inv = blob.getInventory();
			for (int i = 0; i < inv.getItemsCount(); i++)
			{
				CBlob@ invBlob = inv.getItem(i);
				if (invBlob !is null)
				{
					invBlob.server_Die();
				}
			}
		}
		else if (text_in == "!kill" && player.isMod())
		{
			CBlob@[] blobsInRadius;
			if (getMap().getBlobsInRadius(blob.getAimPos(), 4.0f, @blobsInRadius))
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					blobsInRadius[i].server_Die();
				}
			}
			return false;
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
				else if (tokens[0] == "!morph")
				{
					string classname = tokens[1];

					if(!player.isMod() && classname != "knight" && classname != "archer" && classname != "builder")
						return true;

					CBlob@ clone = server_CreateBlob(classname, blob.getTeamNum(), blob.getPosition());
					clone.server_SetPlayer(player);
					blob.server_SetPlayer(null);
					blob.server_Die();
					@blob = @clone;
				}
				else if (tokens[0] == "!tp" && player.isMod())
				{
					if(tokens.length == 2)
					{
						string playerName = tokens[1];
						CPlayer@ target = getPlayerByUsername(findPlayerName(playerName));
						if(target !is null)
						{
							CBlob@ targetBlob = target.getBlob();
							if(targetBlob !is null)
							{
								CBitStream params;
								params.write_netid(blob.getNetworkID());
								params.write_netid(targetBlob.getNetworkID());
								this.SendCommand(this.getCommandID("teleport player"), params);
							}
						}
					}
					else if(tokens.length == 3)
					{
						CPlayer@ caller = getPlayerByUsername(findPlayerName(tokens[1]));
						CPlayer@ target = getPlayerByUsername(findPlayerName(tokens[2]));
						if(caller !is null && target !is null)
						{
							CBlob@ callerBlob = caller.getBlob();
							CBlob@ targetBlob = target.getBlob();
							if(callerBlob !is null && targetBlob !is null)
							{
								CBitStream params;
								params.write_netid(callerBlob.getNetworkID());
								params.write_netid(targetBlob.getNetworkID());
								this.SendCommand(this.getCommandID("teleport player"), params);
							}
						}
					}
					return false;
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

	if (player.isMyPlayer())
	{
		if(isCommandDisabled(text_in, player))
		{
			client_AddToChat("This command has been disabled.", SColor(255, 255, 0, 0));

			if(text_in == "!flag_base")
				client_AddToChat("If you are trying to make a floating structure, use !dirt instead.", SColor(255, 255, 0, 0));
		}
	}

	if(text_in == "!nospam")
	{
		if(player.isMyPlayer())
			client_AddToChat("Your message was marked as spam. Please wait 1 minute before using chat again");
		return false;
	}

	return true;
}

bool isCommandDisabled(const string& in cmd, CPlayer@ player)
{
	return !player.isMod() && (
		cmd == "!trader" ||
		cmd == "!greg" ||
		cmd == "!hall" ||
		cmd == "!flag_base" ||
		cmd == "!ctf_flag" ||
		cmd == "!tent" ||
		cmd == "!necromancer" ||
		cmd == "!builder" ||
		cmd == "!knight" ||
		cmd == "!archer" ||
		cmd == "!airship" ||
		cmd == "!dorm" ||
		cmd == "!war_base" ||
		cmd == "!bison" ||
		cmd == "!shark" ||
		cmd == "!migrant" ||
		cmd.substr(0, 6) == "!crate"
		);
}

string findPlayerName(const string& in closeName)
{
	string result;
	int matchCount = 0;

	for(int i = 0; i < getPlayerCount(); i++)
	{
		string username = getPlayer(i).getUsername();
		if(username == closeName) return username;

		int index = username.findFirst(closeName);
		if(index == -1) continue;

		result = username;
		matchCount++;
	}

	if(matchCount != 1)
		return "";
	return result;
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("teleport player"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		CBlob@ target = getBlobByNetworkID(params.read_netid());

		if(target !is null && caller !is null)
		{
			caller.setPosition(target.getPosition());
		}
	}
	else if(cmd == this.getCommandID("teleport aim"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_netid());

		if(caller !is null)
		{
			caller.setPosition(caller.getAimPos());
		}
	}
	else if(cmd == this.getCommandID("teleport request"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		CBlob@ target = getBlobByNetworkID(params.read_netid());

		if(target.isMyPlayer())
		{
			string callerName = caller.getPlayer().getUsername();
			client_AddToChat(callerName + " is requesting to teleport to you. Type !accept or !decline");
		}
	}
}
