
#include "RuneNames.as";
#include "FireCommon.as";
#include "Hitters.as";

void readRunes(CBlob@ this, CBlob@ invoker, string runes){
	
	int CurrentRune = 0;
	
	while(CurrentRune < runes.length()){
		
		int adv = 0;
	
		if(CurrentRune+1 >= runes.length())adv = processRune(this, invoker, getRuneFromLetter(runes.substr(CurrentRune,1)),-1,-1,-1);
		else if(CurrentRune+2 >= runes.length())adv = processRune(this, invoker, getRuneFromLetter(runes.substr(CurrentRune,1)),getRuneFromLetter(runes.substr(CurrentRune+1,1)),-1,-1);
		else if(CurrentRune+3 >= runes.length())adv = processRune(this, invoker, getRuneFromLetter(runes.substr(CurrentRune,1)),getRuneFromLetter(runes.substr(CurrentRune+1,1)),getRuneFromLetter(runes.substr(CurrentRune+2,1)),-1);
		else adv = processRune(this, invoker, getRuneFromLetter(runes.substr(CurrentRune,1)),getRuneFromLetter(runes.substr(CurrentRune+1,1)),getRuneFromLetter(runes.substr(CurrentRune+2,1)),getRuneFromLetter(runes.substr(CurrentRune+3,1)));
		
		CurrentRune += adv+1;
	
	}
	
	if(this.get_s16("power") < 0){
		f32 damage = (this.get_s16("power")*-1)/25;
		this.server_Hit(invoker, invoker.getPosition(), Vec2f(0.0f, 0.0f), damage, Hitters::suddengib, true);
		if(damage > 0.25)this.set_s16("power",0);
	}
	
}

int processRune(CBlob@ this, CBlob@ invoker, int MainRune, int argument0, int argument1, int argument2){

	print("Processed: " + MainRune + ", Arguments: " + argument0 + "," + argument1 + "," + argument2);
	
	if(this.get_s16("power") < 0 && MainRune != 15)return 0;
	
	if(MainRune == 15)MainRune = XORRandom(21)+4;
	
	if(MainRune == 4){ //Fire
		return FireEffect(this, invoker, argument0, argument1);
	}
	
	if(MainRune == 6){ //Earth
		EarthEffect(this, invoker, argument0);
		return 1;
	}
	
	if(MainRune == 7){ //Wind
		return WindEffect(this, invoker, argument0, argument1);
	}
	
	if(MainRune == 8){ //Flesh
		return FleshEffect(this, invoker, argument0, argument1);
	}
	
	if(MainRune == 9){ //Plant
		return PlantEffect(this, invoker);
	}
	
	if(MainRune == 11){ //Grow
		return GrowEffect(this, invoker);
	}
	
	if(MainRune == 13){ //Tele
		return TeleEffect(this, invoker, argument0);
	}
	
	if(MainRune == 16){ //Light
		return LightEffect(this, invoker, argument0);
	}
	
	if(MainRune == 20){ //Dark
		return DarkEffect(this, invoker, argument0);
	}
	
	if(MainRune == 17){ //Life
		return LifeEffect(this, invoker, argument0, argument1, argument2);
	}
	
	if(MainRune == 21){ //Death
		return DeathEffect(this, invoker, argument0, argument1);
	}
	
	return 0;

}

int FireEffect(CBlob@ this, CBlob@ invoker, int target, int filter){

	if(getTargetType(target) == 0){
		invoker.server_Hit(this, this.getPosition(), Vec2f(0.0f, 0.0f), 0.25, Hitters::fire, true);
		if(!this.hasTag("burning"))this.set_s16("power",this.get_s16("power")+25);
		return 1;
	}
	
	if(getTargetType(target) == 1){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(blobMatchesFilter(b,getFilter(filter)))if(b.hasTag("flesh") || b.hasTag("plant") || (b.canBePickedUp(b))){
					if(!b.hasTag("burning"))invoker.server_Hit(b, b.getPosition(), Vec2f(0.0f, 0.0f), 0.25, Hitters::fire, true);
				}
			}
		}
		this.set_s16("power",this.get_s16("power")-50);
		return 2;
	}
	
	if(getTargetType(target) == 2){
		if (getNet().isServer())
		{
			CBlob @blob = server_CreateBlob("fireball", invoker.getTeamNum(), this.getPosition());
			if (blob !is null)
			{
				Vec2f projectileVel = invoker.getAimPos()-this.getPosition();
				projectileVel.Normalize();
				blob.setVelocity(projectileVel*8);
			}
		}
		this.set_s16("power",this.get_s16("power")-20);
		return 1;
	}
	
	if(getTargetType(target) == 3){
		if (getNet().isServer())
		{
			for(int i = 0; i < 40; i += 1){
				CBlob @blob = server_CreateBlob("fireball", invoker.getTeamNum(), this.getPosition());
				if (blob !is null)
				{
					int dir = XORRandom(4)+1;
					if(XORRandom(2) == 0)dir *= -1;
					Vec2f projectileVel = Vec2f(dir,XORRandom(3)-1);
					projectileVel.Normalize();
					blob.setVelocity(projectileVel*8);
				}
			}
		}
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 96.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(blobMatchesFilter(b,getFilter(filter)))if(b.hasTag("flesh") || b.hasTag("plant") || (b.canBePickedUp(b))){
					if(!b.hasTag("burning"))invoker.server_Hit(b, b.getPosition(), Vec2f(0.0f, 0.0f), 0.25, Hitters::fire, true);
				}
			}
		}
		this.set_s16("power",this.get_s16("power")-100);
		return 1;
	}
	return 0;
}

void EarthEffect(CBlob@ this, CBlob@ invoker, int target){

	if(getTargetType(target) == 0){
		invoker.setVelocity(Vec2f(0,-2.5f));
		if (getNet().isServer())
		{
		server_CreateBlob("boulder", -1, invoker.getPosition()+Vec2f(0,8));
		}
		this.set_s16("power",this.get_s16("power")-50);
	}
	
	if(getTargetType(target) == 1){
		if (getNet().isServer())
		{
		server_CreateBlob("boulder", -1, invoker.getPosition()+Vec2f(16,0));
		server_CreateBlob("boulder", -1, invoker.getPosition()+Vec2f(-16,0));
		}
		this.set_s16("power",this.get_s16("power")-100);
	}
	
	if(getTargetType(target) == 2){
		if (getNet().isServer())
		{
			CBlob @blob = server_CreateBlob("boulder", -1, invoker.getPosition());
			if(!invoker.isFacingLeft()) blob.setPosition(invoker.getPosition() + Vec2f(16,0));
			else blob.setPosition(invoker.getPosition() + Vec2f(-16,0));
			if (blob !is null)
			{
				Vec2f projectileVel = invoker.getAimPos()-(invoker.getPosition());
				projectileVel.Normalize();
				blob.setVelocity(projectileVel*8);
			}
			this.set_s16("power",this.get_s16("power")-75);
		}
	}
	
	if(getTargetType(target) == 3)if(this.get_s16("power") > 125){
		if (getNet().isServer())
		{
		for(int i = 0; i < 10; i += 1)server_CreateBlob("boulder", -1, Vec2f(invoker.getPosition().x+XORRandom(256)-128,-XORRandom(80)));
		}
		this.set_s16("power",this.get_s16("power")-250);
	}
	
}

int WindEffect(CBlob@ this, CBlob@ invoker, int target, int type){

	if(getTargetType(target) == 0){
		invoker.setVelocity(Vec2f(0,-7.5f));
		this.set_s16("power",this.get_s16("power")-20);
		return 1;
	}
	
	if(getTargetType(target) == 1){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b !is invoker)if(!b.hasTag("negrunetatoo"))if(b.hasTag("flesh") || b.hasTag("plant") || (b.canBePickedUp(b))){
					Vec2f projectileVel = invoker.getPosition()-b.getPosition();
					projectileVel.Normalize();
					if(doesRuneFlow(type))b.setVelocity(projectileVel*-4);
					else b.setVelocity(projectileVel*4);
				}
			}
		}
		this.set_s16("power",this.get_s16("power")-20);
		return 2;
	}
	
	if(getTargetType(target) == 2){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 32.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b !is invoker)if(!b.hasTag("negrunetatoo"))if(b.hasTag("flesh") || b.hasTag("plant") || (b.canBePickedUp(b))){
					Vec2f projectileVel = invoker.getAimPos()-b.getPosition();
					projectileVel.Normalize();
					if(doesRuneFlow(type))b.setVelocity(projectileVel*8);
					else b.setVelocity(projectileVel*-8);
				}
			}
		}
		this.set_s16("power",this.get_s16("power")-20);
		return 2;
	}
	
	if(getTargetType(target) == 3)if(this.get_s16("power") >= 100){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 1600.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b.hasTag("flesh") || b.hasTag("plant") || (b.canBePickedUp(b) && !b.isAttached()))if(!b.hasTag("negrunetatoo"))
				b.setVelocity(Vec2f(XORRandom(14)-7,XORRandom(14)-7));
			}
		}
		this.set_s16("power",this.get_s16("power")-200);
		return 1;
	}
	
	return 0;
}


int FleshEffect(CBlob@ this, CBlob@ invoker, int target, int filter){

	if(getTargetType(target) == 0){
		if(invoker.getHealth() < invoker.getInitialHealth()*2)invoker.server_SetHealth(invoker.getHealth()+0.5);
		this.set_s16("power",this.get_s16("power")-50);
		return 1;
	}
	
	if(getTargetType(target) == 1){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(blobMatchesFilter(b,getFilter(filter))){
					if(b.getHealth() < b.getInitialHealth()*2)if(!b.hasTag("negrunetatoo"))if(b.hasTag("flesh") || b.hasTag("plant") || (b.canBePickedUp(b))){
						b.server_SetHealth(b.getHealth()+0.5);
						this.set_s16("power",this.get_s16("power")-40);
					}
				}
			}
		}
		return 2;
	}
	
	if(getTargetType(target) == 2){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(blobMatchesFilter(b,getFilter(filter)))if(!b.hasTag("negrunetatoo"))if(b.getTeamNum() == invoker.getTeamNum()){
					if(b.getHealth() < b.getInitialHealth()*2)if(b.hasTag("flesh") || b.hasTag("plant") || (b.canBePickedUp(b))){
						b.server_SetHealth(b.getHealth()+0.5);
						this.set_s16("power",this.get_s16("power")-50);
					}
				}
			}
		}
		return 2;
	}
	
	if(getTargetType(target) == 3)if(this.get_s16("power") >= 125){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 1600.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(blobMatchesFilter(b,getFilter(filter)))if(!b.hasTag("negrunetatoo"))if(b.hasTag("flesh") || b.hasTag("plant") || (b.canBePickedUp(b))){
					if(b.getHealth() < b.getInitialHealth()*2){
						b.server_SetHealth(b.getHealth()+0.5);
						this.set_s16("power",this.get_s16("power")-40);
					}
				}
			}
		}
		return 2;
	}
	
	return 0;
}

int PlantEffect(CBlob@ this, CBlob@ invoker){
	return 0;
}

int GrowEffect(CBlob@ this, CBlob@ invoker){
	
	CMap@ map = this.getMap();
	if   (map is null) return 0;
	
	Vec2f pos = this.getPosition();
	
	int size = 10;
	
	for (int x_step = -size; x_step < size; ++x_step)
	{
		for (int y_step = -size; y_step < size; ++y_step)
		{
			Vec2f off(x_step * map.tilesize, y_step * map.tilesize);
			
			Vec2f tpos = pos + off;
			
			TileType t = map.getTile(tpos).type;
			TileType above = map.getTile(tpos+Vec2f(0,-map.tilesize)).type;
			if(t == CMap::tile_ground)
			if(above == CMap::tile_empty || above == CMap::tile_castle_back || above == CMap::tile_wood_back)
			{
				map.server_SetTile(tpos+Vec2f(0,-map.tilesize), CMap::tile_grass);
				if (getNet().isServer())
				{
				if(XORRandom(4) > 2)server_CreateBlob("bush", -1, tpos+Vec2f(0,-map.tilesize));
				else if(XORRandom(4) > 2){
					CBlob@ grain = server_CreateBlobNoInit( "grain_plant" );
					if(grain !is null)
					{
						grain.Tag("instant_grow");
						grain.setPosition(tpos+Vec2f(0,-map.tilesize));
						grain.Init();
					}
				}
				}
			}
		}
	}
	
	return 0;
}

int TeleEffect(CBlob@ this, CBlob@ invoker, int target){

	if(getTargetType(target) == 0){
		invoker.setPosition(Vec2f(invoker.getPosition().x+XORRandom(192)-96,invoker.getPosition().y+XORRandom(192)-96));
		this.set_s16("power",this.get_s16("power")-10);
		return 1;
	}
	
	if(getTargetType(target) == 1){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b.hasTag("flesh"))if(!b.hasTag("negrunetatoo")){
					b.setPosition(Vec2f(b.getPosition().x+XORRandom(192)-96,b.getPosition().y+XORRandom(192)-96));
				}
			}
		}
		this.set_s16("power",this.get_s16("power")-100);
		return 1;
	}
	
	if(getTargetType(target) == 2)if(this.get_s16("power") > 100){
		CMap@ map = this.getMap();
		Vec2f surfacepos;
		map.rayCastSolid(invoker.getPosition(), invoker.getAimPos(), surfacepos);
		invoker.setPosition(surfacepos);
		this.set_s16("power",this.get_s16("power")-200);
		return 1;
	}
	
	if(getTargetType(target) == 3)if(this.get_s16("power") >= 300){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 1600.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b.hasTag("flesh"))if(!b.hasTag("negrunetatoo")){
					b.setPosition(Vec2f(b.getPosition().x+XORRandom(128)-64,b.getPosition().y+XORRandom(192)-96));
				}
			}
		}
		this.set_s16("power",this.get_s16("power")-300);
		return 1;
	}
	
	return 0;
}

int LifeEffect(CBlob@ this, CBlob@ invoker, int target, int type1, int type2){
	
	
	string summon = "none";
	int mod = 1;
	int team = -1;
	
	if(type1 == 8){
		if(type2 == 7)summon = "chicken";
		if(type2 == 5)summon = "fishy";
		if(type2 == 21){summon = "zombie";mod = 4;}
		if(type2 == 8){summon = "bison";mod = 20;}
	}
	if(type1 == 10)if(type2 == 5){summon = "shark";mod = 20;}
	
	
	
	
	if(summon != "none"){
		
		if(getTargetType(target) == 0){
			if (getNet().isServer())
			{
			server_CreateBlob(summon, team, invoker.getPosition());
			}
			this.set_s16("power",this.get_s16("power")-25*mod);
		}
		
		if(getTargetType(target) == 1)if(this.get_s16("power") >= 25*mod){
			if (getNet().isServer())
			{
			server_CreateBlob(summon, team, invoker.getPosition()+Vec2f(16,0));
			server_CreateBlob(summon, team, invoker.getPosition()+Vec2f(-16,0));
			}
			this.set_s16("power",this.get_s16("power")-50*mod);
		}
		
		if(getTargetType(target) == 2){
			if (getNet().isServer())
			{
			server_CreateBlob(summon, team, invoker.getAimPos());
			}
			this.set_s16("power",this.get_s16("power")-30*mod);
		}
		
		if(getTargetType(target) == 3)if(this.get_s16("power") > 125*mod){
			CBlob@[] blobsInRadius;	   
			if (this.getMap().getBlobsInRadius(this.getPosition(), 1600.0f, @blobsInRadius)) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ b = blobsInRadius[i];
					if(b.hasTag("Flesh")){
						if (getNet().isServer())
						{
						server_CreateBlob(summon, team, b.getPosition()+Vec2f(16,0));
						server_CreateBlob(summon, team, b.getPosition()+Vec2f(-16,0));
						this.set_s16("power",this.get_s16("power")-50*mod);
						}
					}
				}
			}
		}

		if(type1 == 8){
			if(type2 == 5)return 3;
			if(type2 == 21)return 3;
			if(type2 == 7)return 3;
			if(type2 == 8)return 3;
		}
		if(type1 == 10)if(type2 == 5)return 3;
	}
	
	
	return 0;
}

int DeathEffect(CBlob@ this, CBlob@ invoker, int target, int filter){

	if(getTargetType(target) == 0)if(invoker.getHealth() > 0){
		invoker.server_Hit(invoker, invoker.getPosition(), Vec2f(0.0f, 0.0f), 1.0f, Hitters::suddengib, true);
		if(!invoker.hasTag("holy"))this.set_s16("power",this.get_s16("power")+50);
		return 1;
	}
	
	if(getTargetType(target) == 1)if(this.get_s16("power") >= 100){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(blobMatchesFilter(b,getFilter(filter)))if(!b.hasTag("negrunetatoo"))if(b.hasTag("flesh") || b.hasTag("plant")){
					invoker.server_Hit(b, b.getPosition(), Vec2f(0.0f, 0.0f), 1.0f, Hitters::suddengib, true);
				}
			}
		}
		this.set_s16("power",this.get_s16("power")-100);
		return 2;
	}
	
	if(getTargetType(target) == 2){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b.getTeamNum() == invoker.getTeamNum())if(!b.hasTag("negrunetatoo"))if(b.hasTag("flesh") || b.hasTag("plant"))if(b.getHealth() > 0){
					invoker.server_Hit(b, b.getPosition(), Vec2f(0.0f, 0.0f), 1.0f, Hitters::suddengib, true);
					this.set_s16("power",this.get_s16("power")+50);
				}
			}
		}
		return 1;
	}
	
	if(getTargetType(target) == 3)if(this.get_s16("power") > 500){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 1600.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(blobMatchesFilter(b,getFilter(filter)))if(!b.hasTag("negrunetatoo"))if(b.hasTag("flesh") || b.hasTag("plant")){
					invoker.server_Hit(b, b.getPosition(), Vec2f(0.0f, 0.0f), 4.0f, Hitters::suddengib, true);
				}
			}
		}
		this.set_s16("power",this.get_s16("power")-1000);
		return 2;
	}
	
	return 0;
}

int LightEffect(CBlob@ this, CBlob@ invoker, int target){

	if(getTargetType(target) == 0)if(this.get_s16("power") > 10){
		if (getNet().isServer())
		{
		server_CreateBlob("lantern", -1, this.getPosition());
		}
		this.set_s16("power",this.get_s16("power")-10);
		return 1;
	}
	
	if(getTargetType(target) == 1){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b.hasTag("flesh")){
				if(!b.hasTag("negrunetatoo"))
				if(b.hasTag("evil"))
					invoker.server_Hit(b, b.getPosition(), Vec2f(0.0f, 0.0f), 1.0f, Hitters::suddengib, false);
				}
			}
		}
		this.set_s16("power",this.get_s16("power")-50);
		return 1;
	}
	
	if(getTargetType(target) == 2){
		if (getNet().isServer())
		{
		CBlob @blob = server_CreateBlob("smite", -1, this.getPosition());
		if (blob !is null)
		{
			Vec2f projectileVel = invoker.getAimPos()-this.getPosition();
			projectileVel.Normalize();
			blob.setVelocity(projectileVel*8);
		}
		}
		this.set_s16("power",this.get_s16("power")-20);
		return 1;
	}
	
	if(getTargetType(target) == 3){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 1600.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b.hasTag("evil"))if(!b.hasTag("negrunetatoo"))invoker.server_Hit(b, b.getPosition(), Vec2f(0.0f, 0.0f), 2.0f, Hitters::suddengib, false);
			}
		}
		this.set_s16("power",this.get_s16("power")-100);
		return 1;
	}
	return 0;
}

int DarkEffect(CBlob@ this, CBlob@ invoker, int target){

	if(getTargetType(target) == 0){
		if(invoker.hasTag("holy")){
			this.set_s16("power",this.get_s16("power")+100);
			invoker.Untag("holy");
			invoker.Tag("evil");
		}
		return 1;
	}
	
	if(getTargetType(target) == 1){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b.hasTag("flesh"))if(b.hasTag("holy"))if(!b.hasTag("negrunetatoo")){
					this.set_s16("power",this.get_s16("power")+50);
					b.Untag("holy");
					b.Tag("evil");
				}
			}
		}
		return 1;
	}
	
	if(getTargetType(target) == 2){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b.hasTag("flesh") && b.getTeamNum() == invoker.getTeamNum())if(b.hasTag("holy"))if(!b.hasTag("negrunetatoo")){
					this.set_s16("power",this.get_s16("power")+100);
					b.Untag("holy");
					b.Tag("evil");
				}
			}
		}
		return 1;
	}
	
	if(getTargetType(target) == 3){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 1600.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b.hasTag("flesh"))if(b.hasTag("holy"))if(!b.hasTag("negrunetatoo")){
					this.set_s16("power",this.get_s16("power")+50);
					b.Untag("holy");
					b.Tag("evil");
				}
			}
		}
		return 1;
	}
	return 0;
}

int getTargetType(int rune){
	
	//0 - Self
	//1 - Nearby
	//2 - Aim
	//3 - Global
	//4 - Random
	
	int rand = XORRandom(4);
	
	switch(rune){
		case 0: return 0;
		case 1: return 1;
		case 2: return 3;
		case 3: return 2;
		case 4: return 1;
		case 5: return 2;
		case 6: return 2;
		case 7: return 3;
		case 8: return 0;
		case 9: return 1;
		case 10: return 2;
		case 11: return 0;
		case 12: return rand;
		case 13: return 3;
		case 14: return 0;
		case 15: return rand;
		case 16: return 3;
		case 17: return 2;
		case 18: return 2;
		case 19: return 1;
		case 20: return 2;
		case 21: return 1;
		case 22: return 1;
		case 23: return 1;
	}
	
	return 0;
}

int getFilter(int rune){
	
	//0 - None
	//1 - Evil
	//2 - Holy
	//3 - Alive/Flesh
	//4 - Alive/Plant
	//5 - Alive
	//6 - Dead
	//7 - Random
	
	int rand = XORRandom(7);
	
	switch(rune){
		case 0: return 0;
		case 1: return 0;
		case 2: return 1;
		case 3: return 0;
		case 4: return 0;
		case 5: return 0;
		case 6: return 0;
		case 7: return 0;
		case 8: return 3;
		case 9: return 4;
		case 10: return 3;
		case 11: return 4;
		case 12: return rand;
		case 13: return 0;
		case 14: return 0;
		case 15: return rand;
		case 16: return 2;
		case 17: return 5;
		case 18: return 0;
		case 19: return 0;
		case 20: return 1;
		case 21: return 6;
		case 22: return 0;
		case 23: return 0;
	}
	
	return 0;
}

bool blobMatchesFilter(CBlob@ blob, int filter){
	
	if(filter == 0)return true;
	if(filter == 1)if(blob.hasTag("evil"))return true;
	if(filter == 2)if(blob.hasTag("holy"))return true;
	if(filter == 3)if(blob.hasTag("flesh"))if(!blob.hasTag("dead") && !blob.hasTag("undead"))return true;
	if(filter == 4)if(blob.hasTag("plant"))if(!blob.hasTag("dead") && !blob.hasTag("undead"))return true;
	if(filter == 5)if(blob.hasTag("flesh") || blob.hasTag("plant"))if(!blob.hasTag("dead") && !blob.hasTag("undead"))return true;
	if(filter == 6)if(blob.hasTag("dead") || blob.hasTag("undead"))return true;
	
	return false;
}

bool doesRuneFlow(int rune)
{
	switch(rune){
	
	case 0: return false;
	case 1: return true;
	case 2: return true;
	case 3: return false;
	case 4: return false;
	case 5: return true;
	case 6: return false;
	case 7: return true;
	case 8: return false;
	case 9: return true;
	case 10: return false;
	case 11: return true;
	case 12: return true;
	case 13: return true;
	case 14: return false;
	case 15: {
		if(XORRandom(2) == 0) return false;
		else return true;
	}
	case 16: return true;
	case 17: return true;
	case 18: return true;
	case 19: return false;
	case 20: return false;
	case 21: return false;
	case 22: return false;
	case 23: return true;
	
	
	
	}

	return false;
}