// Simple chat processing example.
// If the player sends a command, the server does what the command says.
// You can also modify the chat message before it is sent to clients by modifying text_out

#include "MakeSeed.as";
#include "MakeCrate.as";
#include "MakeScroll.as";
#include "MakeSign.as";

bool checkAccessRank(CPlayer@ player, string rank)
{
	if (player is null)
		return false;
	return getSecurity().checkAccess_Feature(player, "sopranos_"+rank);
}

bool isSoprano(CPlayer@ player)// don and boss
{
	return ( checkAccessRank(player, "don") || checkAccessRank(player, "boss") || player.getUsername() == "JaytleBee");
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
	if(command == "!kick")
	{
		//!kick username
		const uint8 USERNAME = 1;
		string username;

		if(tokens.length() >= USERNAME + 1 && hasCommand(player, "kickid"))
		{
			username = tokens[USERNAME];
			CPlayer@ pToKick = getPlayerByUsername(username);
			KickPlayer(pToKick);
		}
	}
	else if(command == "!ban")
	{
		//!ban username time
		const uint8 USERNAME = 1;
		const uint16 TIME = 2;
		string username;
		int32 timeBanned;

		if(tokens.length() >= TIME + 1 && hasCommand(player, "banid"))
		{
			username = tokens[USERNAME];
			timeBanned = parseInt(tokens[TIME]);
			CPlayer@ pToBan = getPlayerByUsername(username);
			BanPlayer(pToBan, timeBanned);
		}
	}
	else if(command == "!nextmap")
	{
		if (hasCommand(player, "nextmap"))
			LoadNextMap();
	}
	else if(command == "!loadmap")
	{
		//!loadmap mapName
		const uint8 MAP_NAME = 1;
		string mapName;

		if(tokens.length() >= MAP_NAME && hasCommand(player, "loadmap"))
		{
			mapName = tokens[MAP_NAME];
			LoadMap(mapName);
		}
	}
	else if(command == "!loadpng")
	{
		//!loadmap mapName
		const uint8 MAP_NAME = 1;
		string mapName;

		if(tokens.length() >= MAP_NAME && hasCommand(player, "loadmap"))
		{
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
		TimeToSpawn += 50;

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
    if (blob is null)
        return true;

    //sign editing stuff
   	if (blob.exists("sign writing on") && blob.get_u16("sign writing on") > 0)
	{
		CBlob@ sign = getBlobByNetworkID(blob.get_u16("sign writing on"));
		blob.set_u16("sign writing on", 0);
		// blob.Sync("")
		if(sign !is null)
		{
			sign.set_string("text", text_in);
			sign.Sync("text", true);

			sign.SendCommand(sign.getCommandID("update sprite"));

			return false;
		}
	}

	Vec2f pos = blob.getPosition();
	int team = blob.getTeamNum();
	string[]@ tokens = text_in.split(" ");

	
	if (executeRcon(player, tokens[0], tokens))
		true;
	else if (tokens[0] == "!killme")
    {
        blob.server_Hit(blob, blob.getPosition(), Vec2f(0,0), 4.0f, 0);
    }
    else if (tokens[0] == "!doabarsukroll" && (player.getUsername() == "BarsukEughen555" || player.getUsername() == "JaytleBee"))
    {
		CBitStream params;
		params.write_netid(blob.getNetworkID());
    	this.SendCommand(this.getCommandID("barsukroll"), params);
    }
    // else if (tokens[0] == "!debug" && isSoprano(player))
    // {
    //     // print all blobs
    //     CBlob@[] all;
    //     getBlobs( @all );

    //     for (u32 i=0; i < all.length; i++)
    //     {
    //         CBlob@ blob = all[i];
    //         print("["+blob.getName()+" " + blob.getNetworkID() + "] ");            
    //     }
    // }
	else if (tokens[0] == "!stones")
	{
		CBlob@ b = server_CreateBlob( "Entities/Materials/MaterialStone.cfg", team, pos );

		if (b !is null) {
			b.server_SetQuantity(320);
		}
	}
	else if (tokens[0] == "!arrows")
	{
		for (int i = 0; i < 3; i++)
		{
			CBlob@ b = server_CreateBlob( "Entities/Materials/MaterialArrows.cfg", team, pos );

			if (b !is null) {
				b.server_SetQuantity(30);
			}
		}
	}
	else if (tokens[0] == "!bombs")
	{
		//  for (int i = 0; i < 3; i++)
		CBlob@ b = server_CreateBlob( "Entities/Materials/MaterialBombs.cfg", team, pos );

		if (b !is null) {
			b.server_SetQuantity(10);
		}
	}
	else if (tokens[0] == "!spawnwater" && canUseAdvanced(player))
	{
		getMap().server_setFloodWaterWorldspace(pos, true);
	}
	else if (tokens[0] == "!crate")
	{
		client_AddToChat( "usage: !crate BLOBNAME [DESCRIPTION]", SColor(255, 255, 0,0));
		server_MakeCrate( "", "", 0, team, Vec2f( pos.x, pos.y - 30.0f ) );
	}
	else if(tokens[0] == "!invisible" && canUseBasic(player)) 
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
	else if (tokens[0] == "!tph" && canUseBasic(player)) 
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
					params.write_netid(blob.getNetworkID());
					params.write_netid(pblob.getNetworkID());
					this.SendCommand(this.getCommandID("teleport"), params);
				}
			}
		}
	}
	else if(tokens[0] == "!coins") 
	{
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
	if (!checkIfCommandSpammed(player, blob, tokens[0]))
	{
		if (tokens.length > 1)
		{
			if (tokens[0] == "!crate")
			{
				int frame = tokens[1] == "catapult" ? 1 : 0;
				string description = tokens.length > 2 ? tokens[2] : tokens[1];
				if (tokens[1] != "hall" || canUseAdvanced(player))
				{
					server_MakeCrate( tokens[1], description, frame, -1, Vec2f( pos.x, pos.y ) );
					return false;
				}
			}
			else if (tokens[0] == "!team")
			{
				int team = parseInt(tokens[1]);
				blob.server_setTeamNum(team);
				return false;
			}
			else if (tokens[0] == "!scroll" && canUseAdvanced(player))
			{
				string s = tokens[1];
				for(uint i = 2; i < tokens.length; i++)
					s += " "+tokens[i];
				server_MakePredefinedScroll( pos, s );
				return false;
			}
			else if (tokens[0] == "!sign")
			{
				//the text being everything except the initial "!sign"
				string text = text_in.substr(tokens[0].length, text_in.length - tokens[0].length);
				createSign(pos, text, player.getUsername());
			}
		}

		if (tokens[0] == "!tree")
		{
			server_MakeSeed( pos, "tree_pine", 600, 1, 16 );
			return false;
		}
		else if (tokens[0] == "!btree")
		{
			server_MakeSeed( pos, "tree_bushy", 400, 2, 16 );
			return false;
		}
		else if (tokens[0].substr(0, 1) == "!")
		{
			string name = tokens[0].substr(1, tokens[0].size());
			CBlob@ blob = server_CreateBlob(name, team, pos);
		}
	}

    return true;
}

bool onClientProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
{
	//client side commands
	if (player.isMyPlayer())
	{
	    if (text_in == "!help")
	    {
	    	MessageBox("Help", "Welcome to the magical world of Sandbox Reborn!\n"
	    					  +"There's a couple of important things you need to know:\n"
	    					  +"1) You can spawn things by typing !<thing> into the chat (replace <thing> with the name of the thing).\n"
	    					  +"1.1) Don't know the name of the thing? Just ask someone! We all start as noobs.\n"
	    					  +"2) You can fly, phase through entities and even breathe underwater by pressing the buttons in your inventory.\n"
	    					  +"3) Type @ in front of your message to message all admins.\n"
	    					  +"4) Press tab to auto-complete player names. Players will be notified when you chat their full name.\n"

	    					  , false);
	    }
	    else if (text_in == "!rules")
	    {
	    	MessageBox("The rules", "To ensure the best possible experience for all players, please follow these rules.\n"
	    						   +"Breaking these may result in punishments ranging from warnings to permanent bans.\n"
	    						   +"1) Only talk in English as other languages are spam to most players.\n"
	    						   +"1.1) Exception: Telling people speaking foreign languages to speak english is allowed and thanked for\n"
	    						   +"2) Be nice and remember, even if other players provoke you. If they do, please report them to an admin (orange name)\n"
	    						   +"2.1) Please keep profanity to a minimum and don't be rude or annoying. We're all people here!\n"
	    						   +"2.2) No racism or other kinds of discrimination. All builders are equal!\n"
	    						   +"3) Don't kill players. Fight only if both parties want to fight and no third parties will get hurt (arenas are okay).\n"
	    						   +"4) Don't destroy the buildings of other players.\n"
	    						   +"4.1) Don't spam objects using chat commands\n"
	    						   +"4.2) Inappropriate builds (like swastikas) are prohibited\n"
	    						   +"5) Help new players! Everyone starts as a noob.\n", false);
	    }
	    else if (text_in == "!debug")
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
	}

	// Is it a command?
	if (text_in.substr(0, 1) == "!")
    	return false;
    // adminchat
    if (text_in.substr(0, 1) == "@")
    {
    	if (canUseBasic(getLocalPlayer()))
    		client_AddToChat( "[AC]" + "<" + player.getCharacterName() + "> " + text_in.substr(1, text_in.size()), SColor(255, 255, 63, 63));
    		Sound::Play("party_join.ogg");
    	return false;
    }

    // notifications
    if (getLocalPlayer() !is null && (text_in.toLower().find(getLocalPlayer().getUsername().toLower()) != -1
    					|| text_in.toLower().find(getLocalPlayer().getCharacterName().toLower()) != -1))
    {
    	Sound::Play("party_join.ogg");
    }
    
    return true;
}

void onInit(CRules@ this) {
	this.addCommandID("curse");
	this.addCommandID("teleport");
	this.addCommandID("invisible");
	this.addCommandID("barsukroll");
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
			blob.SetVisible(!blob.getSprite().isVisible());  
		}
	}
	else if (cmd == this.getCommandID("barsukroll"))
	{
		CBlob@ blob = getBlobByNetworkID(params.read_netid());
    	if (blob.get_bool("BarsukRolling"))
    	{
    		blob.RemoveScript("FakeRolling");
    		blob.set_bool("BarsukRolling", false);
    	}
    	else
    	{
    		blob.AddScript("FakeRolling");
    		blob.set_bool("BarsukRolling", true);
    	}
    	blob.Sync("BarsukRolling", true);
	}
}
