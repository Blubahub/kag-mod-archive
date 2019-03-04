/*
MOD name: Ranks
Author: SnIcKeRs
*/
#define CLIENT_ONLY

#include "rules_Commands.as"
#include "commonStats.as"

void showStats(string username, u32 kills, u32 deaths)
{
	f32 kd = getKD(kills, deaths);
	string showMessage = 
	"-----------"+username+"-----------"
	+"\nKills: "+ kills 
	+"\nDeaths: "+ deaths
	+"\nRank points: " + getPoints(kills, deaths)
	+"\n-----------"+username+"-----------";

	client_AddToChat(showMessage, COLOR);
}

void onCommand( CRules@ this, u8 cmd, CBitStream @params )
{

	if(cmd == this.getCommandID("noplayer"))
	{
		CPlayer@ cmdPlayer = getPlayerByNetworkId(params.read_u16());
	    if(cmdPlayer !is getLocalPlayer()){ return; }//check this player requesting stats command

	    client_AddToChat("There is not player "+ params.read_string(), COLOR);
	}
	else if(cmd == this.getCommandID("stats") or cmd == this.getCommandID("offlinestats"))
	{
		u32 deaths = 0, kills = 0;
		string username;

		CPlayer@ cmdPlayer = getPlayerByNetworkId(params.read_u16());

		if(cmd == this.getCommandID("offlinestats"))
	    {
	    	username = params.read_string();
	    }
	    else
	    {
	    	CPlayer@ rankPlayer =  getPlayerByNetworkId(params.read_u16());
	    	username = rankPlayer.getUsername();  
	    }
	     
	    kills = params.read_u32();
		deaths = params.read_u32();	  

		CPlayer@ localPlayer = getLocalPlayer();
	    if(cmdPlayer !is localPlayer){ return; }//check this player requesting stats command

	    showStats(username, kills, deaths);
	}
	else if(cmd == this.getCommandID("top"))
	{
		string topmsg = params.read_string();
		client_AddToChat(topmsg, COLOR);
	}
}