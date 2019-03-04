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
		PlayerProfile@ profile = server_GetOrCreateProfile(player.getUsername());
		
		if (ENABLE_PERSISTENT_STATS_SCOREBOARD && profile !is null)
		{
		    player.setKills(profile.kills);
			player.setDeaths(profile.deaths);
			player.setScore(100 * (f32(player.getKills()) / f32(player.getDeaths() + 1)));
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
					}
				}
			}
		}
	}
}
