// Simple chat processing example.
// If the player sends a command, the server does what the command says.
// You can also modify the chat message before it is sent to clients by modifying text_out

#include "MakeSeed.as";
#include "MakeCrate.as";
#include "MakeScroll.as";

bool checkAccessRank(CPlayer@ player, string rank)
{
	if (player is null)
		return false;
	return getSecurity().checkAccess_Feature(player, "sopranos_"+rank);
}

bool isSoprano(CPlayer@ player)// don and boss
{
	return ( checkAccessRank(player, "don") || checkAccessRank(player, "boss") );
}

bool canUseAdvanced(CPlayer@ player)// gangsters
{
	return ( isSoprano(player) || checkAccessRank(player, "gangster") );
}

bool canUseBasic(CPlayer@ player)// thugs and hitmen
{
	return ( canUseAdvanced(player) || checkAccessRank(player, "thug") );
}

bool canUseDefault(CPlayer@ player)
{
	return true;
}

bool hasCommand(CPlayer@ player, string command)
{
	return getSecurity().checkAccess_Command(player, "command");
}

bool executeRcon(CPlayer@ player, string command, string[]@ tokens)
{
	if(command == "!kick") {
		//!kick username
		const uint8 USERNAME = 1;
		string username;

		if(tokens.length() >= USERNAME + 1 && hasCommand(player, "kickid")) {
			username = tokens[USERNAME];
			CPlayer@ pToKick = getPlayerByUsername(username);
			KickPlayer(pToKick);
		}

	} else if(command == "!ban") {
		//!ban username time
		const uint8 USERNAME = 1;
		const uint16 TIME = 2;
		string username;
		int32 timeBanned;

		if(tokens.length() >= TIME + 1 && hasCommand(player, "banid")) {
			username = tokens[USERNAME];
			timeBanned = parseInt(tokens[TIME]);
			CPlayer@ pToBan = getPlayerByUsername(username);
			BanPlayer(pToBan, timeBanned);
		}

	} else if(command == "!nextmap") {
		if ( hasCommand(player, "nextmap"))
			LoadNextMap();
	} else if(command == "!loadmap") {
		//!loadmap mapName
		const uint8 MAP_NAME = 1;
		string mapName;

		if(tokens.length() >= MAP_NAME && hasCommand(player, "loadmap")) {
			mapName = tokens[MAP_NAME];
			LoadMap(mapName);
		}

	} else if(command == "!loadpng") {
		//!loadmap mapName
		const uint8 MAP_NAME = 1;
		string mapName;

		if(tokens.length() >= MAP_NAME && hasCommand(player, "loadmap")) {
			mapName = tokens[MAP_NAME];
			mapName = mapName + ".png";
			LoadMap(mapName);
		}

	} else if(command == "!loadpng") {
		//!loadmap mapName
		const uint8 MAP_NAME = 1;
		string mapName;

		if(tokens.length() >= MAP_NAME && hasCommand(player, "loadmap")) {
			mapName = tokens[MAP_NAME];
			mapName = mapName + ".png";
			LoadMap(mapName);
		}
	}
	else
	{
		return false;
	}
	return true;
}

void preventCommandSpam(CBlob@ blob, const string& in token, s32 TimeToSpawn)
{
	blob.push( "SpammedCommandsList", token);
	blob.push( "SpammedCommandsTimes", TimeToSpawn);
}

bool checkIfCommandSpammed(CPlayer@ player, CBlob@ blob, const string& in token)
{
	if (canUseAdvanced(player))
		return false;

	if (token == "!hall")
		return true;
	if (token == "!bomb")
		return false;
	string[]@ commands_spam_list;
	s32[]@ commands_spam_times;

    blob.get( "SpammedCommandsList", @commands_spam_list );
    blob.get( "SpammedCommandsTimes", @commands_spam_times );

    s32 TimeToSpawn = getGameTime();
	if ( token == "!zombie" || token == "!wraith" || token == "!skeleton" || token == "!greg")
		TimeToSpawn += 600;
	else if ( token == "!zombieknight" || token == "!shark" || token == "!bison" || token == "!bomber" || token == "!airship" || token == "!zeppelin" )
		TimeToSpawn += 1800;
	else
		TimeToSpawn += 150;

    if (commands_spam_list is null)
    {
    	string[] empty_commands_spam_list;
		s32[] empty_commands_spam_times;
    	blob.set( "SpammedCommandsList", empty_commands_spam_list );
    	blob.set( "SpammedCommandsTimes", empty_commands_spam_times );
    	preventCommandSpam(blob, token, TimeToSpawn);
    	return false;
    }

	int found = commands_spam_list.find(token);
	if (found >= 0)
	{
		if (getGameTime() - commands_spam_times[found] >= 0)
		{
			commands_spam_times[found] = TimeToSpawn;
			blob.set( "SpammedCommandsTimes", commands_spam_times );
			return false;
		}
		return true;
	}
	else
	{
		preventCommandSpam(blob, token, TimeToSpawn);
		return false;
	}
}

bool onServerProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
{
	if (player is null)
		return true;

	
    CBlob@ blob = player.getBlob();

    if (blob is null) {
        return true;
    }

	Vec2f pos = blob.getPosition();
	int team = blob.getTeamNum();

	if (text_in == "!killme")
    {
        blob.server_Hit( blob, blob.getPosition(), Vec2f(0,0), 4.0f, 0);
    }
	else if (text_in == "!bot" && isSoprano(player))
    {
        CPlayer@ bot = AddBot( "Henry" );
    }
    else if (text_in == "!debug" && isSoprano(player))
    {
        // print all blobs
        CBlob@[] all;
        getBlobs( @all );

        for (u32 i=0; i < all.length; i++)
        {
            CBlob@ blob = all[i];
            print("["+blob.getName()+" " + blob.getNetworkID() + "] ");            
        }
    }
	else if (text_in == "!stones")
	{
		CBlob@ b = server_CreateBlob( "Entities/Materials/MaterialStone.cfg", team, pos );

		if (b !is null) {
			b.server_SetQuantity(320);
		}
	}
	else if (text_in == "!arrows")
	{
		for (int i = 0; i < 3; i++)
		{
			CBlob@ b = server_CreateBlob( "Entities/Materials/MaterialArrows.cfg", team, pos );

			if (b !is null) {
				b.server_SetQuantity(30);
			}
		}
	}
	else if (text_in == "!bombs")
	{
		//  for (int i = 0; i < 3; i++)
		CBlob@ b = server_CreateBlob( "Entities/Materials/MaterialBombs.cfg", team, pos );

		if (b !is null) {
			b.server_SetQuantity(10);
		}
	}
	else if (text_in == "!spawnwater" && canUseAdvanced(player))
	{
		getMap().server_setFloodWaterWorldspace(pos, true);
		return false;
	}
	else if (text_in == "!crate")
	{
		client_AddToChat( "usage: !crate BLOBNAME [DESCRIPTION]", SColor(255, 255, 0,0));
		server_MakeCrate( "", "", 0, team, Vec2f( pos.x, pos.y - 30.0f ) );
	}
	else if (text_in.substr(0,1) == "!")
	{
		if (text_in.substr(0,4) == "!mat")
		{
			// try to spawn material
			string name = text_in.substr(1, text_in.size());

			if (server_CreateBlob( name, team, pos ) is null) {
				client_AddToChat( "blob " + text_in + " not found", SColor(255, 255, 0,0));
			}
			return false;
		}

		// check if we have tokens
		string[]@ tokens = text_in.split(" ");

		if (executeRcon(player, tokens[0], tokens))
			return false;

		if(tokens[0] == "!invisible" && canUseBasic(player)) 
		{
			string username = (tokens.length() >= 2) ? tokens[1] : player.getUsername();
			CPlayer@ pToInvis = getPlayerByUsername(username);
			if(pToInvis !is null)	{
				CBlob@ blob = pToInvis.getBlob();
				if(blob !is null) {
					CBitStream params;
					params.write_netid(blob.getNetworkID());
					this.SendCommand(this.getCommandID("invisible"), params);
				}
			}
		}
		else if (tokens[0] == "!curse" && canUseAdvanced(player)) 
		{
			if(tokens.length() == 2) 
			{
				string username = tokens[1];
				CPlayer@ pToAffect = getPlayerByUsername(username);
				if(pToAffect !is null) {
					CBlob@ blob = pToAffect.getBlob();
					if(blob !is null) {
						CBitStream params;
						params.write_netid(blob.getNetworkID());
						this.SendCommand(this.getCommandID("curse"), params);
					}
				}
			}
		}
		else if (tokens[0] == "!tp" && canUseBasic(player)) 
		{
			if(tokens.length() == 2) 
			{
				string username = tokens[1];
				CPlayer@ pToAffect = getPlayerByUsername(username);
				if(pToAffect !is null) {
					CBlob@ blob = pToAffect.getBlob();
					CBlob@ pblob = player.getBlob();
					if(blob !is null && pblob !is null) {
						CBitStream params;
						params.write_netid(pblob.getNetworkID());
						params.write_netid(blob.getNetworkID());
						this.SendCommand(this.getCommandID("teleport"), params);
					}
				}
			}
		}
		else if(tokens[0] == "!coins") 
		{
			// check if we have tokens
			string[]@ tokens = text_in.split(" ");
			if (tokens.length > 1)
			{
				player.server_setCoins(player.getCoins() + parseInt(tokens[1]));
			}
			else
				player.server_setCoins(player.getCoins() + 100);
		}
		else if(tokens[0] == "!kill" && canUseAdvanced(player))
		{
			string username;
			Vec2f pos;

			if(tokens.length() == 2) {
				username = tokens[1];
				CPlayer@ pToAffect = getPlayerByUsername(username);
				
				if(pToAffect !is null && player !is null) {
					CBlob@ bToAffect = pToAffect.getBlob();
					pos = bToAffect.getPosition();
					CBlob@ bWhoTyped = player.getBlob();
					if(bToAffect !is null && bWhoTyped !is null) {
						bWhoTyped.server_Hit(bToAffect, pos, Vec2f(0, 0), 10.0, 0);
					}
				}
			}
		}
		else if(tokens[0] == "!plague" && canUseAdvanced(player))
		{
			Vec2f pos;
			
			for(uint8 i = 0; i < getPlayerCount(); i++) {
				CPlayer@ pToAffect = getPlayer(i);
				if(pToAffect !is null && player !is null && player.getUsername() != pToAffect.getUsername() 
				&& player.getTeamNum() != pToAffect.getTeamNum()) {
					CBlob@ bToAffect = pToAffect.getBlob();
					CBlob@ bWhoTyped = player.getBlob();
					if(bToAffect !is null && bWhoTyped !is null) {
						pos = bToAffect.getPosition();
						bWhoTyped.server_Hit(bToAffect, pos, Vec2f(0, 0), 10.0, 0);
					}
				}
			}
		}
		else if(tokens[0] == "!rain" && canUseAdvanced(player))
		{
			const uint8 BLOB = 1;
			const uint8 TEAM = 2;
			const uint8 INTERVAL = 18;
			int16 amount = 1;
			int8 teamNum;
			string blobName;

			blobName = (tokens.length() >= BLOB + 1) ? tokens[BLOB] : "fishy";

			if(tokens.length() >= TEAM + 1) {
				teamNum = parseInt(tokens[TEAM]);
			} else if(player !is null)	{
				CBlob@ blob = player.getBlob();
				if(blob !is null) {
					teamNum = blob.getTeamNum();
				} else {
					teamNum = 0;
				}
			} else {
				teamNum = 0;
			}

			CMap@ map = getMap();
			if(map !is null) {
				uint16 tileSize = map.tilesize;
				uint16 tileMapWidth = map.tilemapwidth;
				uint16 mapWidth = tileMapWidth * tileSize;

				const uint8 ECCENTRICITY = 3;

				int16 posX = 0;
				int16 posY = 0;
				Vec2f pos;

				float velX;
				float velY;
				Vec2f velocity;
				
				float torque;

				bool activatedKeg = false;
				if(blobName == "lkeg") {
					blobName = "keg";
					activatedKeg = true;
				}

				for(uint16 i = 0; i < tileMapWidth; i += INTERVAL) {
					pos = Vec2f(posX, posY);
					if(posX < mapWidth) {
									
						CBlob@ blob = server_CreateBlob(blobName, teamNum, pos);
						blob.SetDamageOwnerPlayer(player);
						blob.server_SetQuantity(amount);
						if(activatedKeg == true) {
							blob.SendCommand(blob.getCommandID("activate"));
						} 

						velX = XORRandom(ECCENTRICITY);
						velY = XORRandom(ECCENTRICITY);
						torque = XORRandom(ECCENTRICITY);

						if(XORRandom(2) == 1) {
							velX = 0 - velX;
						}
						if(XORRandom(2) == 1) {
							torque = 0 - torque;
						}

						velocity = Vec2f(velX, velY);
						blob.setVelocity(velocity + blob.getOldVelocity());
						blob.AddTorque(torque);

						posX = tileSize * i + XORRandom(INTERVAL);
						posY = tileSize * XORRandom(INTERVAL);
					}
				}
			}

		}

		// spawning things - check whether they are spammed
		if (checkIfCommandSpammed(player, blob, tokens[0]))
			return false;

		if (tokens.length > 1)
		{
			if (tokens[0] == "!crate")
			{
				bool isGun = tokens[1].split("_")[0] == "gun";
				int frame = tokens[1] == "catapult" ? 1 : 0;
				string description = tokens.length > 2 ? tokens[2] : tokens[1];
				if ((isGun || tokens[1] == "hall") && not canUseAdvanced(player))
					return false;
				server_MakeCrate( tokens[1], description, frame, -1, Vec2f( pos.x, pos.y ) );
			}
			else if (tokens[0] == "!team")
			{
				int team = parseInt(tokens[1]);
				blob.server_setTeamNum(team);
			}
			else if (tokens[0] == "!scroll" && canUseAdvanced(player))
			{
				string s = tokens[1];
				for(uint i = 2; i < tokens.length; i++)
					s += " "+tokens[i];
				server_MakePredefinedScroll( pos, s );
			}
		}

		string name = text_in.substr(1, text_in.size());

		if (text_in == "!tree")
		{
			server_MakeSeed( pos, "tree_pine", 600, 1, 16 );
		}
		else if (text_in == "!btree")
		{
			server_MakeSeed( pos, "tree_bushy", 400, 2, 16 );
		}


		bool isGun = text_in.split("_")[0] == "!gun";
    	if (isGun && not canUseBasic(player))
    		return false;

		// try to spawn an actor with this name !actor
		if (server_CreateBlob( name, team, pos ) is null) {
			client_AddToChat( "blob " + text_in + " not found", SColor(255, 255, 0,0));
		}
	}
	else
	{
		return true;
	}

    return false;
}

bool onClientProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
{
    if (text_in == "!debug" && !getNet().isServer())
    {
        // print all blobs
        CBlob@[] all;
        getBlobs( @all );

        for (u32 i=0; i < all.length; i++)
        {
            CBlob@ blob = all[i];
            print("["+blob.getName()+" " + blob.getNetworkID() + "] ");

            if (blob.getShape() !is null)
			{
				CBlob@[] overlapping;		
				if (blob.getOverlapping( @overlapping ))
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

void onInit(CRules@ this) {
	this.addCommandID("curse");
	this.addCommandID("teleport");
	this.addCommandID("invisible");
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params) {

	if(cmd == this.getCommandID("curse")) 
	{
		CBlob@ blob = getBlobByNetworkID(params.read_netid());
		if(blob !is null) {
			blob.server_SetTimeToDie(12);
			blob.SetMass(blob.getMass() * 1.5);

			CSprite@ sprite = blob.getSprite();
			if(sprite !is null) {
				sprite.PlaySound(XORRandom(2) == 0 ? "EvilLaugh.ogg" : "EvilLaughShort1.ogg");
				const string filePath = "../Mods/CC+/Sprites/EvilLightning.png";
				CSpriteLayer@ lightning = sprite.addSpriteLayer("lightning", filePath, 32, 32, -1, -1);
				if (lightning !is null) {
					lightning.addAnimation("default", 4, false);
					int32[] frames;
					for (uint8 i = 0; i < 96; i++) {
						frames.push_back(i);
					}
					lightning.animation.AddFrames(frames);
				}
			}
		}
	} 
	else if(cmd == this.getCommandID("teleport")) 
	{
		CBlob@ pblob = getBlobByNetworkID(params.read_netid());
		CBlob@ blob = getBlobByNetworkID(params.read_netid());
		if(blob !is null && pblob !is null) {
			Vec2f pos = blob.getPosition();
			pblob.setPosition(pos);
		}
	}  
	else if(cmd == this.getCommandID("invisible")) 
	{
		CBlob@ blob = getBlobByNetworkID(params.read_netid());
		if(blob !is null) {
			blob.UnsetMinimapVars();	//Remove minmap icon.
			blob.SetVisible(false);  
		}
	} 
}
