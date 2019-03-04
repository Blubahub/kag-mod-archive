//Battle of Wizards gamemode extension logic

#include "BoHCommon.as";
#include "RulesCore.as";
#include "Explosion.as";
#include "MakeScroll.as";
#include "TradingCommon.as";


/** TODO:
		
		
		
	pimp orb guidance (COMPANION ORB )
	siege eq derp protected
	scrolls (bison, boom, dirtball,	16ton
	fix dblclick on menu
	fix scrolls
	fix scroll actvt in else hands
	pimp research scr
	tweak wiz knocked

	fix wiz giu desync 
add spike playerOwnedDamage


?	add attack while mounted
?	drawtext notifications module 
?	wiz time depend on player count
:/	add console commands
:/	add score on kill door
	
	x	fix team balance
	xx wiz halps (bad icon?)
	xx fix arr time desync/fuckup?
	xxx fix arrive while chosing
	xxx switch wiz name if unused 
	xxx wiz cant cap
	xxx wiz pick class ffs
	xxx wiz announcement
	xxz wiz tele nerf
	xxx wiz no food
	xxx wiz pickup pos
	xxx wiz shoot while bison
	xxx scoreboard reset onrestart
	xxx score formula 
	xxx wiz no points from kills
	xxx	add explaining messages spam
	xxx fix no wiz name reset on restart
	xxx fix hardcoded time hint
	xxx !time fix beggining
	xxx time has passed borken
	xxx remove dinghy
	xxx fix no wiz announcement
	xxx arr mods
	XXX	fix score reset on wiz die
	xx	buy seeds
	xxx add wiz kill icon?
	xxx	WIZ 5 PIONTS
	xxx add hint on join ?
	xxx add gamemode hud lol!!
	xxx fix orb fuckup
	xxx	tap to swap class
	xxx	fletch logs
	xxx	wiz immu to wiz explosion
	xxx	wiz hp bar hud
	xxx tap to swap block
	
	--dropped--
	x wiz boom on gib multiplayer fucked up?
	!go_wizard ?
*/

const string[] helps = {
	"Every "+WIZARD_DELAY_MINUTES+" minutes a player with best score can change class to wizard.",
	"Wizard shoots orbs, teleports and heal over time, but can't take halls or use food or hearts.",
	"Score formula is (KILLS * 2 - DEATHS).",
	"Wizard can shoot orbs down to propel himself up, like jetpack.",
	"Say !time to see when will wizards arrive.",
	"Slaying a wizard gives you 5 kills instead of 1.",
	"Every "+WIZARD_DELAY_MINUTES+" minutes a player with best score can change class to wizard.",
	"Be careful while tring to kill wizard. He explodes on death and drops gold and scrolls.",
	"Wizard can teleport a whole boat with all team mates inside (as long as they can hold on tight enough).",
	"Press F1 to toggle hints.",
	"When the wizard arrives and you are the best player you have 1 minute to change class to wizard. After that next player is chosen.",
};
int helpsCounter;

bool gameStarted;

void onInit( CRules@ this ){
	onRestart(this);
}

void onRestart( CRules@ this ){
	this.set_string("blue_hero_name", "");
	this.set_string( "red_hero_name", "");		
	this.set_u32("blue_hero_arrive", 0);
	this.set_u32( "red_hero_arrive", 0);
	
	this.set_bool("notify_needed", false);
	gameStarted = false;
}

void onPlayerLeave( CRules@ this, CPlayer@ player ){
	CBlob@ blob = player.getBlob();
	if (blob !is null && blob.getName() == "wizard"){
		int team = player.getTeamNum();
		this.set_u32((team==0?"blue":"red")+"_hero_arrive", getGameTime()+WIZARD_DELAY+1);
		this.set_string((team==0?"blue":"red")+"_hero_name", "");
	}
}

// add seed to trader
void onBlobCreated( CRules@ this, CBlob@ blob ){
	if (blob.getName() == "trader"){
		//AddIconToken( "$seed$", "TradingMenuGeneric.png", Vec2f(72,24), 0 );
		TradeItem@ item = addTradeItem( blob, "Seed", 0, true,	"$tree_pine$", "seed tree_pine", "A seed to start a mighty forest." );
		AddRequirement( item.reqs, "blob", "mat_wood", "Wood", 500 );
	}
}

bool onServerProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player ){
	if (text_in == "!now" && player.isMod()) {
		if (this.get_u32("blue_hero_arrive") != 0){
			this.set_u32("blue_hero_arrive", getGameTime()+60);
			this.Sync("blue_hero_arrive", true);
		}
		if (this.get_u32("red_hero_arrive") != 0){
			this.set_u32("red_hero_arrive", getGameTime()+60);
			this.Sync("red_hero_arrive", true);
		}
	}
	return true;
}

bool onClientProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player ){
	if ((text_in == "!time" || text_in == "!state") && player.isMyPlayer()){
		if(this.getCurrentState() != GAME){
			client_AddToChat("Game not started yet.", SColor(255, 127, 0, 127));
			return true;
		}
		const u32 time = getGameTime();
		
		u32[] arriveTimes;
		arriveTimes.push_back(this.get_u32("blue_hero_arrive"));
		arriveTimes.push_back(this.get_u32( "red_hero_arrive"));
	 
		for (uint i = 0; i < arriveTimes.length; i++) {
			int delta = arriveTimes[i]-time;
			if(arriveTimes[i] != 0){ //arriving
				if(this.get_string((i==0?"blue":"red")+"_hero_name") == ""){
					client_AddToChat((i==0?"Blue":"Red")+" wizard arrives in "+(delta/MINUTE)+ " minutes.", SColor(255, 127, 0, 127));
				} else {
					client_AddToChat((i==0?"Blue":"Red")+" wizard has arrived.", SColor(255, 127, 0, 127));
				}
			} else {
				client_AddToChat((i==0?"Blue":"Red")+" wizard is alive.", SColor(255, 127, 0, 127));		
			}
		}
	}

	return true;
}

void onRender( CRules@ this ){
	CPlayer@ player = getLocalPlayer();
	
	if(player !is null && this.get_bool("notify_needed")){//&& this.get_string((player.getTeamNum()==0?"blue":"red")+"_hero_name") == player.getUsername()){
		const u32 time = getGameTime()+1;
		const u32 notifyTime = this.get_u32("notify_time");
		if(notifyTime < time 
			&& time < notifyTime + 10*getTicksASecond()
			&& this.get_string((player.getTeamNum()==0?"blue":"red")+"_hero_name") == player.getUsername())
		{
			if(notifyTime+10 == time){
				Sound::Play("FanfareLose.ogg");
				
			}
			Vec2f middle(getScreenWidth()/2.0f,  120.0f );
			GUI::DrawText( "You have proved yourself worthy to become a wizard.\nYou have 1 minute to change class.",
				Vec2f(middle.x - 140.0f, middle.y), Vec2f(middle.x + 140.0f, middle.y+60.0f), color_black, true, true, true );
		} //else if(notifyTime+CHANGE_PLAYER_DELAY < time 
			// && time < notifyTime+CHANGE_PLAYER_DELAY + 10*getTicksASecond()
			// && player.lastBlobName != "wizard")
		// {
			// Vec2f middle(getScreenWidth()/2.0f,  120.0f );
			// GUI::DrawText( "The time has passed.",
				// Vec2f(middle.x - 140.0f, middle.y), Vec2f(middle.x + 140.0f, middle.y+60.0f), color_black, true, true, true );	
		// }
	}
}

void notify(string name){
	CPlayer@ player = getPlayerByUsername(name);
	CRules@ rules = getRules();
	rules.set_u32("notify_time", getGameTime());
	rules.SyncToPlayer("notify_time", player);
	rules.set_bool("notify_needed", true);
	rules.SyncToPlayer("notify_needed", player);
	// print("notify "+name);
}

int getScore(PlayerInfo@ player){
	CPlayer@ p = getPlayerByUsername(player.username);
	if(p !is null){
		return p.getScore();
	}
	return -10000;
}

bool isFeg(string s){return false;}
void setupWizard(uint teamNum, string prevCandidate=""){
	CRules@ rules = getRules();
	RulesCore@ core;
	rules.get("core", @core);
	PlayerInfo@[] players = core.players;
	
	PlayerInfo@ prevBstPleb;
	PlayerInfo@ prevBstFeg;
	if(prevCandidate != ""){
		if(isFeg(prevCandidate)){
			@prevBstFeg = core.getInfoFromName(prevCandidate);
		} else {
			@prevBstPleb = core.getInfoFromName(prevCandidate);
		}
	}
	
	PlayerInfo@ bstPleb;
	PlayerInfo@ bstFeg;
	
	for (uint i = 0; i < players.length; i++){
		if(players[i].team == teamNum){
			int score = getScore(players[i]);
			if(isFeg(players[i].username)){
				if((prevBstFeg is null 
						|| (prevBstFeg.username != players[i].username 
							&& getScore(prevBstFeg) >= score))
					&& (bstFeg is null	|| score > getScore(bstFeg)	)){
					@bstFeg = players[i];
				}
			} else {
				if((prevBstPleb is null 
						|| (prevBstPleb.username != players[i].username 
							&& getScore(prevBstPleb) >= score))
					&& (bstPleb is null	|| score > getScore(bstPleb)	)){
					@bstPleb = players[i];
				}
			}
		}
	}
	
	if(bstFeg !is null){
		@bstPleb = bstFeg;
	}
		
	if(bstPleb !is null){
		rules.set_string((teamNum==0?"blue":"red")+"_hero_name", bstPleb.username);
		rules.set_u32((teamNum==0?"blue":"red")+"_hero_arrive", getGameTime()+CHANGE_PLAYER_DELAY);
		rules.Sync((teamNum==0?"blue":"red")+"_hero_name", true);
		rules.Sync((teamNum==0?"blue":"red")+"_hero_arrive", true);
		notify(bstPleb.username);
		
		// print(bstPleb.username);
		// print(prevCandidate);
		// print("");
		
	} else if(prevCandidate != ""){ //we've cycled through all players lawl?
		setupWizard(teamNum, ""); //try again
	} else { //empty team
		rules.set_u32((teamNum==0?"blue":"red")+"_hero_arrive", getGameTime()+WIZARD_DELAY+1);
		rules.Sync((teamNum==0?"blue":"red")+"_hero_arrive", true);
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	if (player.isMyPlayer()) 
		client_AddToChat("Welcome to Battle of Wizards server. In this gamemode every "+WIZARD_DELAY_MINUTES+" minutes a player with best score in team can change class to a Wizard.", SColor(255, 0, 127, 127));
}

void onTick( CRules@ this ){
	const u32 time = getGameTime();
	
	u32[] arriveTimes;
	arriveTimes.push_back(this.get_u32("blue_hero_arrive"));
	arriveTimes.push_back(this.get_u32( "red_hero_arrive"));
 
	for (uint i = 0; i < arriveTimes.length; i++) {
		int delta = arriveTimes[i]-time;
		if(delta < 0){
			arriveTimes[i] = this.get_u32((i==0?"blue":"red")+"_hero_arrive");
		}
		
		if(arriveTimes[i] != 0){ //arriving
			if((delta % ANNOUNCEMENT_INTERVAL) == 0){
				if(this.get_string((i==0?"blue":"red")+"_hero_name") == ""){
					if(delta == 0){ //the time has come
						client_AddToChat((i==0?"Blue":"Red")+" wizard has arrived!", SColor(255, 127, 0, 127));
					} else {
						client_AddToChat((i==0?"Blue":"Red")+" wizard arrives in "+(delta/MINUTE)+ " minutes.", SColor(255, 127, 0, 127));
					}
				}
				if(delta == 0 && getNet().isServer()){ //the time has come
					setupWizard(i, this.get_string((i==0?"blue":"red")+"_hero_name"));
				}
			}
		} else {
			if(this.getCurrentState() == GAME && !gameStarted){ //game starting
				this.set_u32("blue_hero_arrive", time+WIZARD_DELAY*FIRST_WAVE_MULTIPLIER-1);
				this.set_u32( "red_hero_arrive", time+WIZARD_DELAY*FIRST_WAVE_MULTIPLIER-1);
				gameStarted = true;
				client_AddToChat("Wizards arrive in "+(WIZARD_DELAY*FIRST_WAVE_MULTIPLIER/MINUTE)+ " minutes.", SColor(255, 127, 0, 127));	
			}
		}
	}
	if(time % (2*MINUTE) == 0){ //spam help msgs
		client_AddToChat(helps[helpsCounter++ % helps.length], SColor(255, 127, 0, 127));
	}
}

void onPlayerDie( CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customData ){
	if (victim !is null ){
		CBlob@ blob = victim.getBlob();
		if (blob !is null && blob.getName() == "wizard"){
			int team = victim.getTeamNum();
			//if(getNet().isServer()){
				this.set_u32((team==0?"blue":"red")+"_hero_arrive", getGameTime()+WIZARD_DELAY+1);
				this.set_string((team==0?"blue":"red")+"_hero_name", "");
				// this.Sync((team==0?"blue":"red")+"_hero_arrive", true);
				// this.Sync((team==0?"blue":"red")+"_hero_name", true);
				victim.lastBlobName = "knight";
				
				victim.setKills(0);
				victim.setDeaths(0); //reset score on wiz death
				victim.setScore(0);
				
				blob.server_setTeamNum(255);
				Explode(blob,64.0f,10.0f);
				//Explode(server_CreateBlob("sponge", 255, blob.getPosition() ),64.0f,10.0f);
				
				server_CreateBlob( "mat_gold", 255, blob.getPosition() );
				string[] scrollNames = {"carnage",
					// "midas",
					"drought" };				
				server_MakePredefinedScroll( blob.getPosition(), scrollNames[XORRandom(scrollNames.length)]);
			//}
			client_AddToChat((team==0?"Blue":"Red")+" wizard has perished!", SColor(255, 127, 0, 127));
		}
	}
}
