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
	
	CBlob@[] blobsInRadius;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), 8.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b.hasTag("rune"))
			if(!b.hasTag("touchrune")){
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
			}
		}
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
		if(GoodOrBad > 0)oth.set_s16("fire immune",600);
	}
	
	if(firewater < 0){
		if(GoodOrBad < 0)oth.set_s16("cant_breathe_air",1800);
		if(GoodOrBad == 0)oth.set_s16("empowerwater",600);
		if(GoodOrBad > 0)oth.set_s16("cant_drown",1800);
	}
	
	if(earthair > 0){
		if(GoodOrBad <= 0)oth.set_s16("squat",600);
		if(GoodOrBad >= 0)oth.set_s16("defense",600);
	}
	if(earthair < 0){
		if(GoodOrBad <= 0)oth.set_s16("weak",600);
		if(GoodOrBad >= 0)oth.set_s16("highjump",600);
	}
	
	if(fleshplant > 0){
		if(GoodOrBad < 0)oth.set_s16("noheal",600);
		if(GoodOrBad > 0)oth.set_s16("overheal",600);
	}
	if(fleshplant < 0){
		if(GoodOrBad <= 0)oth.set_s16("poison",600);
		if(GoodOrBad >= 0)oth.set_s16("buff",600);
	}
	
	if(consumegrow > 0){
		if(GoodOrBad <= 0)oth.set_s16("drain",600);
		if(GoodOrBad >= 0)oth.set_s16("lifesteal",600);
	}
	if(consumegrow < 0){
		if(GoodOrBad <= 0)oth.set_s16("stunt",600);
		if(GoodOrBad >= 0)oth.set_s16("overregen",600);
	}
	
	
	if(hasteslow > 0)oth.set_s16("haste",600);
	if(hasteslow < 0)oth.set_s16("slow",600);
	
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
	
	CBlob@[] blobsInRadius;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), 8.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b.hasTag("rune"))
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
			}
		}
	}
	
	if(goodevil > 0){
		if(GoodOrBad > 0)if(oth.hasTag("evil"))return;
		if(GoodOrBad < 0)if(oth.hasTag("holy"))return;
	}
	if(goodevil < 0){
		if(GoodOrBad > 0)if(oth.hasTag("holy"))return;
		if(GoodOrBad < 0)if(oth.hasTag("evil"))return;
	}
	
	if(healhurt > 0)oth.server_Heal(healhurt*0.25f);
	//if(healhurt < 0){
	//	this.server_Hit(oth, oth.getPosition(), Vec2f(0.0f, 0.0f), (healhurt-1)*-0.25, Hitters::suddengib, false);
	//}
	
	if(firewater > 0){
		if(GoodOrBad < 0)this.server_Hit(oth, oth.getPosition(), Vec2f(0.0f, 0.0f), 0.25, Hitters::fire, true);
		if(GoodOrBad == 0)oth.set_s16("empowerfire",150);
		if(GoodOrBad > 0)oth.set_s16("fire immune",150);
	}
	
	if(firewater < 0){
		if(GoodOrBad < -1)oth.set_s16("cant_breathe_air",150);
		if(GoodOrBad == 0)oth.set_s16("empowerwater",150);
		if(GoodOrBad > 0)oth.set_s16("cant_drown",150);
	}
	
	if(earthair > 0){
		if(GoodOrBad <= 0)oth.set_s16("squat",150);
		if(GoodOrBad >= 0)oth.set_s16("defense",150);
	}
	if(earthair < 0){
		if(GoodOrBad <= 0)oth.set_s16("weak",150);
		if(GoodOrBad >= 0)oth.set_s16("highjump",150);
	}
	
	if(fleshplant > 0){
		if(GoodOrBad < 0)oth.set_s16("noheal",600);
		if(GoodOrBad > 0)oth.set_s16("overheal",600);
	}
	if(fleshplant < 0){
		if(GoodOrBad <= 0)oth.set_s16("poison",600);
		if(GoodOrBad >= 0)oth.set_s16("buff",600);
	}
	
	if(consumegrow > 0){
		if(GoodOrBad <= 0)oth.set_s16("drain",600);
		if(GoodOrBad >= 0)oth.set_s16("lifesteal",600);
	}
	if(consumegrow < 0){
		if(GoodOrBad <= 0)oth.set_s16("stunt",600);
		if(GoodOrBad >= 0)oth.set_s16("overregen",600);
	}
	
	
	if(hasteslow > 0)oth.set_s16("haste",150);
	if(hasteslow < 0)oth.set_s16("slow",150);
	
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
	
	CBlob@[] blobsInRadius;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), 8.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b.hasTag("rune"))
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
			}
		}
	}
	
	if(goodevil > 0){
		if(GoodOrBad > 0)if(oth.hasTag("evil"))return;
		if(GoodOrBad < 0)if(oth.hasTag("holy"))return;
	}
	if(goodevil < 0){
		if(GoodOrBad > 0)if(oth.hasTag("holy"))return;
		if(GoodOrBad < 0)if(oth.hasTag("evil"))return;
	}
	
	if(healhurt > 1)oth.server_Heal((healhurt-1)*0.25f);
	if(healhurt < 0){
		this.server_Hit(oth, oth.getPosition(), Vec2f(0.0f, 0.0f), healhurt*-0.25, Hitters::suddengib, false);
	}
	
	if(firewater > 0){
		if(GoodOrBad < 0)oth.Tag("firecurse");
		if(GoodOrBad == 0)oth.set_s16("empowerfire",30000);
		if(GoodOrBad > 1)oth.set_s16("fire immune",30000);
	}
	
	if(firewater < 0){
		if(GoodOrBad < 0)oth.set_s16("cant_breathe_air",30000);
		if(GoodOrBad == 0)oth.set_s16("empowerwater",30000);
		if(GoodOrBad > 1)oth.set_s16("cant_drown",30000);
	}
	
	if(earthair > 0){
		if(GoodOrBad <= 0)oth.set_s16("squat",30000);
		if(GoodOrBad > 1)oth.set_s16("defense",30000);
	}
	if(earthair < 0){
		if(GoodOrBad <= 0)oth.set_s16("weak",30000);
		if(GoodOrBad > 1)oth.set_s16("highjump",30000);
	}
	
	
	if(fleshplant > 0){
		if(GoodOrBad < 0)oth.set_s16("noheal",30000);
		if(GoodOrBad > 1)oth.set_s16("overheal",30000);
	}
	if(fleshplant < 0){
		if(GoodOrBad <= 0)oth.set_s16("poison",30000);
		if(GoodOrBad >= 1)oth.set_s16("buff",30000);
	}
	
	if(consumegrow > 0){
		oth.set_s16("drain",30000);
		oth.set_s16("lifesteal",30000);
	}
	if(consumegrow < 0){
		if(GoodOrBad <= 0)oth.set_s16("stunt",30000);
		if(GoodOrBad >= 1)oth.set_s16("overregen",30000);
	}
	
	if(hasteslow > 1)oth.set_s16("haste",30000);
	if(hasteslow < 0)oth.set_s16("slow",30000);
	
	return;
}