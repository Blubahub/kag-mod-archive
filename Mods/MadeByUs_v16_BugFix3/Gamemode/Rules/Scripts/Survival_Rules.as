#define SERVER_ONLY;
#include "CTF_Structs.as";
#include "Survival_Structs.as";


void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{	

}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	CBlob@ blob = player.getBlob();
	if(blob !is null)
		blob.server_SetPlayer(null);

}

void onPlayerDie( CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData )
{

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
			if (blob is null)
			{
				
				bool hasBody = false;
				
				CBlob@[] humans;
				getBlobsByName("humanoid", @humans);
				
				for(int j = 0; j < humans.length; j++)
				{
					CBlob @human = humans[j];
					if(human.getPlayer() is null)
					if(human.get_string("player_name") == player.getUsername())
					if(human.hasTag("soul")){
						human.server_SetPlayer(player);
						hasBody = true;
						break;
					}
				}
				
				bool canSpawn = true;
				
				CBlob @roster = getRoster();
				if(roster !is null){
					//print("Checking roster for player:"+player.getUsername());
					if(roster.hasTag(player.getUsername()))canSpawn = false;
					//if(!canSpawn)print("Player '"+player.getUsername()"' has already spawned.");
					//else print("Player '"+player.getUsername()"' hasn't already spawned.");
				}
				
				if(!hasBody && (canSpawn || getGameTime() < 30*10)){ //Give a 10 second grace period for people to spawn if they die.
				
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
			} else {
				if(blob.getName() == "humanoid" && !blob.hasTag("ghost")){
					CBlob @roster = getRoster();
					if(roster !is null){
						roster.Tag(player.getUsername());
					}
				}
			}
		}
	}
}

CBlob@ getRoster(){
	CBlob@[] roster;
	getBlobsByName("roster", @roster);
	
	if(roster.length > 0){
		return roster[0];
	} else {
		print("Roster didn't exist, creating roster.");
		return server_CreateBlob("roster");
	}
	return null;
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
	
	
	this.SetGlobalMessage("");
	this.SetCurrentState(GAME);
	
	server_CreateBlob("survival_music");
	print("Made Roster.");
	server_CreateBlob("roster");
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