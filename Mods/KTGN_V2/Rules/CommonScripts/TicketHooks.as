#include "RulesCore.as";
#include "TeamColour.as";

#include "Tickets.as";

void reset(CRules@ this)
{
	if(getNet().isServer())
	{
	    ConfigFile cfg;
	    if (!cfg.loadFile("../Mods/Necromancer/Rules/NECRO/custom_necro_vars.cfg")){
	        cfg.loadFile("../Mods/Necromancer/Rules/NECRO/necro_vars.cfg");
	    }
	    int teamsCount = this.getTeamsCount();
	    RulesCore@ core;
		this.get("core", @core);
	    for (uint i=0; i<teamsCount; i++)
	    {
	    	s16 tickets = cfg.read_s16("ticketsPerPlayerTeam"+i,5);
	    	this.set_bool("displayTicketsTeam"+i, tickets>0);
	    	this.set_s16("ticketsTeam"+i, tickets*getTeamSize(core.teams, i));
	    	if (getTeamSize(core.teams, i) == 0 )
	    		this.set_s16("ticketsTeam"+i, tickets);	    	
			this.Sync("displayTicketsTeam"+i, true);
			this.Sync("ticketsTeam"+i, true);
	    }
	}
}

void onInit(CRules@ this)
{
	reset(this);
}

void onRestart(CRules@ this)
{
	reset(this);
}

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customData)
{
	int teamNum=victim.getTeamNum();
        checkGameOver(this, teamNum);

    if(this.isMatchRunning()){
       	int numTickets=this.get_s16("ticketsTeam"+teamNum);
       	if(numTickets<=0){
               	Sound::Play("/depleted.ogg");
               	return;
       	}else if(numTickets<=5){
               	Sound::Play("/depleting.ogg");
               	return;
       	}
    }
}

void onPlayerLeave( CRules@ this, CPlayer@ player )
{
	CBlob @blob = player.getBlob();
	if (blob !is null && !blob.hasTag("dead"))
	{
		int teamNum=player.getTeamNum();
        	checkGameOver(this, teamNum);
        }
}

void onPlayerChangedTeam( CRules@ this, CPlayer@ player, u8 oldteam, u8 newteam )
{
	checkGameOver(this, oldteam);
}