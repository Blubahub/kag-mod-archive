#include "RulesCore.as";
#include "TeamColour.as";

#define SERVER_ONLY

void reset(CRules@ this){

	if(getNet().isServer()){

		for(int t = 0; t < 7; t++)
		{
			this.set_s16("tickets_team_"+t, 25);
			this.Sync("tickets_team_"+t, true);
		}
	}
}

void onInit(CRules@ this){
	reset(this);
}

void onRestart(CRules@ this){
	reset(this);
}

void onRender(CRules@ this)
{
	CPlayer@ p = getLocalPlayer();
	if(p !is null)
	{
		int teamNum = p.getTeamNum();
		if(teamNum < 7)
		{
			s16 Tickets = this.get_s16("tickets_team_"+teamNum);

			GUI::DrawText( "Spawns Remaining:", Vec2f(325,getScreenHeight()-100), color_white );
			GUI::DrawText( ""+Tickets, Vec2f(450,getScreenHeight()-100), getTeamColor(teamNum) );
		}
	}
}


void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customData){

	int teamNum = victim.getTeamNum();

	if(teamNum < 7)
	{
		s16 Tickets = this.get_s16("tickets_team_"+teamNum);
		this.set_s16("tickets_team_"+teamNum, Tickets-1);
		this.Sync("tickets_team_"+teamNum, true);
		if(Tickets<=5)
		{
			Sound::Play("/depleted.ogg");
			return;
		}
	}
}

void onTick(CRules@ this)
{
	for(int t = 0; t < 7; t++)
	{
		s16 Tickets = this.get_s16("tickets_team_"+t);
		if(Tickets <=0)
		{
			CBlob@[] facbases;
			getBlobsByName("facbase", @facbases);
			if(!facbases.empty())
			{
				for (uint facs = 0; facs < facbases.length; facs++)
				{
					CBlob@ facbase = facbases[facs];
					if(facbase !is null && facbase.getTeamNum() == t)
					{
						facbase.server_Die();
					}
				}
			}
			
			CBitStream params;
			params.write_u8(t);
			getRules().SendCommand(getRules().getCommandID("killFac"), params);
		}
	}
}