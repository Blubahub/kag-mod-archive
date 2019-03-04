#include "Knocked.as";
#include "Health.as";
#include "Hitters.as";

void onInit(CBlob @this){
	this.set_f32("food_starch",50); //Starch is the most basic food, lasts a decent while.
	this.set_f32("food_protein",50); //Protein is the quickest to get food, lasts quick short, however usually comes along with fat.
	this.set_f32("food_fat",0); //Fat, long term food, generally difficult to get in large amounts.
	
	this.set_f32("heat",27); //Heat goes from 0 to 50, as per usual, normal temp is 27.
}

void onTick(CBlob @this){
	
	if(this.hasTag("dead") || this.getPlayer() is null)return;
	
	f32 HungerRate = 0.1;
	
	///////Welcome to the wonderful world of heat exchange.
	
	f32 HeatMulti = 0.75;
	
	f32 WorldTemperature = 25; //Also known as weather temperature
	
	if(getGameTime() % 15 == 0){
	
		if(getMap().getDayTime() < 0.1 || getMap().getDayTime() > 0.8)WorldTemperature = 10; //Daytime is colder than night time
		
		bool Raining = false;
		if(getRules() !is null){
			if(getRules().get_bool("raining"))Raining = true;
		}
		
		if(Raining)WorldTemperature = 10;
		
		f32 SunTemperature = 30;
		f32 EnviromentTemperature = 25;
		
		bool indoors = false;
		
		for(int i = 0; i < 2; i += 1){
			Vec2f pos = Vec2f(0,0);
			getMap().rayCastSolidNoBlobs(this.getPosition()+Vec2f(-4+i*8,0),Vec2f(this.getPosition().x,0)+Vec2f(-4+i*8,0),pos);
			int id = getMap().getTile(pos).type;
			if(getMap().isTileCastle(id) || getMap().isTileStone(id) || getMap().isTileThickStone(id)){
				EnviromentTemperature -= 2;
			}
			if(getMap().isTileSolid(id)){
				indoors = true;
			}
		}
		
		if(indoors){
			for(int i = 0; i < 2; i += 1)
			for(int j = 0; j < 2; j += 1){
				int id = getMap().getTile((this.getPosition())+Vec2f(i*8-4,j*8-4)).type;
				if(id == CMap::tile_castle_back || id == CMap::tile_castle_back_moss
				|| id == CMap::tile_ground_back)EnviromentTemperature -= 2;
			}
			
			if(this.isOnGround())for(int i = 0; i < 2; i += 1){
				int id = getMap().getTile((this.getPosition())+Vec2f(i*8-4,12)).type;
				if(getMap().isTileCastle(id) || getMap().isTileStone(id) || getMap().isTileThickStone(id))EnviromentTemperature -= 2;
			}
		}
		
		///Body temperture self-regulation
		if(this.get_f32("heat") < 27){
			this.set_f32("heat",this.get_f32("heat")+HeatMulti*0.5);
			if(this.get_f32("heat") < 15)HungerRate = HungerRate*2;
			//When you're cold your body uses energy to keep warm. If I ever added thirst, your body cooling itself would use that.
		}
		if(this.get_f32("heat") > 27)this.set_f32("heat",this.get_f32("heat")-HeatMulti*0.5);
		
		
		if(!this.isInWater() && (!Raining || indoors)){//Air temperature - much weaker than anything else
			if(this.get_f32("heat") < WorldTemperature)this.set_f32("heat",this.get_f32("heat")+HeatMulti*0.1);
			if(this.get_f32("heat") > WorldTemperature)this.set_f32("heat",this.get_f32("heat")-HeatMulti*0.1);
		} else { //Water is colds
			if(this.isInWater()){if(this.get_f32("heat") > WorldTemperature/2)this.set_f32("heat",this.get_f32("heat")-HeatMulti);}
			else if(this.get_f32("heat") > WorldTemperature)this.set_f32("heat",this.get_f32("heat")-HeatMulti);
			//Water can't warm you obviously, too much flow
			//If there is a spa added eventually it'll be based of an object, similar to campfires
		}
		
		//Sunlight so bright
		if(getMap().getDayTime() > 0.1 && getMap().getDayTime() < 0.8)
		if(!indoors){
			if(this.get_f32("heat") < SunTemperature)this.set_f32("heat",this.get_f32("heat")+HeatMulti*0.8);
		}
		
		//Enviroment!
		//Enviroment can only cool because cold stone and whatnot
		if(this.get_f32("heat") > EnviromentTemperature)this.set_f32("heat",this.get_f32("heat")-HeatMulti);
		
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 128.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b.getName() == "fireplace")
				{
					
					this.set_f32("heat",this.get_f32("heat")+HeatMulti*(1-(this.getDistanceTo(b)/128)));
				}
				if(b.getName() == "lantern")
				{
					
					this.set_f32("heat",this.get_f32("heat")+HeatMulti*(1-(this.getDistanceTo(b)/128))*0.5);
				}
				if(b.getName() == "caged_wisp")
				{
					if(this.get_f32("heat") < 27)this.set_f32("heat",this.get_f32("heat")+HeatMulti);
					if(this.get_f32("heat") > 27)this.set_f32("heat",this.get_f32("heat")-HeatMulti);
				}
				if(b.getName() == "forge")
				{
					
					this.set_f32("heat",this.get_f32("heat")+HeatMulti*(1-(this.getDistanceTo(b)/128))*0.5);
				}
			}
		}
		
		if(this.hasTag("burning"))
		this.set_f32("heat",this.get_f32("heat")+HeatMulti*2);
		
		if(this.get_f32("heat") < 27)
		this.set_f32("cold",this.get_f32("heat")/27);
		
		if(this.get_f32("heat") > 50){
			if(!this.hasTag("burning"))
			if(XORRandom(100) == 0)
			if(getNet().isServer())this.server_Hit(this, this.getPosition(), Vec2f(0,0), 0.25, Hitters::fire, true);
		}
	
	}
	
	
	
	///Hunger logic up next
	
	if(getGameTime() % 30 == 0){
	
		if(this.get_f32("food_protein") > 0){
			this.set_f32("food_protein",this.get_f32("food_protein")-(4.0*HungerRate));
			if(getNet().isServer())this.Sync("food_protein",true);
		} else 
		if(this.get_f32("food_starch") > 0){
			this.set_f32("food_starch",this.get_f32("food_starch")-(2.0*HungerRate));
			if(getNet().isServer())this.Sync("food_starch",true);
		} else 
		if(this.get_f32("food_fat") > 0){
			this.set_f32("food_fat",this.get_f32("food_fat")-(HungerRate));
			if(getNet().isServer())this.Sync("food_fat",true);
		} else {
			//Starvation
			//You can actually survive quite a while while starving, but it'll be super annoying.
			SetKnocked(this, 10);
			if(XORRandom(100) == 0){
				if(getNet().isServer())this.server_Hit(this, this.getPosition(), Vec2f(0,0), 0.5, Hitters::suddengib, true);
				this.set_f32("food_fat",3);
				if(getNet().isServer())this.Sync("food_fat",true);
			}
		}
	
	}
	
	if(this.get_f32("food_fat") > 100)this.set_f32("food_fat",100);
	if(this.get_f32("food_starch") > 100)this.set_f32("food_starch",100);
	if(this.get_f32("food_protein") > 100)this.set_f32("food_protein",100);
}

void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;
	
	CBlob @blob = this.getBlob();
	
	if(!blob.isMyPlayer() || blob.hasTag("dead"))return;
	
	int BarX = 4;
	int BarY = 4;
	
	f32 AmountPerc = (blob.get_f32("food_starch")+blob.get_f32("food_fat")+blob.get_f32("food_protein"))/300.0;
	
	f32 AmountMax = 20;
	f32 Amount = AmountMax*AmountPerc;
	
	for(int i = 0; i < AmountMax; i += 1){
		
		if(i+1 >= AmountMax){
			GUI::DrawIcon("GridMenu.png", 12+8, Vec2f(8, 8), Vec2f(BarX+8,BarY+48+i*16), 1.0f);
			GUI::DrawIcon("GridMenu.png", 14+8, Vec2f(8, 8), Vec2f(BarX+8+16,BarY+48+i*16), 1.0f);
		} else {
			GUI::DrawIcon("GridMenu.png", 12, Vec2f(8, 8), Vec2f(BarX+8,BarY+48+i*16), 1.0f);
			GUI::DrawIcon("GridMenu.png", 14, Vec2f(8, 8), Vec2f(BarX+8+16,BarY+48+i*16), 1.0f);
		}
	}
	
	for(int i = 0; i < Maths::Floor(Amount); i += 1){
		GUI::DrawIcon("GridMenu.png", 8, Vec2f(8, 8), Vec2f(BarX+8,BarY+48+i*16), 1.0f);
		GUI::DrawIcon("GridMenu.png", 10, Vec2f(8, 8), Vec2f(BarX+8+16,BarY+48+i*16), 1.0f);
		
		if(i+1 >= Maths::Floor(Amount)){
			f32 addFraction = (Amount-Maths::Floor(Amount))*16.0;
			GUI::DrawIcon("GridMenu.png", 8+8, Vec2f(8, 8), Vec2f(BarX+8,BarY+48+i*16+addFraction), 1.0f);
			GUI::DrawIcon("GridMenu.png", 10+8, Vec2f(8, 8), Vec2f(BarX+8+16,BarY+48+i*16+addFraction), 1.0f);
		}
	}
	if(Maths::Floor(Amount) == 0){
		f32 addFraction = (Amount-Maths::Floor(Amount))*16.0;
		GUI::DrawIcon("GridMenu.png", 8+8, Vec2f(8, 8), Vec2f(BarX+8,BarY+48+addFraction-16), 1.0f);
		GUI::DrawIcon("GridMenu.png", 10+8, Vec2f(8, 8), Vec2f(BarX+8+16,BarY+48+addFraction-16), 1.0f);
	}
	
	GUI::DrawIcon("GridMenu.png", 0, Vec2f(24, 24), Vec2f(BarX,BarY), 1.0f);
	
	GUI::DrawIcon("Quarters.png", 9, Vec2f(24, 24), Vec2f(BarX,BarY), 1.0f);
	
	
	for(int i = 0; i < AmountMax; i += 1){
		
		if(i+1 >= AmountMax){
			GUI::DrawIcon("GridMenu.png", 12+8, Vec2f(8, 8), Vec2f(BarX+8+48+4,BarY+48+i*16), 1.0f);
			GUI::DrawIcon("GridMenu.png", 14+8, Vec2f(8, 8), Vec2f(BarX+8+16+48+4,BarY+48+i*16), 1.0f);
		} else {
			GUI::DrawIcon("GridMenu.png", 12, Vec2f(8, 8), Vec2f(BarX+8+48+4,BarY+48+i*16), 1.0f);
			GUI::DrawIcon("GridMenu.png", 14, Vec2f(8, 8), Vec2f(BarX+8+16+48+4,BarY+48+i*16), 1.0f);
		}
	}
	
	Amount = blob.get_f32("heat")*((AmountMax*16)/50);
	
	GUI::DrawIcon("GridMenu.png", 0, Vec2f(8, 8), Vec2f(BarX+8+48+4,BarY+48-Amount+AmountMax*16-16), 1.0f);
	GUI::DrawIcon("GridMenu.png", 2, Vec2f(8, 8), Vec2f(BarX+8+16+48+4,BarY+48-Amount+AmountMax*16-16), 1.0f);
	GUI::DrawIcon("GridMenu.png", 8+8, Vec2f(8, 8), Vec2f(BarX+8+48+4,BarY+48-Amount+AmountMax*16-14), 1.0f);
	GUI::DrawIcon("GridMenu.png", 10+8, Vec2f(8, 8), Vec2f(BarX+8+16+48+4,BarY+48-Amount+AmountMax*16-14), 1.0f);
	
	GUI::DrawIcon("GridMenu.png", 0, Vec2f(24, 24), Vec2f(BarX+48+4,BarY), 1.0f);
	
	GUI::DrawIcon("Thermometre.png", 0, Vec2f(32, 32), Vec2f(BarX+48-4,BarY-8), 1.0f);
		
}