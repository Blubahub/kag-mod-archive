#define SERVER_ONLY;
#include "CTF_Structs.as";

#include "zombies_Technology.as";


shared class Players
{ CTFPlayerInfo@[] list; Players(){} };

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	player.server_setTeamNum(XORRandom(100)+100);

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

void onTick(CRules@ this)
{
	s32 gametime = getGameTime();

	if ((gametime % 31) != 23) // a basic spawn delay
		return;

	for(u8 i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if(player !is null)
		{
			CBlob@ blob = player.getBlob();
			if(blob is null)//if player is dead, then spawn them
			{
				CBlob@ new_blob = server_CreateBlob("builder");

				int team = player.getTeamNum();
				if(team == 255) {// just in case onTick is called before onNewPlayerJoin
					team = XORRandom(100)+100;
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
					new_blob.setPosition(ruins[XORRandom(ruins.length)].getPosition());
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
	SetupScrolls(getRules());
	Players players();

	for(u8 i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ p = getPlayer(i);
		if(p !is null)
		{
			p.server_setTeamNum(XORRandom(100)+100);
			players.list.push_back(CTFPlayerInfo(p.getUsername(),0,""));
		}
	}

	this.set("players", @players);
	this.SetCurrentState(GAME);
}