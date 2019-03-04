#define SERVER_ONLY;
#include "CTF_Structs.as";
#include "Survival_Structs.as";

shared class Players
{ 
	CTFPlayerInfo@[] list; 
	// PersistentPlayerInfo@[] persistentList; 
	Players(){} 
};

// void GetPersistentPlayerInfo(CRules@ this, string name, PersistentPlayerInfo@ &out info)
// {
	// Players@ players;
	// this.get("players", @players);

	// if (players !is null)
	// {
		// for (u32 i = 0; i < players.persistentList.length; i++)
		// {
			// if (players.persistentList[i].name == name)
			// {
				// @info = players.persistentList[i];
				// return;
			// }
		// }
	// }
// }

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{	
	Players@ players;
	this.get("players", @players);

	// print("length: " + players.persistentList.length);

	if (players is null || player is null) return;
	
	// PersistentPlayerInfo@ info;
	// GetPersistentPlayerInfo(this, player.getUsername(), @info);

	// if (info !is null)
	// {
		// // print("exists");
		// // print("Name: " + info.name + "; Team: " + info.team + "; Coins: " + info.coins);
		
		// player.server_setCoins(info.coins); 
		// player.server_setTeamNum(info.team);
		// player.set_u32("teamkick_time", getGameTime() + info.teamkick_time);
		// player.set_string("classAtDeath","");
		// player.Sync("teamkick_time", true);
		
		// if (player.getBlob() !is null) 
		// {
			// player.getBlob().server_Die(); // Quite hacky
			// player.set_u32("respawn time", 0);
			// player.Sync("respawn time", true);
		// }
	// }
	// else
	// {
		// player.server_setCoins(100);
		// player.set_u32("teamkick_time", 0);
		// player.Sync("teamkick_time", true);
	// }
	
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
			if(players.list[i] !is null && players.list[i].username == player.getUsername())
			{
				players.list.removeAt(i);
				i--;
			}
		}
	
		// PersistentPlayerInfo@ info;
		// GetPersistentPlayerInfo(this, player.getUsername(), @info);
		
		// if (info !is null)
		// {
			// info.team = player.getTeamNum();
			// info.coins = player.getCoins();
			// info.teamkick_time = Maths::Max(0, player.get_u32("teamkick_time") - getGameTime());
		// }
		// else
		// {
			// PersistentPlayerInfo@ newInfo = PersistentPlayerInfo(player.getUsername(), 255);
			// newInfo.team = player.getTeamNum();
			// newInfo.coins = player.getCoins();
			// newInfo.teamkick_time = Maths::Max(0, player.get_u32("teamkick_time") - getGameTime());
			
			// players.persistentList.push_back(newInfo);
		// }
	}
}

void onPlayerRequestSpawn(CRules@ this, CPlayer@ player)
{
	if (player !is null) printf("Request Spawn: " + player.getUsername());
}

void onPlayerDie( CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData )
{
	if(victim is null){
		return;
	}
	victim.set_u32("respawn time", getGameTime() + 30 * (victim.getTeamNum() < this.getTeamsCount() ? 4 : 8));
	
	CBlob@ blob = victim.getBlob();
	if(blob !is null) {
		victim.set_string("classAtDeath",blob.getConfig());
		victim.set_Vec2f("last death position",blob.getPosition());
	}
}

void onTick(CRules@ this)
{
	s32 gametime = getGameTime();
	
	for (u8 i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if(player !is null)
		{
			CBlob@ blob = player.getBlob();
			if (blob is null && player.get_u32("respawn time") <= gametime)
			{
				int team = player.getTeamNum();	
				bool isNeutral = team > 100;

				if(!isNeutral) { // Civilized team spawning
					CBlob@[] bases;
					getBlobsByTag("faction_base", @bases);
					Vec2f[] spawns;
					
					for(uint i=0;i<bases.length;i++) {
						CBlob@ base=bases[i];
						if(base !is null && base.getTeamNum()==team) {
							spawns.push_back(base.getPosition());
						}
					}
					if(spawns.length>0) {
						f32 distance = 100000;
						Vec2f spawnPos = Vec2f(0, 0);
						Vec2f deathPos = player.get_Vec2f("last death position");
						
						for (u32 i = 0; i < spawns.length; i++)
						{
							f32 tmpDistance = Maths::Abs(spawns[i].x - deathPos.x);
						
							// print("Lowest: " + distance + "; Compared against: " + tmpDistance);
						
							if (tmpDistance < distance)
							{
								distance = tmpDistance;
								spawnPos = spawns[i];
							}
						}
						
						string blobType=player.get_string("classAtDeath");
						if(blobType=="royalguard"){
							blobType="knight";
						}
						if(blobType!="builder" && blobType!="knight" && blobType!="archer" && blobType!="sapper"){
							blobType="builder";
						}
						
						CBlob@ new_blob = server_CreateBlob(blobType);
						
						if (new_blob !is null)
						{
							new_blob.setPosition(spawnPos);
							new_blob.server_setTeamNum(team);
							new_blob.server_SetPlayer(player);
						}
					}else{
						isNeutral = true; // In case if the player is respawning while the team has been defeated
					}
				}
				
				if (isNeutral) 
				{ // Bandit scum spawning
					team = 100 + XORRandom(100);
					player.server_setTeamNum(team);
					
					CBlob@[] ruins;
					getBlobsByName("ruins", @ruins);
					getBlobsByName("banditshack", @ruins);
					
					string blobType="peasant";
					if(player.isBot() && player.get_string("classAtDeath")!=""){
						blobType=player.get_string("classAtDeath");
					}
					if(player.getUsername()=="Horace"){
						blobType="chicken";
					}
					CBlob@ new_blob=server_CreateBlob(blobType);

					if (new_blob !is null)
					{
						new_blob.setPosition(ruins[XORRandom(ruins.length)].getPosition());			
						new_blob.server_setTeamNum(team);
						new_blob.server_SetPlayer(player);
					}
				}
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
			p.Sync("teamkick_time", true);
			
			p.server_setCoins(Maths::Max(100, p.getCoins() * 0.5f)); // Half of your fortune is lost by spending it on drugs.
			
			// SetToRandomExistingTeam(this, p);
			p.server_setTeamNum(100 + XORRandom(100));
			players.list.push_back(CTFPlayerInfo(p.getUsername(),0,""));
		}
	}
	//new
	/*for(int playerTeam=0;playerTeam<7;playerTeam++){
		this.set_u32("team"+playerTeam+"_oilAmount",0);
	}*/
	
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

// int getNumNeutrals()
// {
	// int num = 0; 
	// for(int i = 0; i < getPlayerCount(); i++)
	// {
		// CPlayer@ player = getPlayer(i);
		// if(player !is null && player.getTeamNum() >= 100)
		// {
			// num++;
		// }
	// }
	// return num;
// }