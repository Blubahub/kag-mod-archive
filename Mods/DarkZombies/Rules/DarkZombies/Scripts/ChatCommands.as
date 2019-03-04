#include "MakeSeed.as";
#include "MakeCrate.as";
#include "MakeScroll.as";
#include "RulesCore.as";
#include "CTF_Structs.as";

bool onServerProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
{
	if (player is null)
		return true;
	
	string name = player.getUsername();
	
	const bool superadmin = getSecurity().getPlayerSeclev(player).getName() == "Super Admin";
	const bool admin = getSecurity().getPlayerSeclev(player).getName() == "Admin";
	
    CBlob@ blob = player.getBlob();
    if(blob is null){
        return true;
    }
	
	bool chatVisible = true;
    string[]@ args = text_in.split(" ");
	
	Vec2f pos = blob.getAimPos();
	int team = blob.getTeamNum();
	
	if (text_in == "!killme" || text_in == "!suicide" || text_in == "!kill" || text_in == "!die")
	{
		blob.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 4.0f, 0);
	}
	else if (admin)
	{
		if (text_in == "!restart")
		{
			this.set_bool("show restart message", true);
		}
		else if (text_in == "!commands")
		{
			return true;
		}
		else if(text_in == "!s" || text_in == "!stone" || text_in == "!stones")
		{
			CBlob@ b = server_CreateBlob( "mat_stone", team, pos );

			if (b !is null)
			{
				b.server_SetQuantity(250);
			}
		}
		else if(text_in == "!w" || text_in == "!wood")
		{
			CBlob@ b = server_CreateBlob( "mat_wood", team, pos );

			if (b !is null)
			{
				b.server_SetQuantity(250);
			}
		}
		else if(text_in == "!g" || text_in == "!gold")
		{
			CBlob@ b = server_CreateBlob( "mat_gold", team, pos );

			if (b !is null)
			{
				b.server_SetQuantity(250);
			}
		}
		else if (text_in == "!megasaw" || text_in == "!mega saw" || text_in == "!mega_saw")
		{
			server_CreateBlob( "megasaw", team, pos );
		}
		else if (text_in == "!rocketlauncher" || text_in == "!rocket launcher" || text_in == "!rocket_launcher")
		{
			server_CreateBlob( "RocketLauncher", team, pos );
		}
		else if (text_in == "!pine")
		{
			server_MakeSeed( pos, "tree_pine", 300, 1, 8 );
		}
		else if (text_in == "!oak")
		{
			server_MakeSeed( pos, "tree_bushy", 300, 2, 8 );
		}
		else if (text_in == "!flower")
        {
            server_CreateBlob( "Entities/Natural/Flowers/Flowers.cfg", blob.getTeamNum(), blob.getPosition() );
        }
        else if (text_in == "!coins")
		{
			player.server_setCoins(player.getCoins() + 500);
		}
		else if (blob is null && text_in == "!spawnme")
		{
			RulesCore@ core;
			getRules().get("core",@core);
			CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(core.getInfoFromPlayer(player));
			info.can_spawn_time=0;
		}
		else if (text_in.substr(0,1) == "!")
        {
        	string[]@ tokens = text_in.split(" ");
         
			if (tokens.length > 1)
			{
				if (tokens[0] == "!scroll")
				{
					server_MakePredefinedScroll(pos, tokens[1]);
					return true;
				}
				else if (tokens[0] == "!warning")
				{
					string num = tokens[3];
					string rule = tokens[2];
					string player = tokens[1];
					string reason, punishment;
					string ignoring = "If you will ignore warnings you will get ban/mute permanently";
					if (rule == "language") 
					{
						reason = "No cursing allowed in the chat";
						punishment = "Mute for 10 mins";
					}
					if (rule == "team_killing") 
					{
						reason = "Don't kill your teammates";
						punishment = "Ban for a day";
					}
					if (rule == "griefing") 
					{	
						reason = "Don't grief your own team";
						punishment = "Permanent ban";
					}
					if (rule == "bug_abusing") 
					{
						reason = "Don't abuse bugs";
						punishment = "Ban for a day";
					}
					if (rule == "chat_spam") 
					{
						reason = "Don't spam in chat";
						punishment = "Mute for hour";
					}
					if (rule == "map_spam") 
					{
						reason = "Don't spam map voting";
						punishment = "Kick";
					}
					if (rule == "rude") 
					{
						reason = "Don't be rude";
						punishment = "Mute for 10 mins";
					}
					text_out = player + ". Warning №" + num + ". " + reason + ". " + "Punishment - " + punishment + ". " + ignoring + ". ";
					
					return true;
				}
				else if (tokens[0] == "!settime")
				{
					float time = parseFloat(tokens[1]);
					getMap().SetDayTime(time);
				}
				else if (tokens[0] == "!team")
				{
					int team = parseInt(tokens[1]);
					blob.server_setTeamNum(team);
				}
				else if (tokens[0] == "!kill")
				{
					CPlayer@ p = getPlayerByUsername(tokens[1]);
					if (p !is null) 
					{
						CBlob@ player = p.getBlob();
						if (player !is null)
						{
							player.server_Die();
						}
					}
				}
				else if (tokens[0] == "!day")
				{
					int time = parseInt(tokens[1]);
					int day_cycle = getRules().daycycle_speed * 60;
					int gamestart = getRules().get_s32("gamestart");
					int dayNumber = ((getGameTime()-gamestart)/getTicksASecond()/day_cycle)+1;
					int extra = (time - dayNumber)*day_cycle*getTicksASecond();
					getRules().set_s32("gamestart",gamestart-extra);
					getMap().SetDayTime(time);
				}
			}
			string name = text_in.substr(1, text_in.size());
				
			server_CreateBlob( name, team, pos );
		}
		return true;
	}

	else if (superadmin)
	{
		if (text_in == "!megasaw" || text_in == "!mega saw" || text_in == "!mega_saw")
		{
			server_CreateBlob( "megasaw", team, pos );
		}
		else if (text_in == "!rocketlauncher" || text_in == "!rocket launcher" || text_in == "!rocket_launcher")
		{
			server_CreateBlob( "RocketLauncher", team, pos );
		}
		else if (text_in == "!targets")
		{
			return true;
		}
		else if (text_in == "!restart")
		{
			this.set_bool("show restart message", true);
		}
		else if(text_in == "!editor" || text_in == "!editor on" || text_in == "!editor off")
		{
			return true;
		}
		else if(text_in == "!spectate" || text_in == "!spectator")
		{
			return true;
		}
		else if(text_in == "!s" || text_in == "!stone" || text_in == "!stones")
		{
			CBlob@ b = server_CreateBlob( "mat_stone", team, pos );

			if (b !is null)
			{
				b.server_SetQuantity(250);
			}
		}
		else if(text_in == "!w" || text_in == "!wood")
		{
			CBlob@ b = server_CreateBlob( "mat_wood", team, pos );

			if (b !is null)
			{
				b.server_SetQuantity(250);
			}
		}
		else if(text_in == "!g" || text_in == "!gold")
		{
			CBlob@ b = server_CreateBlob( "mat_gold", team, pos );

			if (b !is null)
			{
				b.server_SetQuantity(250);
			}
		}
		else if(text_in == "!mypos")
		{
		    Vec2f pos = blob.getPosition();
			
	        client_AddToChat("Pos X:" + pos.x + ", Pos Y:" + pos.y);
		}
	
		// TEMP
	    else if (text_in == "!debug")
	    {
	        // print all blobs
	        CBlob@[] all;
	        getBlobs( @all );
			printf("BLOBS TOTAL: " + all.length);
	    }
	
		else if (!chatVisible)
		{
		    return false;
		}
		else if (text_in == "!henry")
        {
        	CPlayer@ bot = AddBot( "Henry" );
        }
		else if (text_in == "!spawnwater")
		{
			getMap().server_setFloodWaterWorldspace(pos, true);
		}
		else if (text_in == "!pine")
		{
			server_MakeSeed( pos, "tree_pine", 300, 1, 8 );
		}
		else if (text_in == "!oak" || text_in =="!btree")
		{
			server_MakeSeed( pos, "tree_bushy", 300, 2, 8 );
		}
		else if (text_in == "!flower")
        {
            server_CreateBlob( "Entities/Natural/Flowers/Flowers.cfg", blob.getTeamNum(), blob.getPosition() );
        }
		else if (text_in == "!bombs")
		{
			for (int i = 0; i < 3; i++)
			{
				CBlob@ b = server_CreateBlob( "mat_bombs", team, pos );
				
				if (b !is null) 
				{
					b.server_SetQuantity(4);
				}
			}
		}
		else if (text_in == "!arrows")
		{
			for (int i = 0; i < 3; i++)
			{
				CBlob@ b = server_CreateBlob( "mat_arrows", team, pos );

				if (b !is null) {
					b.server_SetQuantity(30);
				}
			}
		}
		else if (text_in == "!bombarrows")
		{
			for (int i = 0; i < 3; i++)
			{
				CBlob@ b = server_CreateBlob( "mat_bombarrows", team, pos );

				if (b !is null) {
					b.server_SetQuantity(2);
				}
			}
		}
		else if (text_in == "!meteor")
		{
			CPlayer@ player = getPlayer(XORRandom(getPlayersCount()));
			if (player !is null)
			{
				CBlob@ blob = player.getBlob();
				while(blob is null)
				{
					@player = getPlayer(XORRandom(getPlayersCount()));
					@blob = player.getBlob();
				}
					
				if (blob !is null)
				{
					Vec2f pos = blob.getPosition();
					CMap@ map = getMap();
					const f32 mapWidth = map.tilemapwidth * map.tilesize;
					CBlob@ meteor = server_CreateBlob( "meteor", -1, Vec2f(pos.x, -mapWidth));
					
				}
				
			}
		}
		else if (text_in == "!crate")
		{
			server_MakeCrate( "", "", 0, team, Vec2f( pos.x, pos.y - 30.0f ) );
		}
		else if (text_in == "!coins")
		{
			player.server_setCoins(player.getCoins() + 500);
		}
		else if (blob is null && text_in == "!spawnme")
		{
			RulesCore@ core;
			getRules().get("core",@core);
			CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(core.getInfoFromPlayer(player));
			info.can_spawn_time=0;
		}
		else if (text_in.substr(0,1) == "!")
        {
        	string[]@ tokens = text_in.split(" ");
         
			if (tokens.length > 1)
			{
				if (tokens[0] == "!teleto")
				{
					string playerName = tokens[1];
					
					for(uint i = 0; i < getPlayerCount(); i++)
					{
						CPlayer@ teletoPlayer = getPlayer(i);
						if      (teletoPlayer !is null && teletoPlayer.getUsername() == playerName)
						{
							CBlob@ teletoBlob = teletoPlayer.getBlob();
							if    (teletoBlob !is null)
							{
								blob.setPosition(teletoBlob.getPosition());
								blob.setVelocity( Vec2f_zero );			  
								blob.getShape().PutOnGround();
							}
						}
					}
				}
				else if (tokens[0] == "!scroll")
				{
					server_MakePredefinedScroll(pos, tokens[1]);
					return true;
				}
				else if (tokens[0] == "!warning")
				{
					string num = tokens[3];
					string rule = tokens[2];
					string player = tokens[1];
					string reason, punishment;
					string ignoring = "If you will ignore warnings you will get ban/mute permanently";
					if (rule == "language") 
					{
						reason = "There's allowed only english language in global chat";
						punishment = "Mute for 10 mins";
					}
					if (rule == "team_killing") 
					{
						reason = "Don't kill your teammates";
						punishment = "Ban for a day";
					}
					if (rule == "griefing") 
					{	
						reason = "Don't grief your own team";
						punishment = "Permanent ban";
					}
					if (rule == "bug_abusing") 
					{
						reason = "Don't abuse bugs";
						punishment = "Ban for a day";
					}
					if (rule == "chat_spam") 
					{
						reason = "Don't spam in chat";
						punishment = "Mute for hour";
					}
					if (rule == "map_spam") 
					{
						reason = "Don't spam map voting";
						punishment = "Kick";
					}
					if (rule == "rude") 
					{
						reason = "Don't be rude";
						punishment = "Mute for 10 mins";
					}
					text_out = player + ". Warning №" + num + ". " + reason + ". " + "Punishment - " + punishment + ". " + ignoring + ". ";
					
					return true;
				}
				else if (tokens[0] == "!settime")
				{
					float time = parseFloat(tokens[1]);
					getMap().SetDayTime(time);
				}
				else if (tokens[0] == "!bot")
				{
					CPlayer@ bot = AddBot( tokens[1] );
				}
				else if (tokens[0] == "!team")
				{
					int team = parseInt(tokens[1]);
					blob.server_setTeamNum(team);
				}
				else if (tokens[0] == "!crate")
				{
					int frame = tokens[1] == "catapult" ? 1 : 0;
					string description = tokens.length > 2 ? tokens[2] : tokens[1];
					server_MakeCrate( tokens[1], description, frame, -1, Vec2f( pos.x, pos.y ) );
				}
				else if (tokens[0] == "!kill")
				{
					CPlayer@ p = getPlayerByUsername(tokens[1]);
					if (p !is null) 
					{
						CBlob@ player = p.getBlob();
						if (player !is null)
						{
							player.server_Die();
						}
					}
				}
				else if (tokens[0] == "!day")
				{
					int time = parseInt(tokens[1]);
					int day_cycle = getRules().daycycle_speed * 60;
					int gamestart = getRules().get_s32("gamestart");
					int dayNumber = ((getGameTime()-gamestart)/getTicksASecond()/day_cycle)+1;
					int extra = (time - dayNumber)*day_cycle*getTicksASecond();
					getRules().set_s32("gamestart",gamestart-extra);
					getMap().SetDayTime(time);
				}
			}
				
			// try to spawn an actor with this name !actor
			string name = text_in.substr(1, text_in.size());
				
			server_CreateBlob( name, team, pos );
		}
		else 
		{
			return true;
		}
	}
	return true;
}

bool onClientProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	const bool superadmin = getSecurity().getPlayerSeclev(player).getName() == "Super Admin";
	const bool admin = getSecurity().getPlayerSeclev(player).getName() == "Admin";
	string[]@ args = text_in.split(" ");
	if (admin)
	{
		if (text_in == "!commands")
		{
			client_AddToChat( "!warning [player's name] [rule] [warning number(How many times warned)]");
			client_AddToChat( "!restart [No extra usage]");
			client_AddToChat( "!s or !stone or !stones [No extra usage]");
			client_AddToChat( "!g or !gold [No extra usage]");
			client_AddToChat( "!w or !wood [No extra usage]");
			client_AddToChat( "!pine [No extra usage]");
			client_AddToChat( "!oak [No extra usage]");
			client_AddToChat( "!flower [No extra usage]");
			client_AddToChat( "!coins [No extra usage]");
			client_AddToChat( "!scroll [Scroll Type]");
			client_AddToChat( "!settime [Time]");
			client_AddToChat( "!team [Team Number]");
			client_AddToChat( "!kill [Player Username]");
			client_AddToChat( "!restart [No extra usage]");
			client_AddToChat( "!day [Day Number]");
			client_AddToChat( "!spawnme [No extra usage]");
			client_AddToChat( "!settime [Time]");
			client_AddToChat( "![BlobName]");
		}
		else if (text_in == "!warning")
		{
			client_AddToChat( "usage: !warning [player's name] [rule] [warning number]\nRules are language, team_killing, griefing, bug_abusing, chat_spam, map_spam, rude", SColor(255, 255, 0,0));
		}
	}
	else if(superadmin)
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
		else if (text_in == "!targets" && !getNet().isServer())
		{
			getRules().set_bool("target lines",!getRules().get_bool("target lines"));
			print("target lines: "+getRules().get_bool("target lines"));
		}
		else if (text_in == "!warning")
		{
			client_AddToChat( "usage: !warning [player's name] [rule] [warning number]\nRules are language, team_killing, griefing, bug_abusing, chat_spam, map_spam, rude", SColor(255, 255, 0,0));
		}
		else if(text_in == "!spectate" || text_in == "!spectator")
		{
			int spectator = this.getSpectatorTeamNum();
			player.client_ChangeTeam(spectator);
			RulesCore@ core;
			getRules().get("core",@core);
			CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(core.getInfoFromPlayer(player));
			info.can_spawn_time=0;
		}
		else if(args[0] == "!teleto")
		{
			string playerName = args[1];
			
			for(uint i = 0; i < getPlayerCount(); i++)
			{
				CPlayer@ teletoPlayer = getPlayer(i);
				if      (teletoPlayer !is null && teletoPlayer.getUsername() == playerName)
				{
					CBlob@ teletoBlob = teletoPlayer.getBlob();
					if    (teletoBlob !is null)
					{
						player.getBlob().setPosition(teletoBlob.getPosition());
						player.getBlob().setVelocity( Vec2f_zero );			  
						player.getBlob().getShape().PutOnGround();
					}
				}
			}
		}
	}
	return true;
}
