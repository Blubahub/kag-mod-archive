#include "Hitters.as";

void givePlayerEffect(CBlob@ this, CBlob@ oth){
	
	if(oth.hasTag("negrunetatoo"))return;
	
	//if (!getNet().isServer())return;
	
	int GoodOrBad = 0;
	
	int firewater = 0;
	int fleshplant = 0;
	int consumegrow = 0;
	int hasteslow = 0;
	int goodevil = 0;
	int healhurt = 0;
	int earthair = 0;
	int chaos = 0;
	int cleanseinfect = 0;
	
	CBlob@[] blobsInRadius;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), 8.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b.hasTag("rune"))
			if(!b.isAttached())
			if(!b.hasTag("touchrune") && !b.hasTag("sightrune")){
				if(b.hasTag("liferune") || b.hasTag("lightrune") || b.hasTag("witnessrune") || b.hasTag("cleanserune") || b.hasTag("hasterune"))GoodOrBad += 1;
				if(b.hasTag("deathrune") || b.hasTag("darkrune") || b.hasTag("curserune") || b.hasTag("infectrune") || b.hasTag("slowrune"))GoodOrBad -= 1;
				
				if(b.hasTag("lightrune"))goodevil += 1;
				if(b.hasTag("darkrune"))goodevil -= 1;
				
				if(b.hasTag("liferune"))healhurt += 1;
				if(b.hasTag("deathrune"))healhurt -= 1;
				
				if(b.hasTag("firerune"))firewater += 1;
				if(b.hasTag("waterrune"))firewater -= 1;
				
				if(b.hasTag("earthrune"))earthair += 1;
				if(b.hasTag("airrune"))earthair -= 1;
				
				if(b.hasTag("fleshrune"))fleshplant += 1;
				if(b.hasTag("plantrune"))fleshplant -= 1;
				
				if(b.hasTag("consumerune"))consumegrow += 1;
				if(b.hasTag("growrune"))consumegrow -= 1;
				
				if(b.hasTag("hasterune"))hasteslow += 1;
				if(b.hasTag("slowrune"))hasteslow -= 1;
				
				if(b.hasTag("chaosrune"))chaos += 1;
				if(b.hasTag("negrune"))chaos -= 1;
				
				if(b.hasTag("cleanserune"))cleanseinfect += 1;
				if(b.hasTag("infectrune"))cleanseinfect -= 1;
			}
		}
	}
	
	for (int i = 0; i < chaos; i++){
		
		if(XORRandom(4) > 2)goodevil += 1;
		if(XORRandom(4) > 2)goodevil -= 1;
		if(XORRandom(4) > 2)healhurt += 1;
		if(XORRandom(4) > 2)healhurt -= 1;
		if(XORRandom(4) > 2)firewater += 1;
		if(XORRandom(4) > 2)firewater -= 1;
		if(XORRandom(4) > 2)earthair += 1;
		if(XORRandom(4) > 2)earthair -= 1;
		if(XORRandom(4) > 2)fleshplant += 1;
		if(XORRandom(4) > 2)fleshplant -= 1;
		if(XORRandom(4) > 2)consumegrow += 1;
		if(XORRandom(4) > 2)consumegrow -= 1;
		if(XORRandom(4) > 2)hasteslow += 1;
		if(XORRandom(4) > 2)hasteslow -= 1;
		if(XORRandom(4) > 2)chaos += 1;
		
	}
	
	if(goodevil > 0){
		if(GoodOrBad > 0)if(oth.hasTag("evil"))return;
		if(GoodOrBad < 0)if(oth.hasTag("holy"))return;
	}
	if(goodevil < 0){
		if(GoodOrBad > 0)if(oth.hasTag("holy"))return;
		if(GoodOrBad < 0)if(oth.hasTag("evil"))return;
	}
	
	if(healhurt > 0)if(oth.getHealth() < oth.getInitialHealth())oth.server_Heal(healhurt*0.25f);
	if(healhurt < 0){
		this.server_Hit(oth, oth.getPosition(), Vec2f(0.0f, 0.0f), healhurt*-0.25, Hitters::suddengib, false);
	}
	
	if(firewater > 0){
		if(GoodOrBad < 0)this.server_Hit(oth, oth.getPosition(), Vec2f(0.0f, 0.0f), 0.25, Hitters::fire, true);
		if(GoodOrBad == 0)oth.set_s16("empowerfire",600);
		if(GoodOrBad > 0)oth.set_s16("empowerfirelvl2",600);
	}
	
	if(firewater < 0){
		if(GoodOrBad < 0)oth.set_s16("cant_breathe_air",1800);
		if(GoodOrBad == 0)oth.set_s16("empowerwater",600);
		if(GoodOrBad > 0)oth.set_s16("empowerwaterlvl2",1800);
	}
	
	if(earthair > 0){
		if(GoodOrBad <= 0)oth.set_s16("squatlvl2",600);
		if(GoodOrBad >= 0)oth.set_s16("defenselvl2",600);
	}
	if(earthair < 0){
		if(GoodOrBad <= 0)oth.set_s16("weaklvl2",600);
		if(GoodOrBad >= 0)oth.set_s16("highjumplvl2",600);
	}
	
	if(fleshplant > 0){
		if(GoodOrBad < 0)oth.set_s16("noheal",600);
		if(GoodOrBad > 0)oth.set_s16("overheallvl2",600);
	}
	if(fleshplant < 0){
		if(GoodOrBad <= 0)oth.set_s16("poisonlvl2",600);
		if(GoodOrBad >= 0)oth.set_s16("bufflvl2",600);
	}
	
	if(consumegrow > 0){
		if(GoodOrBad <= 0)oth.set_s16("drainlvl2",600);
		if(GoodOrBad >= 0)oth.set_s16("lifesteallvl2",600);
	}
	if(consumegrow < 0){
		if(GoodOrBad <= 0)oth.set_s16("stuntlvl2",600);
		if(GoodOrBad >= 0)oth.set_s16("overregenlvl2",600);
	}
	
	
	if(hasteslow > 0)oth.set_s16("hastelvl2",600);
	if(hasteslow < 0)oth.set_s16("slowlvl2",600);
	
	if(cleanseinfect > 0)oth.Tag("cleanse");
	if(cleanseinfect < 0)oth.Tag("infect");
	
	return;
}

void givePlayerEffectGood(CBlob@ this, CBlob@ oth){
	
	if(oth.hasTag("negrunetatoo"))return;
	
	//if (!getNet().isServer())return;
	
	int GoodOrBad = 5;
	
	int firewater = 0;
	int fleshplant = 0;
	int consumegrow = 0;
	int hasteslow = 0;
	int goodevil = 0;
	int healhurt = 0;
	int earthair = 0;
	int chaos = 0;
	int cleanseinfect = 0;
	
	CBlob@[] blobsInRadius;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), 8.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b.hasTag("rune"))
			if(!b.isAttached())
			if(!b.hasTag("witnessrune")){
				if(b.hasTag("liferune") || b.hasTag("lightrune") || b.hasTag("witnessrune") || b.hasTag("cleanserune") || b.hasTag("hasterune"))GoodOrBad += 1;
				if(b.hasTag("deathrune") || b.hasTag("darkrune") || b.hasTag("curserune") || b.hasTag("infectrune") || b.hasTag("slowrune"))GoodOrBad -= 1;
				
				if(b.hasTag("lightrune"))goodevil += 1;
				if(b.hasTag("darkrune"))goodevil -= 1;
				
				if(b.hasTag("liferune"))healhurt += 1;
				if(b.hasTag("deathrune"))healhurt -= 1;
				
				if(b.hasTag("firerune"))firewater += 1;
				if(b.hasTag("waterrune"))firewater -= 1;
				
				if(b.hasTag("earthrune"))earthair += 1;
				if(b.hasTag("airrune"))earthair -= 1;
				
				if(b.hasTag("fleshrune"))fleshplant += 1;
				if(b.hasTag("plantrune"))fleshplant -= 1;
				
				if(b.hasTag("consumerune"))consumegrow += 1;
				if(b.hasTag("growrune"))consumegrow -= 1;
				
				if(b.hasTag("hasterune"))hasteslow += 1;
				if(b.hasTag("slowrune"))hasteslow -= 1;
				
				if(b.hasTag("chaosrune"))chaos += 1;
				if(b.hasTag("negrune"))chaos -= 1;
				
				if(b.hasTag("cleanserune"))cleanseinfect += 1;
				if(b.hasTag("infectrune"))cleanseinfect -= 1;
			}
		}
	}
	
	for (int i = 0; i < chaos; i++){
		
		if(XORRandom(4) > 2)goodevil += 1;
		if(XORRandom(4) > 2)goodevil -= 1;
		if(XORRandom(4) > 2)healhurt += 1;
		if(XORRandom(4) > 2)healhurt -= 1;
		if(XORRandom(4) > 2)firewater += 1;
		if(XORRandom(4) > 2)firewater -= 1;
		if(XORRandom(4) > 2)earthair += 1;
		if(XORRandom(4) > 2)earthair -= 1;
		if(XORRandom(4) > 2)fleshplant += 1;
		if(XORRandom(4) > 2)fleshplant -= 1;
		if(XORRandom(4) > 2)consumegrow += 1;
		if(XORRandom(4) > 2)consumegrow -= 1;
		if(XORRandom(4) > 2)hasteslow += 1;
		if(XORRandom(4) > 2)hasteslow -= 1;
		if(XORRandom(4) > 2)chaos += 1;
		
	}
	
	if(goodevil > 0){
		if(GoodOrBad > 0)if(oth.hasTag("evil"))return;
		if(GoodOrBad < 0)if(oth.hasTag("holy"))return;
	}
	if(goodevil < 0){
		if(GoodOrBad > 0)if(oth.hasTag("holy"))return;
		if(GoodOrBad < 0)if(oth.hasTag("evil"))return;
	}
	
	if(healhurt > 0)if(oth.getHealth() < oth.getInitialHealth())oth.server_Heal(healhurt*1.0f);
	//if(healhurt < 0){
	//	this.server_Hit(oth, oth.getPosition(), Vec2f(0.0f, 0.0f), (healhurt-1)*-0.25, Hitters::suddengib, false);
	//}
	
	if(firewater > 0){
		if(GoodOrBad < 0)this.server_Hit(oth, oth.getPosition(), Vec2f(0.0f, 0.0f), 0.25, Hitters::fire, true);
		if(GoodOrBad == 0)oth.set_s16("empowerfire",150);
		if(GoodOrBad > 0)oth.set_s16("empowerfirelvl2",150);
	}
	
	if(firewater < 0){
		if(GoodOrBad < -1)oth.set_s16("cant_breathe_air",150);
		if(GoodOrBad == 0)oth.set_s16("empowerwater",150);
		if(GoodOrBad > 0)oth.set_s16("empowerwaterlvl2",150);
	}
	
	if(earthair > 0){
		if(GoodOrBad <= 0)oth.set_s16("squatlvl2",150);
		if(GoodOrBad >= 0)oth.set_s16("defenselvl3",150);
	}
	if(earthair < 0){
		if(GoodOrBad <= 0)oth.set_s16("weaklvl2",150);
		if(GoodOrBad >= 0)oth.set_s16("highjumplvl3",150);
	}
	
	if(fleshplant > 0){
		if(GoodOrBad < 0)oth.set_s16("noheal",600);
		if(GoodOrBad > 0)oth.set_s16("overheallvl3",600);
	}
	if(fleshplant < 0){
		if(GoodOrBad <= 0)oth.set_s16("poisonlvl2",600);
		if(GoodOrBad >= 0)oth.set_s16("bufflvl3",600);
	}
	
	if(consumegrow > 0){
		if(GoodOrBad <= 0)oth.set_s16("drainlvl2",600);
		if(GoodOrBad >= 0)oth.set_s16("lifesteallvl3",600);
	}
	if(consumegrow < 0){
		if(GoodOrBad <= 0)oth.set_s16("stuntlvl2",600);
		if(GoodOrBad >= 0)oth.set_s16("overregenlvl3",600);
	}
	
	
	if(hasteslow > 0)oth.set_s16("hastelvl3",150);
	if(hasteslow < 0)oth.set_s16("slowlvl2",150);
	
	if(cleanseinfect > 0)oth.Tag("cleanse");
	if(cleanseinfect < 0)oth.Tag("infect");
	
	return;
}

void givePlayerEffectBad(CBlob@ this, CBlob@ oth){
	
	if(oth.hasTag("negrunetatoo"))return;
	
	//if (!getNet().isServer())return;
	
	int GoodOrBad = -4;
	
	int firewater = 0;
	int fleshplant = 0;
	int consumegrow = 0;
	int hasteslow = 0;
	int goodevil = 0;
	int healhurt = 0;
	int earthair = 0;
	int chaos = 0;
	int cleanseinfect = 0;
	
	CBlob@[] blobsInRadius;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), 8.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b.hasTag("rune"))
			if(!b.isAttached())
			if(!b.hasTag("curserune")){
				if(b.hasTag("liferune") || b.hasTag("lightrune") || b.hasTag("witnessrune") || b.hasTag("cleanserune") || b.hasTag("hasterune"))GoodOrBad += 1;
				if(b.hasTag("deathrune") || b.hasTag("darkrune") || b.hasTag("curserune") || b.hasTag("infectrune") || b.hasTag("slowrune"))GoodOrBad -= 1;
				
				if(b.hasTag("lightrune"))goodevil += 1;
				if(b.hasTag("darkrune"))goodevil -= 1;
				
				if(b.hasTag("liferune"))healhurt += 1;
				if(b.hasTag("deathrune"))healhurt -= 1;
				
				if(b.hasTag("firerune"))firewater += 1;
				if(b.hasTag("waterrune"))firewater -= 1;
				
				if(b.hasTag("earthrune"))earthair += 1;
				if(b.hasTag("airrune"))earthair -= 1;
				
				if(b.hasTag("fleshrune"))fleshplant += 1;
				if(b.hasTag("plantrune"))fleshplant -= 1;
				
				if(b.hasTag("consumerune"))consumegrow += 1;
				if(b.hasTag("growrune"))consumegrow -= 1;
				
				if(b.hasTag("hasterune"))hasteslow += 1;
				if(b.hasTag("slowrune"))hasteslow -= 1;
				
				if(b.hasTag("chaosrune"))chaos += 1;
				if(b.hasTag("negrune"))chaos -= 1;
				
				if(b.hasTag("cleanserune"))cleanseinfect += 1;
				if(b.hasTag("infectrune"))cleanseinfect -= 1;
			}
		}
	}
	
	for (int i = 0; i < chaos; i++){
		
		if(XORRandom(4) > 2)goodevil += 1;
		if(XORRandom(4) > 2)goodevil -= 1;
		if(XORRandom(4) > 2)healhurt += 1;
		if(XORRandom(4) > 2)healhurt -= 1;
		if(XORRandom(4) > 2)firewater += 1;
		if(XORRandom(4) > 2)firewater -= 1;
		if(XORRandom(4) > 2)earthair += 1;
		if(XORRandom(4) > 2)earthair -= 1;
		if(XORRandom(4) > 2)fleshplant += 1;
		if(XORRandom(4) > 2)fleshplant -= 1;
		if(XORRandom(4) > 2)consumegrow += 1;
		if(XORRandom(4) > 2)consumegrow -= 1;
		if(XORRandom(4) > 2)hasteslow += 1;
		if(XORRandom(4) > 2)hasteslow -= 1;
		if(XORRandom(4) > 2)chaos += 1;
		
	}
	
	if(goodevil > 0){
		if(GoodOrBad > 0)if(oth.hasTag("evil"))return;
		if(GoodOrBad < 0)if(oth.hasTag("holy"))return;
	}
	if(goodevil < 0){
		if(GoodOrBad > 0)if(oth.hasTag("holy"))return;
		if(GoodOrBad < 0)if(oth.hasTag("evil"))return;
	}
	
	if(healhurt > 1)if(oth.getHealth() < oth.getInitialHealth())oth.server_Heal((healhurt-1)*0.25f);
	if(healhurt < 0){
		this.server_Hit(oth, oth.getPosition(), Vec2f(0.0f, 0.0f), healhurt*-0.25, Hitters::suddengib, false);
	}
	
	if(firewater > 0){
		if(GoodOrBad < 0)oth.Tag("firecurse");
		if(GoodOrBad == 0)oth.set_s16("empowerfire",30000);
		if(GoodOrBad > 1)oth.set_s16("empowerfirelvl2",30000);
	}
	
	if(firewater < 0){
		if(GoodOrBad < 0)oth.set_s16("cant_breathe_air",30000);
		if(GoodOrBad == 0)oth.set_s16("empowerwater",30000);
		if(GoodOrBad > 1)oth.set_s16("empowerwaterlvl2",30000);
	}
	
	if(earthair > 0){
		if(GoodOrBad <= 0)oth.set_s16("squatlvl3",30000);
		if(GoodOrBad > 1)oth.set_s16("defenselvl2",30000);
	}
	if(earthair < 0){
		if(GoodOrBad <= 0)oth.set_s16("weaklvl3",30000);
		if(GoodOrBad > 1)oth.set_s16("highjumplvl2",30000);
	}
	
	
	if(fleshplant > 0){
		if(GoodOrBad < 0)oth.set_s16("noheallvl3",30000);
		if(GoodOrBad > 1)oth.set_s16("overheallvl2",30000);
	}
	if(fleshplant < 0){
		if(GoodOrBad <= 0)oth.set_s16("poisonlvl3",30000);
		if(GoodOrBad >= 1)oth.set_s16("bufflvl2",30000);
	}
	
	if(consumegrow > 0){
		oth.set_s16("drainlvl3",30000);
		oth.set_s16("lifesteallvl3",30000);
	}
	if(consumegrow < 0){
		if(GoodOrBad <= 0)oth.set_s16("stuntlvl3",30000);
		if(GoodOrBad >= 1)oth.set_s16("overregenlvl2",30000);
	}
	
	if(hasteslow > 1)oth.set_s16("hastelvl2",30000);
	if(hasteslow < 0)oth.set_s16("slowlvl3",30000);
	
	if(cleanseinfect > 1)oth.Tag("cleanse");
	if(cleanseinfect < 0)oth.Tag("infect");
	
	return;
}