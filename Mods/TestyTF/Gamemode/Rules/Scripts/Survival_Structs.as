// shared class PersistentPlayerInfo
// {
	// string name;
	// u8 team;
	// u32 teamkick_time;
	// u32 coins;

	// PersistentPlayerInfo() { Setup("", 255); }
	// PersistentPlayerInfo(string _name, u8 _team) { Setup(_name, _team); }
	
	// void Setup(string _name, u8 _team)
	// {
		// name = _name;
		// team = _team;
		// coins = 0;
		// teamkick_time = 0;
	// }
	
	// // PersistentPlayerInfo() { Setup("", 0); }
	// // PersistentPlayerInfo(string _name, u8 _team) { Setup(_name, _team); }
	
	// // void PersistentPlayerInfo(string _name, u8 _team)
	// // {
		// // name = _name;
		// // team = _team;
	// // }
// };

const u16 UPKEEP_COST_PLAYER = 10;

shared class TeamData
{
	TeamData() { Setup(); }
	
	u16 upkeep;
	u16 upkeep_cap;
	
	void Setup()
	{
		upkeep = 0;
		upkeep_cap = 0;
	}
};

void GetTeamData(u8 team, TeamData@ &out data)
{
	TeamData[]@ team_list;
	getRules().get("team_list", @team_list);
	
	if (team_list !is null && team < team_list.length)
	{	
		@data = team_list[team];
	}
}