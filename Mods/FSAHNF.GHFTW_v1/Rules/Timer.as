

void onTick(CRules @ this){
	
	
    
	
	if(!this.isWarmup() && this.isMatchRunning() && !this.isGameOver()){
		
		int gametime = getGameTime()-this.get_u32("warmuptime");
		int Seconds = (gametime/30);
		int Minutes = 0;
		int Hours = 0;
		
		while(Seconds > 59){
			Minutes++;
			Seconds -= 60;
		}
		while(Minutes > 59){
			Hours++;
			Minutes -= 60;
		}
		
		string time = ""+Seconds;
		if(Minutes > 0 || Hours > 0){
			if(Seconds < 10)time = ""+Minutes+":0"+Seconds;
			else time = ""+Minutes+":"+Seconds;
		}
		if(Hours > 0){
			if(Minutes < 10)time = ""+Hours+":0"+time;
			else time = ""+Hours+":"+time;
		}
		
		this.SetGlobalMessage("Game Time: "+ time);
		
		if(Maths::FMod(Minutes+Hours*60, 8) == 4)this.SetGlobalMessage("(WARNING: Event Soon) Game Time: "+ time + " (WARNING: Event Soon)");
		
		if(Maths::FMod(Minutes, 5) == 0 && Seconds == 0){
			if(!this.hasTag("hit2")){
				this.Tag("hit2");
				string promo = "";
				
				switch(XORRandom(7)){
					case 0:{
						promo = "The new emotes were drawn by 8x. Thank him.";
					break;}
					
					case 1:{
						promo = "The server is owned by bunnie. Thank him.";
					break;}
					
					case 2:{
						promo = "The server is hosted by Vamist. Thank him.";
					break;}
					
					case 3:{
						promo = "Some sprites were created by TFlippy. Thank him.";
					break;}
					
					case 4:{
						promo = "The maps are made by Icewuerfel, Hallic, bunnie and others that participated in Iko Mapmaking Competition. Thank them.";
					break;}
					
					case 5:{
						promo = "If you have any maps for this server to use or ideas, send them to bunnie at forum.thd.vg";
					break;}
					
					case 6:{
						promo = "Random events happen every 8 min, don't be scared if it's raining meteors.";
					break;}
				}
				
				client_AddToChat(promo);
			}
		} else {
			this.Untag("hit2");
		}
		
		if(getNet().isServer()){
			if(Maths::FMod(Minutes+Hours*60, 8) == 5 && Seconds == 0){
				if(!this.hasTag("hit")){
					this.Tag("hit");
				
					switch(XORRandom(4)){
						case 0:{
							server_CreateBlob("meteorstorm",-1,Vec2f(0,0));
						break;}
						
						case 1:{
							server_CreateBlob("gravitydrop",-1,Vec2f(0,0));
						break;}
						
						case 2:{
							server_CreateBlob("moneyrain",-1,Vec2f(0,0));
						break;}
						
						case 3:{
							server_CreateBlob("wildfire",-1,Vec2f(0,0));
						break;}
					}
				}
			} else {
				this.Untag("hit");
			}
		}
		
	} else {
		this.set_u32("warmuptime",getGameTime());
	}
}