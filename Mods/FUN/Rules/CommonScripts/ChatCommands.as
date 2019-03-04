#include "MakeSeed.as";
#include "MakeCrate.as";
#include "MakeScroll.as";

bool onServerProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
{
	if (player is null)
		return true;

	string adminName = player.getUsername();
	bool admin;
	if (adminName == "Diprog" || adminName == "RaptorAnton" || adminName == "AsuMagic" || adminName == "RichardSTF") admin = true;
	else admin = false;
    CBlob@ blob = player.getBlob();

    if (blob is null) {
        return true;
    }
	
	
	if (player.isMod())
	{
		if (text_in == "!warning")
		{
			client_AddToChat( "usage: !warning [player's name] [rule] [warning number]\nRules are language, team_killing, griefing, bug_abusing, chat_spam, map_spam, rude", SColor(255, 255, 0,0));
		}
		if (text_in == "!restart")
		{
			this.set_bool("show restart message", true);
		}
		if (text_in.substr(0,1) == "!")
		{
			// check if we have tokens
			string[]@ tokens = text_in.split(" ");

			if (tokens.length > 1)
			{
				if (tokens[0] == "!warning")
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
				if (tokens[0] == "!restart" && player.isMod())
				{
					int time = parseInt(tokens[1]);
					this.set_bool("show restart message", true);
					this.set_u32("show time", time);
				}
			}
		}
	}
	
	if(admin)
	{
		Vec2f pos = blob.getPosition();
		int team = blob.getTeamNum();
		
		if (text_in == "!spawnwater" && player.isMod())
		{
			getMap().server_setFloodWaterWorldspace(pos, true);
		}
		else if (text_in == "!bot")
		{
			CPlayer@ bot = AddBot("Henry");
			return true;
		}
		if (text_in.substr(0,1) == "!")
		{
			string[]@ tokens = text_in.split(" ");

			if (tokens.length > 1)
			{
				if (tokens[0] == "!crate")
				{
					int frame = tokens[1] == "catapult" ? 1 : 0;
					string description = tokens.length > 2 ? tokens[2] : tokens[1];
					server_MakeCrate( tokens[1], description, frame, -1, Vec2f( pos.x, pos.y ) );
				}
				else if (tokens[0] == "!bot")
				{
					string s = tokens[1];
					CPlayer@ bot = AddBot(s);
					return true;
				}
				else if (tokens[0] == "!corpse")
				{
					string s = tokens[1];
					CBlob@ corpse = server_CreateBlob(s, team, pos);
					if (corpse !is null) corpse.Tag("dead");
				}
				else if (tokens[0] == "!tp")
				{
					CPlayer@ p = getPlayerByUsername(tokens[1]);
					CPlayer@ toP = getPlayerByUsername(tokens[2]);
					if (p !is null && toP !is null) 
					{
						CBlob@ player = p.getBlob();
						CBlob@ toPlayer = toP.getBlob();
						if (player !is null && toPlayer !is null)
						{
							player.setPosition(toPlayer.getPosition());
						}
					}
				}
				else if (tokens[0] == "!invis")
				{
					CPlayer@ p = getPlayerByUsername(tokens[1]);
					bool vis = (tokens[2] == "1");
					if (p !is null) 
					{
						CBlob@ blob = p.getBlob();
						if (blob !is null)
						{
							if (vis)
								blob.SetVisible(true);
							else
								blob.SetVisible(false);
						}
					}
				}
				else if (tokens[0] == "!tpp")
				{
					CPlayer@ p = getPlayerByUsername(tokens[1]);
					float x = parseFloat(tokens[2]);
					float y = parseFloat(tokens[3]);
					if (p !is null) 
					{
						CBlob@ player = p.getBlob();
						if (player !is null)
						{
							player.setPosition(Vec2f(x,y));
						}
					}
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
				else if (tokens[0] == "!coins")
				{
					int coins = parseInt(tokens[1]);
					player.server_setCoins( player.getCoins() + coins );
				}
				else if (tokens[0] == "!team")
				{
					int team = parseInt(tokens[1]);
					blob.server_setTeamNum(team);
				}
				
				return true;
			}

			// try to spawn an actor with this name !actor
			string name = text_in.substr(1, text_in.size());

			if (server_CreateBlob( name, team, pos ) is null) {
				client_AddToChat( "blob " + text_in + " not found", SColor(255, 255, 0,0));
			}
		}
	}

    return true;
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
