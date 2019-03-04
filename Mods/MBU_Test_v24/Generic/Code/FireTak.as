
#include "AbilityCommon.as"
#include "ModHitters.as"
#include "eleven.as"

void onInit(CBlob @this){

	if(!this.exists("fire_amount"))this.set_s16("fire_amount", 0);
	
	this.set_u32("last_expell",getGameTime());
	
	this.getCurrentScript().tickFrequency = 30;

	this.set_u8("burnt_eyes",0);
}

void onTick(CBlob @this){
	
	int fire = this.get_s16("fire_amount");
	int burnt_eyes = this.get_u8("burnt_eyes");
	
	if(fire > 0 && !this.hasTag("searing_vent_ability"))giveAbility(this,"searing_vent_ability","fire");
	else if(fire >= 10 && !this.hasTag("searing_infuse_ability"))giveAbility(this,"searing_infuse_ability","fire");
	else if(fire >= 20 && !this.hasTag("searing_nova_ability"))giveAbility(this,"searing_nova_ability","fire");
	else if(fire >= 30 && !this.hasTag("searing_bolt_ability"))giveAbility(this,"searing_bolt_ability","fire");
	else if(fire >= 40 && !this.hasTag("blazing_trail_ability"))giveAbility(this,"blazing_trail_ability","fire");
	else if(fire >= 50 && !this.hasTag("searing_discharge_ability"))giveAbility(this,"searing_discharge_ability","fire");
	else if(fire >= 90 && !this.hasTag("form_pyro_ability"))giveAbility(this,"form_pyro_ability","fire");
	else if(fire >= 100 && !this.hasTag("summon_sun_ability"))giveAbility(this,"summon_sun_ability","fire");
	
	
	if(!this.hasTag("pyromaniac")){
		if(fire <= 0){
			this.set_u32("last_expell",getGameTime());
			this.Untag("venting_heat");
			this.Untag("trail_blazing");
		} else {
			if(!this.hasTag("venting_heat")){
				if(this.get_u32("last_expell") < getGameTime()-(30*10)){
					fire -= 1;
					if(getNet().isServer())this.server_Hit(this, this.getPosition(), Vec2f(0,0), 1.0f, Hitters::self_burn, true);
				}
			} else {
				if(burnt_eyes == 2)fire -= 1;
				else fire -= 2;
				
				if(checkEInterface(this,this.getPosition(),32,1)){
					CBlob@[] blobsInRadius;	   
					if (this.getMap().getBlobsInRadius(this.getPosition(), 160.0f, @blobsInRadius)) 
					{
						for (uint i = 0; i < blobsInRadius.length; i++)
						{
							CBlob@ b = blobsInRadius[i];
							if(b !is null && !b.isInWater())b.Tag("warm");
						}
					}
				} else this.Untag("venting_heat");
			}
			
			if(checkEInterface(this,this.getPosition(),32,0)){
				if(this.hasTag("trail_blazing")){
					if(burnt_eyes == 2)fire -= 1;
					else fire -= 2;
				}
			} else this.Untag("trail_blazing");
		}
	} else {
		if(getNet().isServer())this.server_Hit(this, this.getPosition(), Vec2f(0,0), 1.0f, Hitters::fire, true);
	}
	
	if(fire < 0)fire = 0;
	this.set_s16("fire_amount", fire);
	
	if(this.hasTag("fire_sight") && !this.hasTag("searing_intake_ability")){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f*getPowerMod(this, "fire"), @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b !is null && !b.hasTag("fire source")){
					if(XORRandom(100) == 0){
						giveAbility(this,"searing_intake_ability","fire");
					}
				}
			}
		}
	}
	
	
	
	if(burnt_eyes > 0)this.Tag("fire_sight");
	else this.Untag("fire_sight");
	
	if(getNet().isClient())
	if(getLocalPlayer() is this.getPlayer()){
		if(this.hasTag("fire_sight"))getLocalPlayer().Tag("fire_sight");
		else getLocalPlayer().Untag("fire_sight");
	}

}
