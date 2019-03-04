/* Profiles.as
 * author: Aphelion
 */

#include "ProfilesCommon.as";
#include "MessagesCommon.as";
#include "Settings.as";

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
	if(!getNet().isServer()) return;

	if (player !is null)
	{
		PlayerProfile@ profile = server_getProfile(player);
		
		if (ENABLE_PERSISTENT_STATS_SCOREBOARD && profile !is null)
		{
		    player.setKills(profile.kills);
			player.setDeaths(profile.deaths);
      player.setScore(profile.rank);
      checkTop(player);
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
	
	if (ENABLE_STATS_COMMAND && args[0] == "/stats")
	{
	    string username = player.getUsername();
		
	    if (ENABLE_STATS_COMMAND_OTHER_PLAYERS && args.length == 2)
		{
		    username = args[1];
		}
		
		PlayerProfile@ profile = server_getProfileByName(username);

		if (profile !is null)
		{
			int kills  = profile.kills;
			int deaths = profile.deaths;
      int rank = profile.rank;
			f32 ratio = kills / Maths::Max(deaths, 1.0f);

			cmdSendMessage(player.getUsername(), "-- Username: " + username + ", Kills: " + kills + ", Deaths: " + deaths + ", K/D: " + formatFloat(ratio, "", 3, 1) + "\nRank:"+rank+" --", false);
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
			victim.setScore(100 * (f32(victim.getKills()) / f32(victim.getDeaths() + 1)));

			PlayerProfile@ profile = server_getProfile(victim);

			if (profile !is null)
			{
				profile.deaths++;
        profile.rank -= 10;
        victim.setScore(profile.rank);
        checkTop(victim);
			}
			
			if (killer !is null) //requires victim so that killing trees matters
			{
				if (killer.getTeamNum() != blob.getTeamNum())
				{
					killer.setKills(killer.getKills() + 1);
					// temporary until we have a proper score system
					killer.setScore(100 * (f32(killer.getKills()) / f32(killer.getDeaths() + 1)));
					
					@profile = server_getProfile(killer);

					if (profile !is null)
					{
						profile.kills++;
            profile.rank += 10;
            killer.setScore(profile.rank);
            checkTop(killer);
					}
				}
			}
		}
	}
}
