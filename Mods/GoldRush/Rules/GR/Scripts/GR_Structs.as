// management structs

#include "Rules/CommonScripts/PlayerInfo.as";
#include "BaseTeamInfo.as";
    
namespace ItemFlag {

const u32 Builder = 0x01;
const u32 Archer = 0x02;
const u32 Knight = 0x04;

}

shared class GRPlayerInfo : PlayerInfo
{
    u32 can_spawn_time;
	
	u32 spawn_point;
	
	u32 items_collected;
	
    GRPlayerInfo() { Setup( "", 0, "" ); }
    GRPlayerInfo(string _name, u8 _team, string _default_config ) { Setup( _name, _team, _default_config ); }

    void Setup( string _name, u8 _team, string _default_config )
    {
        PlayerInfo::Setup(_name,_team,_default_config);
        can_spawn_time = 0;
        spawn_point = 0;
        
        items_collected = 0;
    }
};

//teams

shared class GRTeamInfo : BaseTeamInfo
{
    PlayerInfo@[] spawns;

    GRTeamInfo() { super(); }

    GRTeamInfo(u8 _index, string _name)
    {
        super(_index, _name);
    }

    void Reset()
    {
        BaseTeamInfo::Reset();
        //spawns.clear();
    }

};