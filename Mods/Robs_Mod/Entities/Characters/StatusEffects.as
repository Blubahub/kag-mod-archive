#include "RunnerCommon.as"
#include "FireCommon.as"

void onTick(CBlob@ this)
{

	checkTatoos(this);

	if(this.hasTag("undead")){
		this.Tag("evil");
		this.Untag("holy");
	}
	
	if(this.hasTag("cleanse") && !this.hasTag("undead")){
		this.set_s16("slow",0);
		this.set_s16("squat",0);
		this.set_s16("empowerfire",0);
		this.Untag("firecurse");
		this.set_s16("weak",0);
		this.set_s16("cant_breathe_air",0);
		this.set_s16("drain",0);
		this.set_s16("poison",0);
		this.set_s16("noheal",0);
		this.set_s16("stunt",0);
		this.Untag("infect");
		this.Untag("cleanse");
	}
	
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
	if(this.get_s16("haste") > 0){
		if(this.get("moveVars", @moveVars))
		{
			moveVars.walkFactor *= 1.5f;
		}
		this.set_s16("haste",this.get_s16("haste")-1);
	}
	
	if(this.get_s16("squat") > 0){
		if(this.get("moveVars", @moveVars))
		{
			moveVars.jumpFactor *= 0.5f;
		}
		this.set_s16("squat",this.get_s16("squat")-1);
	}
	if(this.get_s16("highjump") > 0){
		if(this.get("moveVars", @moveVars))
		{
			moveVars.jumpFactor *= 2.0f;
		}
		this.set_s16("highjump",this.get_s16("highjump")-1);
	}
	
	if(this.get_s16("empowerfire") > 0)this.set_s16("empowerfire",this.get_s16("empowerfire")-1);
	if(this.get_s16("fire immune") > 0){
		server_setFireOff(this);
		this.set_s16("fire immune",this.get_s16("fire immune")-1);
	}
	
	if(this.hasTag("firecurse")){
		if(!this.hasTag("burning"))server_setFireOn(this);
	}
	
	if(this.get_s16("empowerwater") > 0){
		this.set_s16("empowerwater",this.get_s16("empowerwater")-1);
	}
	if(this.get_s16("cant_drown") > 0)this.set_s16("cant_drown",this.get_s16("cant_drown")-1);
	if(this.get_s16("cant_breathe_air") > 0)this.set_s16("cant_breathe_air",this.get_s16("cant_breathe_air")-1);
	
	if(this.get_s16("defense") > 0)this.set_s16("defense",this.get_s16("defense")-1);
	if(this.get_s16("weak") > 0)this.set_s16("weak",this.get_s16("weak")-1);
	
	if(this.get_s16("blessed") > 0)this.set_s16("blessed",this.get_s16("blessed")-1);
	
	if(this.get_s16("drain") > 0)this.set_s16("drain",this.get_s16("drain")-1);
	if(this.get_s16("lifesteal") > 0)this.set_s16("lifesteal",this.get_s16("lifesteal")-1);
	
	
	
	
	if(this.get_s16("overheal") > 0){
		if(this.getHealth() == this.getInitialHealth())this.server_SetHealth(this.getInitialHealth()+0.5);
		this.set_s16("overheal",this.get_s16("overheal")-1);
	}
	if(this.get_s16("poison") > 0)this.set_s16("poison",this.get_s16("poison")-1);
	if(this.get_s16("buff") > 0)this.set_s16("buff",this.get_s16("buff")-1);
	if(this.get_s16("stunt") > 0){
		if(this.getHealth() > this.getInitialHealth()/2)this.server_SetHealth(this.getInitialHealth()/2);
		this.set_s16("stunt",this.get_s16("stunt")-1);
	}
	if(this.get_s16("overregen") > 0)this.set_s16("overregen",this.get_s16("overregen")-1);
	
	if(this.get_s16("statustimer") > 60){
		
		if(this.get_s16("drain") > 0)if(this.getHealth() > 0.125)this.server_Heal(-0.25);
		if(this.get_s16("overregen") > 0)if(this.getHealth() < this.getInitialHealth()*2)this.server_SetHealth(this.getHealth()+0.125f);
		if(this.get_s16("poison") > 0)this.server_Hit(this, this.getPosition(), Vec2f(0.0f, 0.0f), 0.25, Hitters::suddengib, false);
		
		this.set_s16("statustimer",0);
	} else this.set_s16("statustimer",this.get_s16("statustimer")+1);
	
	if(this.get_s16("noheal") > 0 && this.getHealth() >= this.get_f32("nohealvar"))this.set_s16("noheal",this.get_s16("noheal")-1);
	else this.set_f32("nohealvar",this.getHealth());
	this.server_SetHealth(this.get_f32("nohealvar"));
}


f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	f32 dmg = damage;
	if(this.get_s16("weak") > 0)dmg *= 1.5f;
	if(this.get_s16("defense") > 0)dmg -= 0.5f;
	if(this.get_s16("blessed") > 0)dmg -= 0.5f;
	if(this.get_s16("buff") > 0)dmg *= 0.75f;
	
	if(this.hasTag("slowrunetatoo"))hitterBlob.set_s16("slow",300);
	
	if(dmg < 0)dmg = 0;
	
	if(this.hasTag("liferunetatoo"))if(this.getHealth()*2-dmg <= 0){
		dmg = 0;
		this.server_Heal(200);
		this.Untag("dead");
		this.Untag("liferunetatoo");
	}
	if (getNet().isServer())
	if(this.hasTag("deathrunetatoo"))if(this.getHealth()*2-dmg <= 0){
		server_CreateBlob("zombie", this.getTeamNum(), this.getPosition()); 
		this.server_Die();
	}
	
	return dmg; //no block, damage goes through
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	
	if(this.get_s16("lifesteal") > 0)if(hitBlob.hasTag("flesh"))if(this.getHealth() < this.getInitialHealth())this.server_Heal(damage*0.5f);
	
	return;
}

void checkTatoos(CBlob@ this){
	if(this.hasTag("firerunetatoo")){
		this.set_s16("empowerfire",10);
		this.set_s16("fire immune",10);
	}
	if(this.hasTag("waterrunetatoo")){
		this.set_s16("empowerwater",10);
		this.set_s16("cant_drown",10);
	}
	if(this.hasTag("earthrunetatoo")){
		this.set_s16("defense",10);
	}
	if(this.hasTag("airrunetatoo")){
		this.set_s16("highjump",10);
	}
	
	if(this.hasTag("fleshrunetatoo")){
		this.set_s16("overheal",10);
	}
	if(this.hasTag("consumerunetatoo")){
		this.set_s16("lifesteal",10);
	}
	if(this.hasTag("plantrunetatoo")){
		this.set_s16("buff",10);
	}
	if(this.hasTag("growrunetatoo")){
		this.set_s16("overregen",10);
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
	
	if(this.hasTag("hasterunetatoo"))this.set_s16("haste",10);
	if(this.hasTag("curerunetatoo"))this.Tag("cleanse");
	
	
	
}