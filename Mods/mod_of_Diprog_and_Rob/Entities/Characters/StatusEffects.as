#include "RunnerCommon.as"
#include "FireCommon.as"
#include "Hitters.as"
#include "Polymorph.as";

void onTick(CBlob@ this)
{

	checkTatoos(this);

	if(this.hasTag("undead")){
		this.Tag("evil");
		this.Untag("holy");
	}
	
	if(this.hasTag("cleanse") && !this.hasTag("undead")){
		this.set_s16("slow",0);
		this.set_s16("slowlvl2",0);
		this.set_s16("squat",0);
		this.set_s16("squatlvl2",0);
		this.set_s16("empowerfire",0);
		this.Untag("firecurse");
		this.set_s16("weak",0);
		this.set_s16("weaklvl2",0);
		this.set_s16("cant_breathe_air",0);
		this.set_s16("empowerwater",0);
		this.set_s16("drain",0);
		this.set_s16("drainlvl2",0);
		this.set_s16("poison",0);
		this.set_s16("poisonlvl2",0);
		this.set_s16("noheal",0);
		this.set_s16("stunt",0);
		this.set_s16("stuntlvl2",0);
		this.Untag("infect");
	}
	this.Untag("cleanse");
	
	if(this.hasTag("infect") || this.hasTag("infectrunetatoo")){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 16.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b.hasTag("flesh") && !b.hasTag("infectrunetatoo"))if(!this.hasTag("infectrunetatoo") || b.getTeamNum() != this.getTeamNum()){
					b.set_s16("slow",this.get_s16("slow"));
					b.set_s16("squat",this.get_s16("squat"));
					b.set_s16("weak",this.get_s16("weak"));
					b.set_s16("poison",this.get_s16("poison"));
					b.set_s16("slowlvl2",this.get_s16("slowlvl2"));
					b.set_s16("squatlvl2",this.get_s16("squatlvl2"));
					b.set_s16("weaklvl2",this.get_s16("weaklvl2"));
					b.set_s16("poisonlvl2",this.get_s16("poisonlvl2"));
					b.set_s16("slowlvl3",this.get_s16("slowlvl3"));
					b.set_s16("squatlvl3",this.get_s16("squatlvl3"));
					b.set_s16("weaklvl3",this.get_s16("weaklvl3"));
					b.set_s16("poisonlvl3",this.get_s16("poisonlvl3"));
					b.set_s16("noheal",this.get_s16("noheal"));
					b.Tag("infect");
				}
			}
		}
	}
	
	RunnerMoveVars@ moveVars;
	if(this.get("moveVars", @moveVars))
	{
		moveVars.jumpFactor = 1.0f;
	}
	if(this.get_s16("slow") > 0){
		if(this.get("moveVars", @moveVars))
		{
			moveVars.walkFactor *= 0.5f;
		}
		this.set_s16("slow",this.get_s16("slow")-1);
	}
	if(this.get_s16("slowlvl2") > 0){
		if(this.get("moveVars", @moveVars))
		{
			moveVars.walkFactor *= 0.25f;
		}
		this.set_s16("slowlvl2",this.get_s16("slowlvl2")-1);
	}
	if(this.get_s16("slowlvl3") > 0){
		if(this.get("moveVars", @moveVars))
		{
			moveVars.walkFactor *= 0.0f;
		}
		this.set_s16("slowlvl3",this.get_s16("slowlvl3")-1);
	}
	if(this.get_s16("haste") > 0){
		if(this.get("moveVars", @moveVars))
		{
			moveVars.walkFactor *= 1.2f;
		}
		this.set_s16("haste",this.get_s16("haste")-1);
	}
	if(this.get_s16("hastelvl2") > 0){
		if(this.get("moveVars", @moveVars))
		{
			moveVars.walkFactor *= 1.5f;
		}
		this.set_s16("hastelvl2",this.get_s16("hastelvl2")-1);
	}
	if(this.get_s16("hastelvl3") > 0){
		if(this.get("moveVars", @moveVars))
		{
			moveVars.walkFactor *= 2.0f;
		}
		this.set_s16("hastelvl3",this.get_s16("hastelvl3")-1);
	}
	
	if(this.get_s16("squat") > 0){
		if(this.get("moveVars", @moveVars))
		{
			moveVars.jumpFactor *= 0.5f;
		}
		this.set_s16("squat",this.get_s16("squat")-1);
	}
	if(this.get_s16("squatlvl2") > 0){
		if(this.get("moveVars", @moveVars))
		{
			moveVars.jumpFactor *= 0.2f;
		}
		this.set_s16("squatlvl2",this.get_s16("squatlvl2")-1);
	}
	if(this.get_s16("squatlvl3") > 0){
		if(this.get("moveVars", @moveVars))
		{
			moveVars.jumpFactor *= 0.0f;
		}
		this.set_s16("squatlvl3",this.get_s16("squatlvl3")-1);
	}
	if(this.get_s16("highjump") > 0){
		if(this.get("moveVars", @moveVars))
		{
			moveVars.jumpFactor *= 2.0f;
		}
		this.set_s16("highjump",this.get_s16("highjump")-1);
	}
	if(this.get_s16("highjumplvl2") > 0){
		if(this.get("moveVars", @moveVars))
		{
			moveVars.jumpFactor *= 3.0f;
		}
		this.set_s16("highjumplvl2",this.get_s16("highjumplvl2")-1);
	}
	if(this.get_s16("highjumplvl3") > 0){
		this.Tag("flying");
		this.set_s16("highjumplvl3",this.get_s16("highjumplvl3")-1);
	} else this.Untag("flying");
	
	////////////FIRE//////////////
	if(this.get_s16("empowerfire") > 0)this.set_s16("empowerfire",this.get_s16("empowerfire")-1);
	if(this.get_s16("empowerfirelvl2") > 0){
		server_setFireOff(this);
		this.set_s16("empowerfirelvl2",this.get_s16("empowerfirelvl2")-1);
	}
	if(this.get_s16("empowerfirelvl3") > 0){
		server_setFireOff(this);
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if((b.hasTag("flesh") || b.hasTag("plant")) && !b.hasTag("infectrunetatoo") && b.getTeamNum() != this.getTeamNum()){
					if(!b.hasTag("empowerfirelvl3") && !b.hasTag("empowerfirelvl2"))if(!b.hasTag("burning"))this.server_Hit(b, b.getPosition(), Vec2f(0.0f, 0.0f), 0.25, Hitters::fire, true);
				}
			}
		}
		this.set_s16("empowerfirelvl3",this.get_s16("empowerfirelvl3")-1);
	}
	if(this.hasTag("firecurse")){
		if(!this.hasTag("burning"))server_setFireOn(this);
	}
	/////////////////////
	
	
	/////////////Water//////////////////
	if(this.get_s16("empowerwater") > 0){
		this.set_s16("empowerwater",this.get_s16("empowerwater")-1);
	}
	if(this.get_s16("empowerwaterlvl2") > 0)this.set_s16("empowerwaterlvl2",this.get_s16("empowerwaterlvl2")-1);
	if(this.get_s16("empowerwaterlvl3") > 0){
		server_setFireOff(this);
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 96.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b.hasTag("flesh") && !b.hasTag("infectrunetatoo") && b.getTeamNum() != this.getTeamNum()){
					if(!b.hasTag("empowerwaterlvl3") && !b.hasTag("empowerwaterlvl2"))b.set_s16("cant_breathe_air",10);
				}
			}
		}
		this.set_s16("empowerwaterlvl3",this.get_s16("empowerwaterlvl3")-1);
	}
	if(this.get_s16("cant_breathe_air") > 0)this.set_s16("cant_breathe_air",this.get_s16("cant_breathe_air")-1);
	///////////////////
	
	
	
	if(this.get_s16("blessed") > 0)this.set_s16("blessed",this.get_s16("blessed")-1);
	if(this.get_s16("defense") > 0)this.set_s16("defense",this.get_s16("defense")-1);
	if(this.get_s16("defenselvl2") > 0)this.set_s16("defenselvl2",this.get_s16("defenselvl2")-1);
	if(this.get_s16("defenselvl3") > 0)this.set_s16("defenselvl3",this.get_s16("defenselvl3")-1);
	if(this.get_s16("buff") > 0)this.set_s16("buff",this.get_s16("buff")-1);
	if(this.get_s16("bufflvl2") > 0)this.set_s16("bufflvl2",this.get_s16("bufflvl2")-1);
	if(this.get_s16("bufflvl3") > 0)this.set_s16("bufflvl3",this.get_s16("bufflvl3")-1);
	if(this.get_s16("weak") > 0)this.set_s16("weak",this.get_s16("weak")-1);
	if(this.get_s16("weaklvl2") > 0)this.set_s16("weaklvl2",this.get_s16("weaklvl2")-1);
	if(this.get_s16("weaklvl3") > 0)this.set_s16("weaklvl3",this.get_s16("weaklvl3")-1);
	
	
	
	
	if(this.get_s16("lifesteal") > 0)this.set_s16("lifesteal",this.get_s16("lifesteal")-1);
	if(this.get_s16("lifesteallvl2") > 0)this.set_s16("lifesteallvl2",this.get_s16("lifesteallvl2")-1);
	if(this.get_s16("lifesteallvl3") > 0)this.set_s16("lifesteallvl3",this.get_s16("lifesteallvl3")-1);
	
	if(this.get_s16("temp_statis") > 0)this.set_s16("temp_statis",this.get_s16("temp_statis")-1);
	
	
	
	if(this.get_s16("overheal") > 0){
		if(this.getHealth() == this.getInitialHealth())this.server_SetHealth(this.getInitialHealth()+0.5);
		this.set_s16("overheal",this.get_s16("overheal")-1);
	}
	if(this.get_s16("overheallvl2") > 0){
		if(this.getHealth() == this.getInitialHealth())this.server_SetHealth(this.getInitialHealth()+1.0);
		this.set_s16("overheallvl2",this.get_s16("overheallvl2")-1);
	}
	if(this.get_s16("overheallvl3") > 0){
		if(this.getHealth() == this.getInitialHealth())this.server_SetHealth(this.getInitialHealth()+1.5);
		this.set_s16("overheallvl3",this.get_s16("overheallvl3")-1);
	}
	
	
	if(this.get_s16("poison") > 0)this.set_s16("poison",this.get_s16("poison")-1);
	if(this.get_s16("poisonlvl2") > 0)this.set_s16("poisonlvl2",this.get_s16("poisonlvl2")-1);
	if(this.get_s16("poisonlvl3") > 0)this.set_s16("poisonlvl3",this.get_s16("poisonlvl3")-1);
	if(this.get_s16("overregen") > 0)this.set_s16("overregen",this.get_s16("overregen")-1);
	if(this.get_s16("overregenlvl2") > 0)this.set_s16("overregenlvl2",this.get_s16("overregenlvl2")-1);
	if(this.get_s16("overregenlvl3") > 0)this.set_s16("overregenlvl3",this.get_s16("overregenlvl3")-1);
	if(this.get_s16("drain") > 0)this.set_s16("drain",this.get_s16("drain")-1);
	if(this.get_s16("drainlvl2") > 0)this.set_s16("drainlvl2",this.get_s16("drainlvl2")-1);
	if(this.get_s16("drainlvl3") > 0)this.set_s16("drainlvl3",this.get_s16("drainlvl3")-1);
	
	if(this.get_s16("statustimer") > 60){
		
		if(this.get_s16("drain") > 0)if(this.getHealth() > 0.125)this.server_SetHealth(this.getHealth()-0.125f);
		if(this.get_s16("drainlvl2") > 0)if(this.getHealth() > 0.25)this.server_SetHealth(this.getHealth()-0.25f);
		if(this.get_s16("drainlvl3") > 0)if(this.getHealth() > 0.375)this.server_SetHealth(this.getHealth()-0.375f);
		if(this.get_s16("overregen") > 0)if(this.getHealth() < this.getInitialHealth()*1.5)this.server_SetHealth(this.getHealth()+0.125f);
		if(this.get_s16("overregenlvl2") > 0)if(this.getHealth() < this.getInitialHealth()*2.5)this.server_SetHealth(this.getHealth()+0.125f);
		if(this.get_s16("overregenlvl3") > 0)if(this.getHealth() < this.getInitialHealth()*5)this.server_SetHealth(this.getHealth()+0.125f);
		if(this.get_s16("poison") > 0)this.server_Hit(this, this.getPosition(), Vec2f(0.0f, 0.0f), 0.25, Hitters::suddengib, false);
		if(this.get_s16("poisonlvl2") > 0)this.server_Hit(this, this.getPosition(), Vec2f(0.0f, 0.0f), 0.5, Hitters::suddengib, false);
		if(this.get_s16("poisonlvl3") > 0)this.server_Hit(this, this.getPosition(), Vec2f(0.0f, 0.0f), 1.0, Hitters::suddengib, false);
		
		this.set_s16("statustimer",0);
	} else this.set_s16("statustimer",this.get_s16("statustimer")+1);
	
	if(this.get_s16("stunt") > 0){
		if(this.getHealth() > this.getInitialHealth()/1.5)this.server_SetHealth(this.getInitialHealth()/1.5);
		this.set_s16("stunt",this.get_s16("stunt")-1);
	}
	if(this.get_s16("stuntlvl2") > 0){
		if(this.getHealth() > this.getInitialHealth()/2)this.server_SetHealth(this.getInitialHealth()/2);
		this.set_s16("stuntlvl2",this.get_s16("stuntlvl2")-1);
	}
	if(this.get_s16("stuntlvl3") > 0){
		if(this.getHealth() > this.getInitialHealth()/4)this.server_SetHealth(this.getInitialHealth()/4);
		this.set_s16("stuntlvl3",this.get_s16("stuntlvl3")-1);
	}
	
	if(this.get_s16("noheal") > 0 && this.getHealth() >= this.get_f32("nohealvar"))this.set_s16("noheal",this.get_s16("noheal")-1);
	else this.set_f32("nohealvar",this.getHealth());
	this.server_SetHealth(this.get_f32("nohealvar"));
}


f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	f32 dmg = damage;
	
	if(dmg <= 0)return dmg;
	
	if(this.get_s16("blessed") > 0)dmg -= 0.5f;
	
	if(Hitters::suddengib != customData){
		if(this.get_s16("weak") > 0)dmg *= 1.25f;
		if(this.get_s16("weaklvl2") > 0)dmg *= 1.5f;
		if(this.get_s16("weaklvl3") > 0)dmg *= 2.0f;
		if(this.get_s16("defense") > 0)dmg -= 0.25f;
		if(this.get_s16("defenselvl2") > 0)dmg -= 0.5f;
		if(this.get_s16("defenselvl3") > 0)dmg -= 1.0f;
		if(this.get_s16("buff") > 0)dmg *= 0.75f;
		if(this.get_s16("bufflvl2") > 0)dmg *= 0.5f;
		if(this.get_s16("bufflvl3") > 0)dmg *= 0.25f;
	}
	
	if(dmg <= 0)dmg = 0.25;
	
	if(this.hasTag("slowrunetatoo"))hitterBlob.set_s16("slowlvl1",300);
	if(this.hasTag("slowrunetatoo"))if(this.getName() == "runemaster")hitterBlob.set_s16("slowlvl2",300);
	if(this.hasTag("slowrunetatoo"))if(this.getName() == "necro")hitterBlob.set_s16("slowlvl3",300);
	
	if(this.hasTag("telerunetatoo")){
		this.setPosition(Vec2f(this.getPosition().x+XORRandom(64)-32,this.getPosition().y+XORRandom(64)-32));
	}
	if(this.hasTag("chaosrunetatoo")){
		if(XORRandom(16) > 2)if(this.getHealth() < this.getInitialHealth())this.server_Heal(0.5f);
		if(XORRandom(8) > 2)this.server_Hit(this, this.getPosition(), Vec2f(0.0f, 0.0f), 0.5f, Hitters::suddengib, false);
		if(XORRandom(16) > 2)this.set_s16("cant_breathe_air",1800);
		if(XORRandom(16) > 2)this.set_s16("squat",600);
		if(XORRandom(8) > 2)this.set_s16("defense",600);
		if(XORRandom(16) > 2)this.set_s16("weak",600);
		if(XORRandom(8) > 2)this.set_s16("highjump",600);
		if(XORRandom(16) > 2)this.set_s16("noheal",600);
		if(XORRandom(8) > 2)this.set_s16("overheal",600);
		if(XORRandom(16) > 2)this.set_s16("poison",600);
		if(XORRandom(8) > 2)this.set_s16("buff",600);
		if(XORRandom(16) > 2)this.set_s16("drain",600);
		if(XORRandom(8) > 2)this.set_s16("lifesteal",600);
		if(XORRandom(16) > 2)this.set_s16("stunt",600);
		if(XORRandom(16) > 2)this.set_s16("overregen",600);
		if(XORRandom(8) > 2)this.set_s16("haste",600);
		if(XORRandom(16) > 2)this.set_s16("slow",600);
		if(XORRandom(16) > 2)this.Tag("infect");
		
		if(XORRandom(16) > 2)if(hitterBlob.getHealth() < hitterBlob.getInitialHealth())hitterBlob.server_Heal(0.5f);
		if(XORRandom(8) > 2)this.server_Hit(hitterBlob, hitterBlob.getPosition(), Vec2f(0.0f, 0.0f), 0.5f, Hitters::suddengib, false);
		if(XORRandom(8) > 2)hitterBlob.set_s16("cant_breathe_air",1800);
		if(XORRandom(8) > 2)hitterBlob.set_s16("squat",600);
		if(XORRandom(16) > 2)hitterBlob.set_s16("defense",600);
		if(XORRandom(8) > 2)hitterBlob.set_s16("weak",600);
		if(XORRandom(16) > 2)hitterBlob.set_s16("highjump",600);
		if(XORRandom(8) > 2)hitterBlob.set_s16("noheal",600);
		if(XORRandom(16) > 2)hitterBlob.set_s16("overheal",600);
		if(XORRandom(8) > 2)hitterBlob.set_s16("poison",600);
		if(XORRandom(16) > 2)hitterBlob.set_s16("buff",600);
		if(XORRandom(8) > 2)hitterBlob.set_s16("drain",600);
		if(XORRandom(16) > 2)hitterBlob.set_s16("lifesteal",600);
		if(XORRandom(8) > 2)hitterBlob.set_s16("stunt",600);
		if(XORRandom(16) > 2)hitterBlob.set_s16("overregen",600);
		if(XORRandom(8) > 2)hitterBlob.set_s16("haste",600);
		if(XORRandom(16) > 2)hitterBlob.set_s16("slow",600);
		if(XORRandom(8) > 2)hitterBlob.Tag("infect");
	}
	
	if(this.hasTag("liferunetatoo"))if(this.getHealth()*2-dmg <= 0){
		dmg = 0;
		this.server_SetHealth(this.getInitialHealth()*2);
		this.Untag("dead");
		this.Untag("liferunetatoo");
	}
	if(this.hasTag("polyrunetatoo"))if(this.getHealth()*2-dmg <= 0){
		dmg = 0;
		this.server_SetHealth(this.getInitialHealth()*2);
		this.Untag("dead");
		this.Untag("polyrunetatoo");
		Polymorph(this, "polygolem", 150);
	}
	if (getNet().isServer())
	if(this.hasTag("deathrunetatoo"))if(this.getHealth()*2-dmg <= 0){
		if(this.getName() != "necro"){
			server_CreateBlob("zombie", this.getTeamNum(), this.getPosition()); 
			this.server_Die();
		} else {
			Polymorph(this, "ghoul", 30000);
		}
	}
	
	return dmg; //no block, damage goes through
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	
	if(this.get_s16("lifesteal") > 0)if(hitBlob.hasTag("flesh"))this.server_SetHealth(this.getHealth()+damage*0.25f);
	if(this.get_s16("lifesteallvl2") > 0)if(hitBlob.hasTag("flesh"))this.server_SetHealth(this.getHealth()+damage*0.5f);
	if(this.get_s16("lifesteallvl3") > 0)if(hitBlob.hasTag("flesh"))this.server_SetHealth(this.getHealth()+damage);
	
	return;
}

void checkTatoos(CBlob@ this){
	if(this.hasTag("firerunetatoo")){
		this.set_s16("empowerfire",10);
		this.set_s16("empowerfirelvl2",10);
	}
	if(this.hasTag("waterrunetatoo")){
		this.set_s16("empowerwater",10);
		this.set_s16("empowerwaterlvl2",10);
	}
	if(this.hasTag("earthrunetatoo")){
		if(this.getName() == "runemaster")this.set_s16("defenselvl2",10);
		else this.set_s16("defense",10);
	}
	if(this.hasTag("airrunetatoo")){
		if(this.getName() == "runemaster")this.set_s16("highjumplvl2",10);
		else this.set_s16("highjump",10);
	}
	
	if(this.hasTag("fleshrunetatoo")){
		if(this.getName() == "runemaster")this.set_s16("overheallvl2",10);
		else this.set_s16("overheal",10);
	}
	if(this.hasTag("consumerunetatoo")){
		if(this.getName() == "runemaster")this.set_s16("lifesteallvl2",10);
		else this.set_s16("lifesteal",10);
	}
	if(this.hasTag("plantrunetatoo")){
		if(this.getName() == "runemaster")this.set_s16("bufflvl2",10);
		else this.set_s16("buff",10);
	}
	if(this.hasTag("growrunetatoo")){
		if(this.getName() == "runemaster")this.set_s16("overregenlvl2",10);
		else this.set_s16("overregen",10);
	}
	
	if(this.hasTag("lightrunetatoo") || this.hasTag("holy")){
		this.Tag("holy");
		this.Untag("darkrunetatoo");
		this.Untag("deathrunetatoo");
		this.Untag("slowrunetatoo");
		this.Untag("infectrunetatoo");
	}
	if(this.hasTag("darkrunetatoo") || this.hasTag("evil")){
		this.Tag("evil");
		this.Untag("lightrunetatoo");
		this.Untag("liferunetatoo");
		this.Untag("hasterunetatoo");
		this.Untag("curerunetatoo");
	}
	
	if(this.hasTag("hasterunetatoo")){
		if(this.getName() == "runemaster")this.set_s16("hastelvl2",10);
		else this.set_s16("haste",10);
	}
	if(this.hasTag("curerunetatoo"))this.Tag("cleanse");
	
	
	
}


//////////////////////////Sprites!!!!!!!!!!!!!/////////////////////




void onInit(CSprite@ this)
{
	{
		this.RemoveSpriteLayer("halo");
		CSpriteLayer@ genericstatuseffect = this.addSpriteLayer("halo", "StatusEffects.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (genericstatuseffect !is null)
		{
			Animation@ anim = genericstatuseffect.addAnimation("default", 0, false);
			anim.AddFrame(0);
			genericstatuseffect.SetOffset(Vec2f(0,0));
			genericstatuseffect.SetAnimation("default");
			genericstatuseffect.SetVisible(false);
			genericstatuseffect.SetRelativeZ(2.0f);
		}
	}
	{
		this.RemoveSpriteLayer("blessing");
		CSpriteLayer@ genericstatuseffect = this.addSpriteLayer("blessing", "StatusEffects.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (genericstatuseffect !is null)
		{
			Animation@ anim = genericstatuseffect.addAnimation("default", 0, false);
			anim.AddFrame(1);
			genericstatuseffect.SetOffset(Vec2f(0,0));
			genericstatuseffect.SetAnimation("default");
			genericstatuseffect.SetVisible(false);
			genericstatuseffect.SetRelativeZ(2.0f);
		}
	}
	{
		this.RemoveSpriteLayer("plague");
		CSpriteLayer@ genericstatuseffect = this.addSpriteLayer("plague", "StatusEffects.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (genericstatuseffect !is null)
		{
			Animation@ anim = genericstatuseffect.addAnimation("default", 0, false);
			anim.AddFrame(5);
			genericstatuseffect.SetOffset(Vec2f(0,0));
			genericstatuseffect.SetAnimation("default");
			genericstatuseffect.SetVisible(false);
			genericstatuseffect.SetRelativeZ(2.0f);
		}
	}
	{
		this.RemoveSpriteLayer("haste");
		CSpriteLayer@ genericstatuseffect = this.addSpriteLayer("haste", "StatusEffects.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (genericstatuseffect !is null)
		{
			Animation@ anim = genericstatuseffect.addAnimation("default", 0, false);
			anim.AddFrame(3);
			genericstatuseffect.SetOffset(Vec2f(0,0));
			genericstatuseffect.SetAnimation("default");
			genericstatuseffect.SetVisible(false);
			genericstatuseffect.SetRelativeZ(2.0f);
		}
	}
	{
		this.RemoveSpriteLayer("slow");
		CSpriteLayer@ genericstatuseffect = this.addSpriteLayer("slow", "StatusEffects.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (genericstatuseffect !is null)
		{
			Animation@ anim = genericstatuseffect.addAnimation("default", 0, false);
			anim.AddFrame(4);
			genericstatuseffect.SetOffset(Vec2f(0,0));
			genericstatuseffect.SetAnimation("default");
			genericstatuseffect.SetVisible(false);
			genericstatuseffect.SetRelativeZ(2.0f);
		}
	}
	{
		this.RemoveSpriteLayer("jump");
		CSpriteLayer@ genericstatuseffect = this.addSpriteLayer("jump", "StatusEffects.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (genericstatuseffect !is null)
		{
			Animation@ anim = genericstatuseffect.addAnimation("default", 0, false);
			anim.AddFrame(6);
			genericstatuseffect.SetOffset(Vec2f(0,0));
			genericstatuseffect.SetAnimation("default");
			genericstatuseffect.SetVisible(false);
			genericstatuseffect.SetRelativeZ(2.0f);
		}
	}
	{
		this.RemoveSpriteLayer("squat");
		CSpriteLayer@ genericstatuseffect = this.addSpriteLayer("squat", "StatusEffects.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (genericstatuseffect !is null)
		{
			Animation@ anim = genericstatuseffect.addAnimation("default", 0, false);
			anim.AddFrame(7);
			genericstatuseffect.SetOffset(Vec2f(0,0));
			genericstatuseffect.SetAnimation("default");
			genericstatuseffect.SetVisible(false);
			genericstatuseffect.SetRelativeZ(2.0f);
		}
	}
	{
		this.RemoveSpriteLayer("water");
		CSpriteLayer@ genericstatuseffect = this.addSpriteLayer("water", "StatusEffects.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (genericstatuseffect !is null)
		{
			Animation@ anim = genericstatuseffect.addAnimation("default", 0, false);
			anim.AddFrame(9);
			genericstatuseffect.SetOffset(Vec2f(0,-2));
			genericstatuseffect.SetAnimation("default");
			genericstatuseffect.SetVisible(false);
			genericstatuseffect.SetRelativeZ(2.0f);
		}
	}
	{
		this.RemoveSpriteLayer("fire");
		CSpriteLayer@ genericstatuseffect = this.addSpriteLayer("fire", "StatusEffects.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (genericstatuseffect !is null)
		{
			Animation@ anim = genericstatuseffect.addAnimation("default", 0, false);
			anim.AddFrame(8);
			genericstatuseffect.SetOffset(Vec2f(0,-2));
			genericstatuseffect.SetAnimation("default");
			genericstatuseffect.SetVisible(false);
			genericstatuseffect.SetRelativeZ(2.0f);
		}
	}
	{
		this.RemoveSpriteLayer("cursefire");
		CSpriteLayer@ genericstatuseffect = this.addSpriteLayer("cursefire", "StatusEffects.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (genericstatuseffect !is null)
		{
			Animation@ anim = genericstatuseffect.addAnimation("default", 0, false);
			anim.AddFrame(10);
			genericstatuseffect.SetOffset(Vec2f(0,0));
			genericstatuseffect.SetAnimation("default");
			genericstatuseffect.SetVisible(false);
			genericstatuseffect.SetRelativeZ(2.0f);
		}
	}
	{
		this.RemoveSpriteLayer("rockshield");
		CSpriteLayer@ genericstatuseffect = this.addSpriteLayer("rockshield", "StatusEffects.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (genericstatuseffect !is null)
		{
			Animation@ anim = genericstatuseffect.addAnimation("default", 0, false);
			anim.AddFrame(11);
			genericstatuseffect.SetOffset(Vec2f(0,0));
			genericstatuseffect.SetAnimation("default");
			genericstatuseffect.SetVisible(false);
			genericstatuseffect.SetRelativeZ(2.0f);
		}
	}
	{
		this.RemoveSpriteLayer("timbershield");
		CSpriteLayer@ genericstatuseffect = this.addSpriteLayer("timbershield", "StatusEffects.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (genericstatuseffect !is null)
		{
			Animation@ anim = genericstatuseffect.addAnimation("default", 0, false);
			anim.AddFrame(12);
			genericstatuseffect.SetOffset(Vec2f(0,0));
			genericstatuseffect.SetAnimation("default");
			genericstatuseffect.SetVisible(false);
			genericstatuseffect.SetRelativeZ(2.0f);
		}
	}
	{
		this.RemoveSpriteLayer("lifedrain");
		CSpriteLayer@ genericstatuseffect = this.addSpriteLayer("lifedrain", "StatusEffects.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (genericstatuseffect !is null)
		{
			Animation@ anim = genericstatuseffect.addAnimation("default", 0, false);
			anim.AddFrame(13);
			genericstatuseffect.SetOffset(Vec2f(0,-24));
			genericstatuseffect.SetAnimation("default");
			genericstatuseffect.SetVisible(false);
			genericstatuseffect.SetRelativeZ(2.0f);
		}
	}
	{
		this.RemoveSpriteLayer("lifesteal");
		CSpriteLayer@ genericstatuseffect = this.addSpriteLayer("lifesteal", "StatusEffects.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (genericstatuseffect !is null)
		{
			Animation@ anim = genericstatuseffect.addAnimation("default", 0, false);
			anim.AddFrame(14);
			genericstatuseffect.SetOffset(Vec2f(0,-24));
			genericstatuseffect.SetAnimation("default");
			genericstatuseffect.SetVisible(false);
			genericstatuseffect.SetRelativeZ(2.0f);
		}
	}
	{
		this.RemoveSpriteLayer("overregen");
		CSpriteLayer@ genericstatuseffect = this.addSpriteLayer("overregen", "StatusEffects.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (genericstatuseffect !is null)
		{
			Animation@ anim = genericstatuseffect.addAnimation("default", 0, false);
			anim.AddFrame(15);
			genericstatuseffect.SetOffset(Vec2f(0,-24));
			genericstatuseffect.SetAnimation("default");
			genericstatuseffect.SetVisible(false);
			genericstatuseffect.SetRelativeZ(2.0f);
		}
	}
	{
		this.RemoveSpriteLayer("poison");
		CSpriteLayer@ genericstatuseffect = this.addSpriteLayer("poison", "StatusEffects.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (genericstatuseffect !is null)
		{
			Animation@ anim = genericstatuseffect.addAnimation("default", 0, false);
			anim.AddFrame(16);
			genericstatuseffect.SetOffset(Vec2f(0,-24));
			genericstatuseffect.SetAnimation("default");
			genericstatuseffect.SetVisible(false);
			genericstatuseffect.SetRelativeZ(2.0f);
		}
	}
	{
		this.RemoveSpriteLayer("brokenheart");
		CSpriteLayer@ genericstatuseffect = this.addSpriteLayer("brokenheart", "StatusEffects.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (genericstatuseffect !is null)
		{
			Animation@ anim = genericstatuseffect.addAnimation("default", 0, false);
			anim.AddFrame(17);
			genericstatuseffect.SetOffset(Vec2f(0,-24));
			genericstatuseffect.SetAnimation("default");
			genericstatuseffect.SetVisible(false);
			genericstatuseffect.SetRelativeZ(2.0f);
		}
	}
	{
		this.RemoveSpriteLayer("statis");
		CSpriteLayer@ genericstatuseffect = this.addSpriteLayer("statis", "StatusEffects.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (genericstatuseffect !is null)
		{
			Animation@ anim = genericstatuseffect.addAnimation("default", 0, false);
			anim.AddFrame(18);
			genericstatuseffect.SetOffset(Vec2f(0,0));
			genericstatuseffect.SetAnimation("default");
			genericstatuseffect.SetVisible(false);
			genericstatuseffect.SetRelativeZ(2.0f);
		}
	}
	{
		this.RemoveSpriteLayer("cure");
		CSpriteLayer@ genericstatuseffect = this.addSpriteLayer("cure", "StatusEffects.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (genericstatuseffect !is null)
		{
			Animation@ anim = genericstatuseffect.addAnimation("default", 0, false);
			anim.AddFrame(19);
			genericstatuseffect.SetOffset(Vec2f(0,-24));
			genericstatuseffect.SetAnimation("default");
			genericstatuseffect.SetVisible(false);
			genericstatuseffect.SetRelativeZ(2.0f);
		}
	}
	{
		this.RemoveSpriteLayer("haunt");
		CSpriteLayer@ genericstatuseffect = this.addSpriteLayer("haunt", "StatusEffects.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (genericstatuseffect !is null)
		{
			Animation@ anim = genericstatuseffect.addAnimation("default", 0, false);
			anim.AddFrame(20);
			genericstatuseffect.SetOffset(Vec2f(0,0));
			genericstatuseffect.SetAnimation("default");
			genericstatuseffect.SetVisible(false);
			genericstatuseffect.SetRelativeZ(-0.1f);
		}
	}
}

void onTick(CSprite@ this)
{
	// store some vars for ease and speed
	CBlob@ blob = this.getBlob();

	this.getSpriteLayer("halo").SetVisible(false);
	if(!blob.hasTag("dead"))if(blob.hasTag("liferunetatoo"))this.getSpriteLayer("halo").SetVisible(true);
	
	this.getSpriteLayer("blessing").SetVisible(false);
	if(!blob.hasTag("dead"))if(blob.get_s16("blessed") > 0)this.getSpriteLayer("blessing").SetVisible(true);
	
	this.getSpriteLayer("plague").SetVisible(false);
	if(!blob.hasTag("dead"))if(blob.hasTag("infect") || blob.hasTag("infectrunetatoo"))this.getSpriteLayer("plague").SetVisible(true);
	
	this.getSpriteLayer("haste").SetVisible(false);
	if(!blob.hasTag("dead"))if(blob.get_s16("haste") > 0 || blob.get_s16("hastelvl2") > 0 || blob.get_s16("hastelvl3") > 0)this.getSpriteLayer("haste").SetVisible(true);
	this.getSpriteLayer("slow").SetVisible(false);
	if(!blob.hasTag("dead"))if(blob.get_s16("slow") > 0 || blob.get_s16("slowlvl2") > 0 || blob.get_s16("slowlvl3") > 0)this.getSpriteLayer("slow").SetVisible(true);
	
	this.getSpriteLayer("jump").SetVisible(false);
	if(!blob.hasTag("dead"))if(blob.get_s16("highjump") > 0 || blob.get_s16("highjumplvl2") > 0 || blob.get_s16("highjumplvl3") > 0)this.getSpriteLayer("jump").SetVisible(true);
	this.getSpriteLayer("squat").SetVisible(false);
	if(!blob.hasTag("dead"))if(blob.get_s16("squat") > 0 || blob.get_s16("squatlvl2") > 0 || blob.get_s16("squatlvl3") > 0)this.getSpriteLayer("squat").SetVisible(true);
	
	this.getSpriteLayer("water").SetVisible(false);
	if(!blob.hasTag("dead"))if(blob.getName() != "waterman")if(blob.get_s16("empowerwater") > 0 || blob.get_s16("empowerwaterlvl2") > 0 || blob.get_s16("empowerwaterlvl3") > 0)this.getSpriteLayer("water").SetVisible(true);
	this.getSpriteLayer("fire").SetVisible(false);
	if(!blob.hasTag("dead"))if(blob.get_s16("empowerfire") > 0 || blob.get_s16("empowerfirelvl2") > 0 || blob.get_s16("empowerfirelvl3") > 0)this.getSpriteLayer("fire").SetVisible(true);
	
	this.getSpriteLayer("cursefire").SetVisible(false);
	if(!blob.hasTag("dead"))if(blob.hasTag("firecurse"))this.getSpriteLayer("cursefire").SetVisible(true);
	
	this.getSpriteLayer("rockshield").SetVisible(false);
	if(!blob.hasTag("dead"))if(blob.get_s16("defense") > 0 || blob.get_s16("defenselvl2") > 0 || blob.get_s16("defenselvl3") > 0)this.getSpriteLayer("rockshield").SetVisible(true);
	this.getSpriteLayer("timbershield").SetVisible(false);
	if(!blob.hasTag("dead"))if(blob.get_s16("buff") > 0 || blob.get_s16("bufftlvl2") > 0 || blob.get_s16("bufflvl3") > 0)this.getSpriteLayer("timbershield").SetVisible(true);
	
	this.getSpriteLayer("lifedrain").SetVisible(false);
	if(!blob.hasTag("dead"))if(blob.get_s16("drain") > 0 || blob.get_s16("drainlvl2") > 0 || blob.get_s16("drainlvl3") > 0)this.getSpriteLayer("lifedrain").SetVisible(true);
	this.getSpriteLayer("lifesteal").SetVisible(false);
	if(!blob.hasTag("dead"))if(blob.get_s16("lifesteal") > 0 || blob.get_s16("lifesteallvl2") > 0 || blob.get_s16("lifesteallvl3") > 0)this.getSpriteLayer("lifesteal").SetVisible(true);
	this.getSpriteLayer("overregen").SetVisible(false);
	if(!blob.hasTag("dead"))if(blob.get_s16("overregen") > 0 || blob.get_s16("overregenlvl2") > 0 || blob.get_s16("overregenlvl3") > 0)this.getSpriteLayer("overregen").SetVisible(true);
	this.getSpriteLayer("poison").SetVisible(false);
	if(!blob.hasTag("dead"))if(blob.get_s16("poison") > 0 || blob.get_s16("poisonlvl2") > 0 || blob.get_s16("poisonlvl3") > 0)this.getSpriteLayer("poison").SetVisible(true);
	
	this.getSpriteLayer("brokenheart").SetVisible(false);
	if(!blob.hasTag("dead"))if(blob.get_s16("stunt") > 0 || blob.get_s16("stuntlvl2") > 0 || blob.get_s16("stuntlvl3") > 0 || blob.get_s16("noheal") > 0)this.getSpriteLayer("brokenheart").SetVisible(true);
	
	this.getSpriteLayer("statis").SetVisible(false);
	if(!blob.hasTag("dead"))if(blob.get_s16("temp_statis") > 0)this.getSpriteLayer("statis").SetVisible(true);
	
	this.getSpriteLayer("cure").SetVisible(false);
	if(!blob.hasTag("dead"))if(blob.hasTag("curerunetatoo") || blob.hasTag("cleanse"))this.getSpriteLayer("cure").SetVisible(true);
	
	this.getSpriteLayer("haunt").SetVisible(false);
	if(!blob.hasTag("dead"))if(blob.hasTag("deathrunetatoo"))this.getSpriteLayer("haunt").SetVisible(true);
}




