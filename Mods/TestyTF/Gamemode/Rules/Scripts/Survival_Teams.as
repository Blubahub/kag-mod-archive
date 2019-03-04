#include "Survival_Structs.as";

void onInit(CRules@ this)
{
	Reset(this);
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void Reset(CRules@ this)
{
	TeamData[] team_list = {TeamData(), TeamData(), TeamData(), TeamData(), TeamData(), TeamData() ,TeamData()};
	this.set("team_list", @team_list);
}

// Too many people complained
// void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customData)
// {
	// if (victim !is null)
	// {
		// u8 team = victim.getTeamNum();
	
		// TeamData@ team_data;
		// GetTeamData(team, @team_data);
		
		// if (team_data !is null)
		// {
			// if (team_data.upkeep > team_data.upkeep_cap)
			// {
				// victim.server_setTeamNum(100 + XORRandom(100));
				// client_AddToChat("Due to " + getRules().getTeam(team).getName() + "'s upkeep being too high, " + victim.getCharacterName() + " had to leave the faction.");
			// }
		// }
	// }
// }

void onTick(CRules@ this)
{
	if (getGameTime() % 15 == 0)
	{
		TeamData[]@ team_list;

		this.get("team_list", @team_list);
		u8 maxTeams = team_list.length;
		
		if (team_list !is null)
		{	
			for (u32 i = 0; i < team_list.length; i++) 
			{
				team_list[i].upkeep = 0;
				team_list[i].upkeep_cap = 10;
			}
		
			for (u32 i = 0; i < getPlayersCount(); i++)
			{
				CPlayer@ p = getPlayer(i);
				
				if (p !is null)
				{
					u8 team = p.getTeamNum();
					if (team > maxTeams) continue;
					
					team_list[team].upkeep += 10;
				}
			}
		
			CBlob@[] buildings;
			if (getBlobsByTag("upkeep building", @buildings))
			{
				for (u32 i = 0; i < buildings.length; i++)
				{
					CBlob@ blob = buildings[i];
					u8 team = blob.getTeamNum();
					
					if (team > maxTeams) continue;
										
					team_list[team].upkeep += blob.get_u8("upkeep cost");
					team_list[team].upkeep_cap += blob.get_u8("upkeep cap increase");
				}
			}
					
			// string stats = "Team Data:\n";
			
			// for (int i = 0; i < team_list.length; i++)
			// {
				// stats += "\n Team: " + i + "; Upkeep: " + team_list[i].upkeep + " / " + team_list[i].upkeep_cap;
			// }
			
			// print(stats);
		}
		// else print("null");
	}
}

