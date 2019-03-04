// management structs

#include "Rules/CommonScripts/BaseTeamInfo.as";
#include "Rules/CommonScripts/PlayerInfo.as";

shared class BVBPlayerInfo : PlayerInfo
{
	u32 can_spawn_time;
	u32 spawn_point;

	BVBPlayerInfo() { Setup("", 0, ""); }
	BVBPlayerInfo(string _name, u8 _team, string _default_config) { Setup(_name, _team, _default_config); }

	void Setup(string _name, u8 _team, string _default_config)
	{
		PlayerInfo::Setup(_name, _team, _default_config);
		can_spawn_time = 0;		
		spawn_point = 0;
	}
};

//teams

shared class BVBTeamInfo : BaseTeamInfo
{
	PlayerInfo@[] spawns;	
	int goals;

	u8 teamnumber;

	BVBTeamInfo() { super(); }

	BVBTeamInfo(u8 _index, string _name)
	{
		super(_index, _name);
	}

	void Reset()
	{
		BaseTeamInfo::Reset();
		goals = 0;
	}
};

shared class BVB_HUD
{
	u8 team_num;
	u8 spawn_time;
	s16 bluegoals;
	s16 redgoals;
	s16 goals_limit;

	BVB_HUD() { }
	BVB_HUD(CBitStream@ bt) { Unserialise(bt); }	

	void Serialise(CBitStream@ bt)
	{
		bt.write_u8(team_num);
		bt.write_u8(spawn_time);
		bt.write_s16(bluegoals);
		bt.write_s16(redgoals);
		bt.write_s16(goals_limit);
	}
	void Unserialise(CBitStream@ bt)
	{
		team_num = bt.read_u8();
		spawn_time = bt.read_u8();
		bluegoals = bt.read_s16();
		redgoals = bt.read_s16();
		goals_limit = bt.read_s16();
	}
};

//shared void NewServe( u8 servingTeam)
//{			
//	CBlob@ blob = getBallServer(servingTeam);
//	if (blob !is null)
//	{
//		CMap@ map = getMap();
//		f32 mapMid = (map.tilemapwidth * map.tilesize)/2;
//		f32 side = (servingTeam == 0 ? mapMid-300.0f : mapMid+300.0f);
//
//		Vec2f servePos = Vec2f(side, map.getLandYAtX(side / map.tilesize) * map.tilesize - 32.0f);
//
//		blob.setPosition(servePos);
//		
//		CBlob@ ball = server_CreateBlob("beachball");
//		if (ball !is null)
//		{						
//			ball.setPosition(blob.getPosition());
//			blob.server_AttachTo(ball, "PICKUP");
//		}
//		getRules().set_bool("Wants New Serve", false);
//	}
//}

shared CBlob@ getGameBall()
{
	CBlob@[] balls;
	getBlobsByTag("volleyball", @balls);
	for (uint i = 0; i < balls.length; i++)
	{
		CBlob @b = balls[i];
		return b;		
	}
	return null;
}

shared CBlob@ getBallServer(int servingTeam)
{
	CBlob@[] players;
	CBlob@[] potentials;

	getBlobsByTag("player", @players);
	for (uint i = 0; i < players.length; i++)
	{		
		if (players[i].getTeamNum() == servingTeam)
		{
			CBlob@ potential = players[i];
			if (potential !is null)
			{ 
				potentials.push_back(potential);	
				
				int randPotential = XORRandom(potentials.length);
				return potentials[randPotential];
			}	
			else
			{				
				getRules().set_u8("serve delay", 2*30);
				CBlob@ b = getGameBall();
				if (b !is null)
				{b.server_Die();}				
			}				
		}
	}
	return null;
}
