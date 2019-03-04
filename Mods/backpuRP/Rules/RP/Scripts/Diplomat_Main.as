//Version 1
//Core rules for RP - Diplomat stuff


///u8 team Name;
// Team number vs 

///Status
// 1 = war
// 2 = neutral
// 3 = friends/allies


///Every possible combinations of teams
// 0 1 = 1
// 0 2 = 2
// 0 3 = 3
/// 1 0 = 1
// 1 2 = 3
// 1 3 = 4
/// 2 0 = 2
/// 2 1 = 3
// 2 3 = 5
/// 3 0 = 3
/// 3 1 = 4
/// 3 2 = 5


// What teams are in use;
// 0 1
// 0 2
// 0 3
// 1 2
// 1 3
// 2 3
void syncDiplomatStatus(CRules@ this,int team,int team2, int status)
{
	//Make sure we check the teams before hand
	this.set_u8(getTeamNumber(team,team2), status);
	if(getNet().isServer())
	{
		this.Sync(getTeamNumber(team,team2), false);
	}
}

string getTeamNumber(int team, int team2)
{
	switch(team+team2)
	{
		case 1:
			return "0 1";

		case 2:
			return "0 2";

		case 3:
			if(team == 0 || team2 == 0)
				return "0 3";
			else
				return "1 2";
		
		case 4:
			return "1 3";

		case 5: 
			return "2 3";

		default:
			return "";
	}
	return "";
}


int getDiplomatStatus(CRules@ this, int team,int team2)
{
	return this.get_u8(getTeamNumber(team,team2));
}