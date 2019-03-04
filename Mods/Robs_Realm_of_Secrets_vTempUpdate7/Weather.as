
SColor color_rain(0xff4444ff);

void onInit(CRules@ this)
{
	this.set_bool("raining",false);
}

void onTick(CRules@ this)
{
	if(this.get_bool("raining")){
		
		//if(getGameTime() % 2 == 0)
		if(getNet().isClient())
		for(int i = 0; i < 2; i += 1)
		if(getCamera() !is null){
			CParticle @drop = ParticlePixel(Vec2f(getCamera().getPosition().x+XORRandom(1280)-640,4), Vec2f(XORRandom(3)-1,0), color_rain, false);
			if(drop !is null){
				drop.fastcollision = true;
				drop.damping = 0.97f;
				//drop.timeout = 600;
				drop.diesoncollide = true;
				drop.lighting = false;
			}
		}
	
		if(getGameTime() % 30*30 == 0){
		
			getMap().SetDayTime(0.99);
		
			if(XORRandom(100) == 0){
				this.set_bool("raining",false);
			}
		
		}
	
		if(getNet().isServer())this.Sync("raining",true);
	
	} else {
	
		if(getNet().isServer()){
			if(getGameTime() % 30*30 == 0)
			if(getMap().getDayTime() < 0.1 || getMap().getDayTime() > 0.8){
				if(XORRandom(20) == 0){
					this.set_bool("raining",true);
				}
			}
		}
		
		//if(getNet().isClient())client_AddToChat("A sudden downpour has begun.", SColor(255, 0, 100, 255));
	
	}
}