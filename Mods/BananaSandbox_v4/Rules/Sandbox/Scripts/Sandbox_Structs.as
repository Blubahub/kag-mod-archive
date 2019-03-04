// management structs

#include "Rules/CommonScripts/BaseTeamInfo.as";
#include "Rules/CommonScripts/PlayerInfo.as";

namespace ItemFlag
{
	const u32 Builder = 0x01;
	const u32 Archer = 0x02;
	const u32 Knight = 0x04;
}

shared class SandboxPlayerInfo : PlayerInfo
{
	u32 can_spawn_time;

	u32 flag_captures;

	u32 spawn_point;

	u32 items_collected;

	u32 spam_count;

	u32 spam_timer;

	u32 spam_cooldown;

	SandboxPlayerInfo() { Setup("", 0, ""); }
	SandboxPlayerInfo(string _name, u8 _team, string _default_config) { Setup(_name, _team, _default_config); }

	void Setup(string _name, u8 _team, string _default_config)
	{
		PlayerInfo::Setup(_name, _team, _default_config);
		can_spawn_time = 0;
		flag_captures = 0;
		spawn_point = 0;

		items_collected = 0;

        spam_count = 0;
        spam_timer = 0;
        spam_cooldown = 0;
	}
};

//teams

shared class SandboxTeamInfo : BaseTeamInfo
{
	PlayerInfo@[] spawns;

	SandboxTeamInfo() { super(); }

	SandboxTeamInfo(u8 _index, string _name)
	{
		super(_index, _name);
	}

	void Reset()
	{
		BaseTeamInfo::Reset();
		//spawns.clear();
	}
};
