#define SERVER_ONLY;
#include "CTF_Structs.as";
#include "Survival_Structs.as";
#include "HumanoidClasses.as";
#include "HumanoidCommon.as";
#include "LimbsCommon.as";
#include "AbilityCommon.as";


void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	CBlob@ blob = player.getBlob();
	if(blob !is null)
		blob.server_SetPlayer(null);

}


void onTick(CRules@ this)
{
	s32 gametime = getGameTime();

	bool give_lives = false;
	
	float time_length = 15*60*30;
	
	if(gametime % time_length < 10 && !this.hasTag("gave_lives")){
		give_lives = true;
		this.Tag("gave_lives");
	}
	
	if(gametime % time_length >= 10){
		this.Untag("gave_lives");
	}
	
	for(u8 i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if(player !is null)
		{
			if(give_lives){
				if(this.get_u8(player.getUsername()+"_lives") < 3)this.add_u8(player.getUsername()+"_lives",1);
				
				CBitStream params;
				params.write_u16(player.getNetworkID());
				params.write_u8(this.get_u8(player.getUsername()+"_lives"));
				this.SendCommand(this.getCommandID("sync_life"), params);
				
				ConfigFile cfg = ConfigFile("../Cache/player_lives.cfg");
				cfg.add_u16(player.getUsername(), this.get_u8(player.getUsername()+"_lives"));
				cfg.saveFile("player_lives.cfg");
			}
			
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
				
				if(this.get_u8(player.getUsername()+"_lives") <= 0)canSpawn = false;
				
				if(!hasBody && canSpawn){ //Give a 10 second grace period for people to spawn if they die.
				
					int team = player.getTeamNum();	
					
					if(team < 20 || team > 200)team = getUnclaimedTeam();
					player.server_setTeamNum(team);
					
					////removeAbilities(player); //Clear player abilities so they don't remember stuff from their previous life
					CBitStream params;
					params.write_u16(player.getNetworkID());
					this.SendCommand(this.getCommandID("reset_abilities"), params);
					
					CBlob@[] ruins;
					getBlobsByName("ruins", @ruins);
					
					CBlob@ new_blob = server_CreateBlob("humanoid");
					if(new_blob !is null){
						if(this.get_u8(player.getUsername()+"_lives") > 0)this.sub_u8(player.getUsername()+"_lives",1);
						
						CBitStream params;
						params.write_u16(player.getNetworkID());
						params.write_u8(this.get_u8(player.getUsername()+"_lives"));
						this.SendCommand(this.getCommandID("sync_life"), params);
						
						ConfigFile cfg = ConfigFile("../Cache/player_lives.cfg");
						cfg.add_u16(player.getUsername(), this.get_u8(player.getUsername()+"_lives"));
						cfg.saveFile("player_lives.cfg");
						
						int Body = 0;
						
						if(player.getUsername().toLower() == "niiiiii" || XORRandom(1000) == 0)Body = BodyType::Fairy;
						
						setupBody(new_blob,Body,Body,Body,Body,Body,Body);
						
						if(ruins.length > 0){
							new_blob.setPosition(ruins[XORRandom(ruins.length)].getPosition());		
						} else {
							int newPos = XORRandom(getMap().tilemapwidth) * getMap().tilesize;
							int newLandY = getMap().getLandYAtX(newPos / 8) * 8;
							int break_amount = 0;
							while(getMap().isInWater(Vec2f(newPos, newLandY - 8)) && break_amount < 100){
								newPos = XORRandom(getMap().tilemapwidth) * getMap().tilesize;
								newLandY = getMap().getLandYAtX(newPos / 8) * 8;
								break_amount++;
							}
							new_blob.setPosition(Vec2f(newPos, newLandY - 8));
						}
						
						if(Body != BodyType::Fairy)equipNomad(new_blob);
						
						if(player.getUsername().toLower() == "barsukeughen555"){
							equipItemTemp(new_blob, server_CreateBlob("pointed_helmet",new_blob.get_u8("cloth_colour"),new_blob.getPosition()), "head");
						}
						if(player.getUsername().toLower() == "niiiiii"){
							equipItemTemp(new_blob, server_CreateBlob("iw",-1,new_blob.getPosition()), "back");
						}
						
						if(player.getUsername().toLower() == "vamist"){
							for(int i = 0;i < 10;i++)new_blob.server_PutInInventory(server_CreateBlob("bread",-1,new_blob.getPosition()));
						}
						
						new_blob.server_setTeamNum(team);
						new_blob.server_SetPlayer(player);
						new_blob.set_string("player_name",player.getUsername());
						
						new_blob.Init();
					}
				}
			}
		}
	}
}

void onInit(CRules@ this)
{
	//sv_mapcycle_shuffle = false;
	Reset(this);
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void Reset(CRules@ this)
{
	printf("Restarting rules script: " + getCurrentScriptName());
	
	getMap().legacyTileMinimap = false;
	
	this.SetGlobalMessage("");
	this.SetCurrentState(GAME);
	
	server_CreateBlob("survival_music");
	
	/*for(u8 i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if(player !is null)
		{
			
		}
	}*/
}

int getUnclaimedTeam()
{
	int teamnum = 0;
	for(int num = 20; num < 255; num++){
		bool found = false;
		for(int i = 0; i < getPlayerCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			if(player !is null)
			{
				if(player.getTeamNum() == num)found = true;
			}
		}
		if(found == false){
			teamnum = num;
			break;
		}
	}
	return teamnum;
}