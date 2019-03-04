
#include "RosterCommon.as";

void onInit(CBlob @ this){

	print("Roster loaded");
	
	for(int i = 0; i < getPlayerCount(); i += 1){
		CPlayer @player = getPlayer(i);
		if(player !is null){
			addPlayerToRoster(this,player);
		}
	}
}

void onNewPlayerJoin( CRules@ this, CPlayer@ player ){

	if(getRoster() !is null)addPlayerToRoster(getRoster(),player);

}



void onTick(CBlob @ this){

}