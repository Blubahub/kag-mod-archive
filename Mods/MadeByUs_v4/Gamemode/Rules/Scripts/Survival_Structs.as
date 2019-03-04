shared class PersistentPlayerInfo
{
	string name;
	u8 team;
	u32 teamkick_time;
	u32 coins;
	bool spawned;

	PersistentPlayerInfo() { Setup("", 255); }
	PersistentPlayerInfo(string _name, u8 _team) { Setup(_name, _team); }
	
	void Setup(string _name, u8 _team)
	{
		name = _name;
		team = _team;
		coins = 0;
		teamkick_time = 0;
		spawned = false;
	}
	
	// PersistentPlayerInfo() { Setup("", 0); }
	// PersistentPlayerInfo(string _name, u8 _team) { Setup(_name, _team); }
	
	// void PersistentPlayerInfo(string _name, u8 _team)
	// {
		// name = _name;
		// team = _team;
	// }
};