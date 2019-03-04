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
		blob.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 100.0f, 0);
	}
	else if (text_in == "!bot" && player.isMod()) // TODO: whoaaa check seclevs
	{
		CPlayer@ bot = AddBot("NevroBot");
		return true;
	}
	else if (text_in == "!nfd")
	{
		blob.RemoveScript('FallDamage.as');
	}
	else if (text_in == "!god")
	{
		blob.server_SetHealth(9999.0f);
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
		else if (text_in == "!lkeg")
		{
			for( int n = 0; n < 3; n++ )
			{
			CBlob@ b = server_CreateBlob('keg', -1, pos);
			b.SendCommand(b.getCommandID('activate'));
			b.setPosition(getControls().getMouseWorldPos());
			}
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
				else if(tokens[0]=="!turn" && tokens[2]=="into" && tokens[3]=="a")
				{
					CPlayer@ user =	GetPlayer(tokens[1]); // 2nd word get username

					string blobname = tokens[4]; // 4th word is the new blob name. crate, bison, migrant, etc.

					if(user !is null && getName(blobname)) // chosen player exists?
					{
						CBlob@ playerblob = user.getBlob();				
						CBlob@ newblob = server_CreateBlob( blobname, team, playerblob.getPosition());

						if (newblob !is null) // our new blob exists?
						{		
							newblob.server_SetPlayer(user); // set the chosen player as to the new blob 							
							playerblob.server_SetPlayer(null);
							playerblob.server_Die();

							newblob.AddScript('StandardControls.as');
							newblob.AddScript('StandardPickup.as');
							newblob.AddScript('ActivateHeldObject.as');
							newblob.AddScript('EmoteBubble.as');
							newblob.AddScript('DrawHoverMessages.as');

							CMovement@ movement = newblob.getMovement();
							if (movement !is null)
							{						
								movement.AddScript('FaceAimPosition.as');
								movement.AddScript("RunnerMovementInit.as");
								movement.AddScript("RunnerMovement.as");
							}
						}
					}				
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

bool getName(string name)
{	
	string[] blobnames = { 		//animals
							"chicken", "bison", "shark", "fishy", "egg",
							//characters
							"knight", "archer", "builder", "necromancer",  "greg",  "princess", "trader", "dummy",
							"archer_fem_dummy", "builder_fem_dummy", "knight_fem_dummy", "orb", "migrant", "bandit",
							"exosuit", "grandpa", "ninja", "peasant", "royalguard", "sapper", "slave",
							//natural
							"bush",  "flowers", "tree_pine",  "tree_bushy", "grain", "grain_plant",  "chicken", "mat_seed",
							//structures/industry 
							"hall", "building", "trampoline", "wooden_door", "stone_door", "ladder", "platform",
							"trap_block", "mounted_bow", "spikes", "archershop", "buildershop", "knightshop", "boatshop", "vehicleshop",
							"quarters", "storage", "drill", "factory", "saw", "fireplace", "tunnel",  "workbench", "tradingpost",
							"ctf_flag", "flag base", "tradingpost", "tent",
							 //old buildings
							"barracks", "bed", "dorm", "kitchen", "nursery", "research", "__storage__old",
							//vehicles
							"catapult", "ballista", "raft", "longboat", "warboat", "dinghy",  "airship", "bomber",
							//items 
							"lantern", "boulder", "bucket", "chest", "crate", "log", "powerup",
							"sponge", "scroll", "heart", "steak", "food",
							"keg", "bomb", "mine", "satchel", "waterbomb", "warboat", "arrow", "ballista_bolt",
							//mats
							"mat_wood", "mat_stone", "mat_gold", "mat_firearrows", "mat_bombarrows",  "mat_waterarrows", "mat_bombs",
							//components... really
							"bolter", "spiker", "dispenser", "lamp", "obstructor",  "receiver", "toggle", "transistor",
							"diode", "emitter", "inverter", "junction", "magazine", "oscillator", "randomizer",
							"wire", "tee", "elbow", "coin_slot", "lever", "pressure_plate", "push_button",
							"sensor"
		             	};
 	for (uint i = 0; i < blobnames.length; i++)
	{
		string blobname = blobnames[i];
		if (name == blobname)
		{
			return true;
		}
	}
	return false;
}

CPlayer@ GetPlayer(string username)
{
	username=			username.toLower();
	int playersAmount=	getPlayerCount();
	for(int i=0;i<playersAmount;i++){
		CPlayer@ player=getPlayer(i);
		if(player.getUsername().toLower()==username || (username.length()>=3 && player.getUsername().toLower().findFirst(username,0)==0)){
			return player;
		}
	}
	return null;
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
