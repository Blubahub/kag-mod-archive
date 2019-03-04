#define SERVER_ONLY;
#include "CTF_Structs.as";

shared class Players
{ CTFPlayerInfo@[] list; Players(){} };

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	player.server_setTeamNum(100+getNumNeutrals());

	Players@ players;
	this.get("players", @players);
	players.list.push_back(CTFPlayerInfo(player.getUsername(),0,""));
}

void onPlayerRequestTeamChange(CRules@ this, CPlayer@ player, u8 newteam)
{
	player.server_setTeamNum(newteam);
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	CBlob@ blob = player.getBlob();
	if(blob !is null)
		blob.server_Die();

	Players@ players;
	this.get("players", @players);
	if(players !is null) {
		for(s8 i = 0; i < players.list.length; i++) {
			if(players.list[i] !is null && players.list[i].username == player.getUsername()) {
				players.list.removeAt(i);
				i--;
			}
		}
	}
}

void onPlayerDie( CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData )
{
	if(victim is null)
		return;
	victim.set_u32("respawn time", 
		((victim.getTeamNum() >= 100 && victim.getTeamNum() <= 200) ?
		 (getGameTime() + (30*10)) : (getGameTime() + (30*7))));
}

void onTick(CRules@ this)
{
	s32 gametime = getGameTime();

	u32[][] flag_caps = getFlagCapNumbers();

	u32 largest_cap_num = 0;
	u32 team_with_largest_cap_num = 0;

	for(u32 i = 0; i < flag_caps.length; i++)
	{
		for(u32 j = 0; j < flag_caps[i].length; j++)
		{
			u32 x = flag_caps[i][j];
			if(x > largest_cap_num)
			{
				largest_cap_num = x;
				team_with_largest_cap_num = i;
			}	
		}
	}

	if(largest_cap_num >= 10)
	{
		this.SetTeamWon(team_with_largest_cap_num);
		CTeam@ teamWon = this.getTeam(team_with_largest_cap_num);
		if (teamWon !is null)
			this.SetGlobalMessage(teamWon.getName() + " wins the game!");

		this.SetCurrentState(3);
	}

	for(u8 i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if(player !is null)
		{
			CBlob@ blob = player.getBlob();
			if(blob is null && player.get_u32("respawn time") <= getGameTime())//if player is dead, then spawn them
			{
				CBlob@ new_blob = server_CreateBlob("builder");

				int team = player.getTeamNum();
				if(team == 255) {// just in case onTick is called before onNewPlayerJoin
					team = 100+getNumNeutrals();
					player.server_setTeamNum(team);
				}

				if(team < 100)//if player is already on a team, then spawn him at one of his bases
				{
					CBlob@[] flag_bases;
					getBlobsByName("flag_base", @flag_bases);
					Vec2f[] spawns;
					for(uint i = 0; i < flag_bases.length; i++)
					{
						CBlob@ flag_base = flag_bases[i];
						if(flag_base !is null && flag_base.getTeamNum() == team)
						{
							spawns.push_back(flag_base.getPosition());
						}
					}
					new_blob.setPosition(spawns[XORRandom(spawns.length)]);
					
				}
				else//if player is still not on a team
				{
					CBlob@[] ruins;
					getBlobsByName("ruins", @ruins);
					
					if(ruins.length > 0){
						new_blob.setPosition(ruins[XORRandom(ruins.length)].getPosition());		
					} else {
						int newPos = XORRandom(getMap().tilemapwidth) * getMap().tilesize;
						int newLandY = getMap().getLandYAtX(newPos / 8) * 8;
						new_blob.setPosition(Vec2f(newPos, newLandY - 8));
					}
				}
				new_blob.server_setTeamNum(team);
				new_blob.server_SetPlayer(player);
			}
		}
	}
}

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
	printf("Restarting rules script: " + getCurrentScriptName());

	Players players();

	for(u8 i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ p = getPlayer(i);
		if(p !is null)
		{
			p.set_u32("respawn time", getGameTime() + (30*1));
			p.server_setTeamNum(100+getNumNeutrals());
			players.list.push_back(CTFPlayerInfo(p.getUsername(),0,""));
		}
	}
	this.SetGlobalMessage("");
	this.set("players", @players);
	this.SetCurrentState(GAME);
}

u32[][] getFlagCapNumbers()
{
	u32[][] flag_caps;
	for(u8 i = 0; i <= 7; i++)
	{
		u32[] x = {0};
		flag_caps.push_back(x);
	}
	CBlob@[] flag_bases;
	getBlobsByName("flag_base", @flag_bases);
	for(uint i = 0; i < flag_bases.length; i++)
	{
		CBlob@ flag_base = flag_bases[i];
		if(flag_base !is null)
		{
			u32 team = flag_base.getTeamNum();
			u32 caps = flag_base.get_u8("flag_caps");
			if(team > 7)
				continue;
			if(flag_caps[team][0] < caps)
				flag_caps[team][0] = caps;
		}
	}

	return flag_caps;
}

int getNumNeutrals()
{
	int num = 0; 
	for(int i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if(player !is null && player.getTeamNum() >= 100)
		{
			num++;
		}
	}
	return num;
}