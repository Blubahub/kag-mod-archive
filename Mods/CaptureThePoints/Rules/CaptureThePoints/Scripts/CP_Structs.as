// management structs

#include "Rules/CommonScripts/BaseTeamInfo.as";
#include "Rules/CommonScripts/PlayerInfo.as";

shared class CPPlayerInfo : PlayerInfo
{
    u32 can_spawn_time;

    CPPlayerInfo() { Setup( "", 0, "" ); }
    CPPlayerInfo(string _name, u8 _team, string _default_config ) { Setup( _name, _team, _default_config ); }

    void Setup( string _name, u8 _team, string _default_config )
    {
        PlayerInfo::Setup(_name,_team,_default_config);
        can_spawn_time = 0;
    }
};

//teams

shared class CPTeamInfo : BaseTeamInfo
{
    PlayerInfo@[] spawns;
	s32 LastSpawnTime;

    CPTeamInfo() { super(); }

    CPTeamInfo(u8 _index, string _name)
    {
        super(_index, _name);
		LastSpawnTime = getGameTime();
    }

    void Reset()
    {
        BaseTeamInfo::Reset();
		LastSpawnTime = getGameTime();
        //spawns.clear();
    }
};
