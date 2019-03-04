/* Profiles.as
 * author: Aphelion
 */

#include "ProfilesCommon.as";
#include "MessagesCommon.as";
#include "ExpCommon.as";

void Reset( CRules@ this )
{
	if(!getNet().isServer()) return;
	
	PlayerProfile[]@ profiles = server_getProfiles();

	if (profiles !is null)
	{
		for(uint i = 0; i < profiles.length; i++)
		{
			PlayerProfile@ profile = profiles[i];

			if (profile !is null)
			{
				profile.SaveToFile();
			}
		}
	}

	PlayerProfile[] empty;
	this.set("profile array", empty);
}

void onRestart( CRules@ this )
{
	Reset(this);
}

void onInit( CRules@ this )
{
	Reset(this);
	
    this.addCommandID(cmd_message);
}

void onNewPlayerJoin( CRules@ this, CPlayer@ player )
{
  //OpenWebsite("https://discord.gg/EGA6ExQ");
  
	if(!getNet().isServer()) return;

	if (player !is null)
	{
		PlayerProfile@ profile = server_getProfile(player);
		
		if (  profile !is null)
		{
			player.setScore(profile.elo);
		}
	}
}

void onCommand( CRules@ this, u8 cmd, CBitStream@ params )
{
	if (cmd == this.getCommandID(cmd_message))
	{
	    string user, msg;
		bool red;
		
		if (!params.saferead_string(user) || !params.saferead_string(msg) || !params.saferead_bool(red))
		    return;
		
		CPlayer@ localPlayer = getLocalPlayer();
		if      (localPlayer !is null && localPlayer.getUsername() == user && getNet().isClient())
		{
	        client_AddToChat(msg, red ? RED : BLACK);
		}
	}
}

bool onServerProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if (player is null)
		return true;
	
    string[]@ args = text_in.split(" ");
	
	if ( args[0] == "/stats")
	{
	    string username = player.getUsername();
		
	    if ( args.length == 2)
		{
		    username = args[1];
		}
		
		PlayerProfile@ profile = server_getProfileByName(username);

		if (profile !is null)
		{
			int elo  = profile.elo;

			cmdSendMessage(player.getUsername(), "-- Username: " + username + ", Elo: " + elo +" --", false);
		}
	}

	return true;
}

// set kills and deaths

void onBlobDie(CRules@ this, CBlob@ blob)
{
	if (blob !is null)
	{
		CPlayer@ killer = blob.getPlayerOfRecentDamage();
		CPlayer@ victim = blob.getPlayer();

		if (victim !is null)
		{
			victim.setDeaths(victim.getDeaths() + 1);
			// temporary until we have a proper score system

			
			
			if (killer !is null) //requires victim so that killing trees matters
			{
				if (killer.getTeamNum() != blob.getTeamNum())
				{
					killer.setKills(killer.getKills() + 1);
          
          CBlob@ actualkiller = killer.getBlob();
          if(actualkiller !is null)
          {
            actualkiller.set_u32("Exp", actualkiller.get_u32("Exp") + 1);
            setProfileByBlobName(actualkiller);
          }
					// temporary until we have a proper score system
          
          PlayerProfile@ profile = server_getProfile(victim);

          PlayerProfile@ profile1 = server_getProfile(killer);

					if (profile !is null && profile1 !is null)
					{
						float r = Maths::Pow(10,profile.elo/400.0f);
            float r1 = Maths::Pow(10,profile1.elo/400.0f);
            
            float e = r / (r + r1);
            float e1 = r1 / (r + r1);
            profile.elo = Maths::Round(profile.elo + ( 100* (0-e)));
            profile1.elo = Maths::Round(profile1.elo + ( 100* (1-e1)));
           
            
            killer.setScore(profile1.elo);
            victim.setScore(profile.elo);
            
					}
				}
			}
		}
	}
}
