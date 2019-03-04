// management structs

#include "Rules/CommonScripts/BaseTeamInfo.as";
#include "Rules/CommonScripts/PlayerInfo.as";

shared class RapturePlayerInfo : PlayerInfo
{
	u32 can_spawn_time;
	bool thrownBomb;

	RapturePlayerInfo() { Setup("", 0, ""); }
	RapturePlayerInfo(string _name, u8 _team, string _default_config) { Setup(_name, _team, _default_config); }

	void Setup(string _name, u8 _team, string _default_config)
	{
		PlayerInfo::Setup(_name, _team, _default_config);
		can_spawn_time = 0;
		thrownBomb = false;
	}
};

//teams

shared class RaptureTeamInfo : BaseTeamInfo
{
	PlayerInfo@[] spawns;
	int kills;

	RaptureTeamInfo() { super(); }

	RaptureTeamInfo(u8 _index, string _name)
	{
		super(_index, _name);
	}

	void Reset()
	{
		BaseTeamInfo::Reset();
		kills = 0;
		//spawns.clear();
	}
};

shared class Rapture_HUD
{
	//is this our team?
	u8 team_num;
	//exclaim!
	string unit_pattern;
	u8 spawn_time;
	//units
	s16 kills;
	s16 kills_limit; //here for convenience

	Rapture_HUD() { }
	Rapture_HUD(CBitStream@ bt) { Unserialise(bt); }

	void Serialise(CBitStream@ bt)
	{
		bt.write_u8(team_num);
		bt.write_string(unit_pattern);
		bt.write_u8(spawn_time);
		bt.write_s16(kills);
		bt.write_s16(kills_limit);
	}

	void Unserialise(CBitStream@ bt)
	{
		team_num = bt.read_u8();
		unit_pattern = bt.read_string();
		spawn_time = bt.read_u8();
		kills = bt.read_s16();
		kills_limit = bt.read_s16();
	}

};
