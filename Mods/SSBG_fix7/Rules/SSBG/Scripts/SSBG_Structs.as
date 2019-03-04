// management structs

#include "Rules/CommonScripts/BaseTeamInfo.as";
#include "Rules/CommonScripts/PlayerInfo.as";

shared class SSBGPlayerInfo : PlayerInfo
{
    u32 can_spawn_time;
    bool thrownBomb;

    SSBGPlayerInfo() { Setup( "", 0, "" ); }
    SSBGPlayerInfo(string _name, u8 _team, string _default_config ) { Setup( _name, _team, _default_config ); }

    void Setup( string _name, u8 _team, string _default_config )
    {
        PlayerInfo::Setup(_name,_team,_default_config);
        can_spawn_time = 0;
        thrownBomb = false;
    }
};

//teams

shared class SSBGTeamInfo : BaseTeamInfo
{
    PlayerInfo@[] spawns;
    int deaths;

    SSBGTeamInfo() { super(); }

    SSBGTeamInfo(u8 _index, string _name)
    {
        super(_index, _name);
    }

    void Reset()
    {
        BaseTeamInfo::Reset();
        deaths = 0;
        //spawns.clear();
    }
};

shared class SSBG_HUD
{
    //is this our team?
    u8 team_num;
    //exclaim!
    string unit_pattern;
    u8 spawn_time;
    //units
    s16 deaths;
	s16 lives;
    s16 deaths_limit; //here for convenience

    SSBG_HUD() { }
    SSBG_HUD(CBitStream@ bt) { Unserialise(bt); }

    void Serialise(CBitStream@ bt)
    {
        bt.write_u8(team_num);
        bt.write_string(unit_pattern);
        bt.write_u8(spawn_time);
        bt.write_s16(deaths);
		bt.write_s16(lives);
        bt.write_s16(deaths_limit);
    }

    void Unserialise(CBitStream@ bt)
    {
        team_num = bt.read_u8();
        unit_pattern = bt.read_string();
        spawn_time = bt.read_u8();
        deaths = bt.read_s16();
		lives = bt.read_s16();
        deaths_limit = bt.read_s16();
    }

};
