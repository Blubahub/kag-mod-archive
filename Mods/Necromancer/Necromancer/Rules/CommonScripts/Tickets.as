#include "RulesCore.as";
#include "NECRO_Structs";

shared int ticketsRemaining(CRules@ this, int team)
{
	return this.get_s16("ticketsTeam"+team);
}

shared int decrementTickets(CRules@ this, int team)
{			//returns 1 if no tickets left, 0 otherwise
	s16 numTickets = this.get_s16("ticketsTeam"+team);
	if(numTickets<=0)return 1;
	numTickets--;
	this.set_s16("ticketsTeam"+team, numTickets);
	this.Sync("ticketsTeam"+team, true);
	return 0;
}

shared bool isPlayersLeft(CRules@ this, int team)
{			//checks if spawning players or alive players 
    CBlob@[] player_blobs;
    getBlobsByTag( "player", @player_blobs );
 
    for(uint i=0; i<player_blobs.length; i++ ){
        if (player_blobs[i] !is null && player_blobs[i].getTeamNum()==team && !player_blobs[i].hasTag("dead")){
            return true;
        }
    }
    return false;
}

shared bool checkGameOver(CRules@ this, int teamNum)
{
	if (teamNum == 255) return false;
	if (teamNum != 0 && teamNum != 1) return false;
	if (this.get_s16("ticketsTeam"+teamNum)>0) return false;
	if(isPlayersLeft(this, teamNum)) return false;
	if(!getRules().isMatchRunning()) return false;
	this.SetTeamWon( teamNum == 0 ? 1 : 0 );
	this.SetCurrentState(GAME_OVER);
	this.SetGlobalMessage( this.getTeam(teamNum == 1 ? 0 : 1).getName() + " won the game!" );
	return true;
}

