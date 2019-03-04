#include "RulesCore.as";
#include "TeamColour.as";

#include "tickets.as";

int redTicketsLeft;
int blueTicketsLeft;

s16 ticketsPerTeam;
s16 ticketsPerPlayer;
s16 ticketsPerPlayerInTeam0;

bool unevenTickets;
s16 numBlueTickets;
s16 numRedTickets;

s16 numBlueTicketsPerPlayerInTeam;
s16 numRedTicketsPerPlayerInTeam;
s16 numBlueTicketsPerPlayerInGame;
s16 numRedTicketsPerPlayerInGame;
bool startOnMap = false;

int8 playerCount;
bool synced = false;
u8 redColour;
u8 greenColour;
u8 blueColour;

void reload(CRules@ this){

	if(getNet().isServer()){
		//string configstr = "../Mods/tickets/Rules/CommonScripts/tickets/tickets.cfg";
		string configstr = "../Mods/LeosCTF/Tickets/settings/tickets.cfg";
		if (this.exists("ticketsconfig")){
			configstr = this.get_string("ticketsconfig");
		}
		ConfigFile cfg = ConfigFile( configstr );
		
		ticketsPerTeam = cfg.read_s16("ticketsPerTeam",40);
		ticketsPerPlayer = cfg.read_s16("ticketsPerPlayer",0);
		ticketsPerPlayerInTeam0 = cfg.read_s16("ticketsPerPlayerInTeam0",0);
		
		numBlueTickets = cfg.read_s16("numBlueTickets",0);
		numRedTickets = cfg.read_s16("numRedTickets",0);

		numBlueTicketsPerPlayerInTeam = cfg.read_s16("numBlueTicketsPerPlayerInTeam",0);
		numRedTicketsPerPlayerInTeam = cfg.read_s16("numRedTicketsPerPlayerInTeam",0);
		numBlueTicketsPerPlayerInGame = cfg.read_s16("numBlueTicketsPerPlayerInGame",0);
		numRedTicketsPerPlayerInGame = cfg.read_s16("numRedTicketsPerPlayerInGame",0);
		startOnMap = cfg.read_bool("startOnMap");
		//cfg.add_bool("startOnMap",true);
		//cfg.saveFile("tickets.cfg");	
		//print(startOnMap+"");
		if(startOnMap)
		{
			this.set_bool("TicketsOn?",true);
			this.Sync("TicketsOn?",true);
		}
		
		RulesCore@ core;
		this.get("core", @core);
		if(core is null) print("core is null!!!");
		

		s16 redTickets=ticketsPerTeam;
		s16 blueTickets=ticketsPerTeam;

		int playersInGame=getPlayersCount();

		blueTickets+=(ticketsPerPlayer*playersInGame);
		redTickets+=(ticketsPerPlayer*playersInGame);
		blueTickets+=(ticketsPerPlayerInTeam0*(core.getTeam(0).players_count));
		redTickets+=(ticketsPerPlayerInTeam0*(core.getTeam(0).players_count));

		blueTickets+=numBlueTickets;
		redTickets+=numRedTickets;
		blueTickets+=(numBlueTicketsPerPlayerInTeam*core.getTeam(0).players_count);
		redTickets+=(numRedTicketsPerPlayerInTeam*core.getTeam(1).players_count);
		blueTickets+=(numBlueTicketsPerPlayerInGame*playersInGame);
		redTickets+=(numRedTicketsPerPlayerInGame*playersInGame);

		this.set_s16("redTickets", redTickets);
		this.set_s16("blueTickets", blueTickets);
		this.Sync("redTickets", true);
		this.Sync("blueTickets", true);
	}
	else
	{
		synced = false;
		redColour = 0;
		greenColour = 0;
		blueColour = 0;
	}

}

void onInit(CRules@ this){
	reload(this);
}

void onRestart(CRules@ this){
	reload(this);
}

void onRender(CRules@ this){

	CPlayer@ p = getLocalPlayer();
	if (p is null || !p.isMyPlayer()) { return; }

	/*if(p.get_s32("timeToShowMessage") > getGameTime())
	{
		if(!synced)
		{
			playerCount = this.get_u8("playersBeforePickup");
			redColour = this.get_u8("redColour");
			greenColour = this.get_u8("greenColour");
			blueColour = this.get_u8("blueColour");
		}
		if(playerCount > getPlayersCount())
			GUI::DrawText("Can not pick up flag until there are " + playerCount + " Players", Vec2f(345,(getScreenHeight()-150) - 70.0f + Maths::Sin(getGameTime() / 3.0f) * 5.0f), SColor(255,redColour,greenColour,blueColour) );
	}*/

	if(this.get_bool("TicketsOn?"))
	{
		if(this.get_u8("TicketsJustOn") == 1)
		{
			this.set_u8("TicketsJustOn",0);
			client_AddToChat("An admin has just turned tickets on!", SColor(255,225,0,225));
			reload(this);
		}
		s16 blueTickets=0;
		s16 redTickets=0;

		blueTickets=this.get_s16("blueTickets");
		redTickets=this.get_s16("redTickets");

		GUI::DrawText( "Spawns Remaining:", Vec2f(345,getScreenHeight()-100), color_white );
		GUI::DrawText( ""+redTickets, Vec2f(430,getScreenHeight()-80), getTeamColor(1) );		//shows tickets just above bottom left HUD
		GUI::DrawText( ""+blueTickets, Vec2f(380,getScreenHeight()-80), getTeamColor(0) );
	}
	else if(this.get_u8("TicketsJustOn") == 2)
	{
		this.set_u8("TicketsJustOn",0);
		client_AddToChat("An admin has just turned tickets off!", SColor(255,225,0,225));
	}
}


void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customData){
	if(this.get_bool("TicketsOn?"))
	{
		int teamNum=victim.getTeamNum();
		checkGameOver(this, teamNum);
		if(killer is null)
		{
			victim.Tag("Suicide");
		}

		if(this.isMatchRunning()){
			int numTickets=0;

			if(teamNum==0){
				numTickets=this.get_s16("blueTickets");
			}else{
				numTickets=this.get_s16("redTickets");
			}
			if(numTickets<=0){          //play sound if running/run out of tickets
				Sound::Play("/depleted.ogg");
				return;
			}else if(numTickets<=5){
				Sound::Play("/depleting.ogg");
				return;
			}
		}
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	if(getNet().isServer())
	{
		s16 blueTickets=0;
		s16 redTickets=0;

		blueTickets=this.get_s16("blueTickets");
		redTickets=this.get_s16("redTickets");

		blueTickets+=ticketsPerPlayer;
		redTickets+=ticketsPerPlayer;
		this.set_s16("redTickets", redTickets);
		this.set_s16("blueTickets", blueTickets);
		this.Sync("redTickets", true);
		this.Sync("blueTickets", true);
	}
}

void onPlayerLeave( CRules@ this, CPlayer@ player ){

	/*if(getNet().isServer())
	{
		s16 blueTickets=0;
		s16 redTickets=0;

		blueTickets=this.get_s16("blueTickets");
		redTickets=this.get_s16("redTickets");

		blueTickets+=-ticketsPerPlayer;
		redTickets+=-ticketsPerPlayer;
		this.set_s16("redTickets", redTickets);
		this.set_s16("blueTickets", blueTickets);
		this.Sync("redTickets", true);
		this.Sync("blueTickets", true);
	}*/
	CBlob @blob = player.getBlob();
	if (blob !is null && !blob.hasTag("dead"))
	{
		int teamNum=player.getTeamNum();
		checkGameOver(this, teamNum);
	}

}

void onPlayerChangedTeam( CRules@ this, CPlayer@ player, u8 oldteam, u8 newteam ){
	checkGameOver(this, oldteam);
}