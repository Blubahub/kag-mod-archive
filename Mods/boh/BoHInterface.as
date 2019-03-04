
#include "BoHCommon.as";

string[] wizard_hud_strings(2, "");
f32[] perc(2, 0);
SColor[] color(2, 0xff008000);

void onRender( CRules@ this ){
	if (g_videorecording)
		return;
    CPlayer@ p = getLocalPlayer();
    if (p is null || !p.isMyPlayer() ) { return; }

	Vec2f upperleft( 10, 10+64+10 );
	Vec2f size( 128 + 4*32 , 52);		
	Vec2f off;
	GUI::DrawPane( upperleft, upperleft+size );
	
	string name = this.get_string((p.getTeamNum()==0?"blue":"red")+"_hero_name");
	int seconds = getGameTime()/getTicksASecond();
	
	Vec2f dim = Vec2f(128 + 4*32 - 8, 6);
	Vec2f pos2d = upperleft+Vec2f(4, 20);
	
	for (uint i = 0; i < perc.length; i++) {
		if (perc[i] >= 0.0f){
			GUI::DrawRectangle( pos2d, pos2d+dim );
			GUI::DrawRectangle( pos2d+Vec2f(2, 1), pos2d+Vec2f(perc[i]*dim.x -2, dim.y-2), color[i] );
			pos2d += Vec2f(0, 22);
		}
	}
	
	off = Vec2f(4, 4);
	for (uint i = 0; i < wizard_hud_strings.length; i++) {
		GUI::DrawText((i==0?"Blue":"Red")+" wizard: "+wizard_hud_strings[i], 
			upperleft+off, 
			upperleft+off+size, 
			SColor(((p.getTeamNum()==int(i)) && (p.getUsername()==name) && (seconds%2==0))?0xffff0000:0xffffffff), true, true );
		off += Vec2f(0, 22);
	}
}


void onTick( CRules@ this ){
	const u32 time = getGameTime();
	if(time % 15 == 0){
	
		u32[] arriveTimes;
		arriveTimes.push_back(this.get_u32("blue_hero_arrive"));
		arriveTimes.push_back(this.get_u32( "red_hero_arrive"));
		
		for (uint i = 0; i < arriveTimes.length; i++) {
			int delta = arriveTimes[i]-time;		
			if(arriveTimes[i] != 0){ //arriving	
				string name = this.get_string((i==0?"blue":"red")+"_hero_name");
				string timeString = timeToString(delta / getTicksASecond());
				if(name != ""){
					wizard_hud_strings[i] = name + " (" + timeString + ")";
					color[i] = 0xffac1512;
					perc[i] = (float(delta) / CHANGE_PLAYER_DELAY);
				} else {
					wizard_hud_strings[i] = timeString;
					color[i] = 0xff008000;
					perc[i] = 1 - (float(delta) / WIZARD_DELAY);
				}
			} else {
				if(this.getCurrentState() != GAME){
					wizard_hud_strings[i] = "WARMUP";
					perc[i] = 0;
				} else {
					for(int j=getPlayerCount()-1;j>=0;j--){
						CPlayer@ p = getPlayer(j);
						if(p.lastBlobName == "wizard" && p.getTeamNum()==int(i)){
							wizard_hud_strings[i] = p.getUsername();
							color[i] = 0xffac1512;
							CBlob@ b = p.getBlob();
							if(b !is null){
								perc[i] = b.getHealth() / b.getInitialHealth();
							}
							break;
						}
					}
				}
			}
		}
	}
}

string timeToString(int time){
	int minute = 60;
	int minutes = time / minute;
	int seconds = time % minute;
	return minutes + ":" + formatInt(seconds, "0", 2);
}
/**/