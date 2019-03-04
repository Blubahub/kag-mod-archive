#define SERVER_ONLY;
#include "CTF_Structs.as";
#include "Survival_Structs.as";

shared class Players
{ 
	CTFPlayerInfo@[] list; 
	PersistentPlayerInfo@[] persistentList; 
	Players(){} 
};

void GetPersistentPlayerInfo(CRules@ this, string name, PersistentPlayerInfo@ &out info)
{
	Players@ players;
	this.get("players", @players);

	if (players !is null)
	{
		for (u32 i = 0; i < players.persistentList.length; i++)
		{
			if (players.persistentList[i].name == name)
			{
				@info = players.persistentList[i];
				return;
			}
		}
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{	
	Players@ players;
	this.get("players", @players);

	// print("length: " + players.persistentList.length);

	if (players is null || player is null) return;
	
	PersistentPlayerInfo@ info;
	GetPersistentPlayerInfo(this, player.getUsername(), @info);

	if (info !is null)
	{
		// print("exists");
		// print("Name: " + info.name + "; Team: " + info.team + "; Coins: " + info.coins);
		
		player.server_setCoins(info.coins); 
		player.server_setTeamNum(info.team);
		player.set_u32("teamkick_time", getGameTime() + info.teamkick_time);
		player.Sync("teamkick_time", true);
		if(info.spawned)player.Tag("spawned");
		
		if (player.getBlob() !is null) 
		{
			player.getBlob().server_Die(); // Quite hacky
			player.set_u32("respawn time", 0);
		}
	}
	else
	{
		player.server_setCoins(100);
	}
	
	players.list.push_back(CTFPlayerInfo(player.getUsername(), 0, ""));
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
	
	if (players !is null) 
	{
		for(s8 i = 0; i < players.list.length; i++) {
			if(players.list[i] !is null && players.list[i].username == player.getUsername()) {
				players.list.removeAt(i);
				i--;
			}
		}
	
		PersistentPlayerInfo@ info;
		GetPersistentPlayerInfo(this, player.getUsername(), @info);
		
		if (info !is null)
		{
			info.team = player.getTeamNum();
			info.coins = player.getCoins();
			info.teamkick_time = Maths::Max(0, player.get_u32("teamkick_time") - getGameTime());
			info.spawned = player.hasTag("spawned");
		}
		else
		{
			PersistentPlayerInfo@ newInfo = PersistentPlayerInfo(player.getUsername(), 255);
			newInfo.team = player.getTeamNum();
			newInfo.coins = player.getCoins();
			newInfo.spawned = player.hasTag("spawned");
			newInfo.teamkick_time = Maths::Max(0, player.get_u32("teamkick_time") - getGameTime());
			
			players.persistentList.push_back(newInfo);
		}
	}
}

void onPlayerDie( CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData )
{
	if (victim is null) return;
	victim.set_u32("respawn time", getGameTime() + 30 * (victim.getTeamNum() < this.getTeamsCount() ? 4 : 8));
}

void onTick(CRules@ this)
{
	s32 gametime = getGameTime();

	for(u8 i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if(player !is null)
		{
			CBlob@ blob = player.getBlob();
			if (blob is null && !player.hasTag("spawned"))
			{
				player.Tag("spawned");
				
				int team = player.getTeamNum();	
				
				team = 100 + XORRandom(100);
				player.server_setTeamNum(team);
				
				CBlob@[] ruins;
				getBlobsByName("ruins", @ruins);
				
				CBlob@ new_blob = server_CreateBlob("humanoid");
				
				if(ruins.length > 0){
					new_blob.setPosition(ruins[XORRandom(ruins.length)].getPosition());		
				} else {
					int newPos = XORRandom(getMap().tilemapwidth) * getMap().tilesize;
					int newLandY = getMap().getLandYAtX(newPos / 8) * 8;
					new_blob.setPosition(Vec2f(newPos, newLandY - 8));
				}
				
				new_blob.server_setTeamNum(team);
				new_blob.server_SetPlayer(player);
			}
		}
	}
}

void onInit(CRules@ this)
{
	sv_mapcycle_shuffle = false;
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
			p.set_u32("respawn time", getGameTime() + (30 * 1));
			p.set_u32("teamkick_time", 0);
			p.server_setCoins(Maths::Max(100, p.getCoins() * 0.5f)); // Half of your fortune is lost by spending it on drugs.
			p.Untag("spawned");
			// SetToRandomExistingTeam(this, p);
			p.server_setTeamNum(100 + XORRandom(100));
			players.list.push_back(CTFPlayerInfo(p.getUsername(),0,""));
		}
	}
	
	this.SetGlobalMessage("");
	this.set("players", @players);
	this.SetCurrentState(GAME);
	
	server_CreateBlob("survival_music");
}



// u32[][] getFlagCapNumbers()
// {
	// u32[][] flag_caps;
	// for(u8 i = 0; i <= 7; i++)
	// {
		// u32[] x = {0};
		// flag_caps.push_back(x);
	// }
	// CBlob@[] flag_bases;
	// getBlobsByName("flag_base", @flag_bases);
	// for(uint i = 0; i < flag_bases.length; i++)
	// {
		// CBlob@ flag_base = flag_bases[i];
		// if(flag_base !is null)
		// {
			// u32 team = flag_base.getTeamNum();
			// u32 caps = flag_base.get_u8("flag_caps");
			// if(team > 7)
				// continue;
			// if(flag_caps[team][0] < caps)
				// flag_caps[team][0] = caps;
		// }
	// }

	// return flag_caps;
// }

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