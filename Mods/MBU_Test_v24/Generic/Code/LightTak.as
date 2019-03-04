
#include "AbilityCommon.as";
#include "eleven.as"
#include "HumanoidCommon.as";

void onInit(CBlob @this){

	if(!this.exists("light_amount"))this.set_s16("light_amount", 0);
	
	this.getCurrentScript().tickFrequency = 30;
	
	this.set_u8("light_eyes",0);
	this.Tag("light_tak");

}

void onTick(CBlob @this){
	
	if(this.hasTag("light_ability")){
		int Light = this.get_s16("light_amount");
		
		if(Light <= XORRandom(1000))
		if(!getMap().isBelowLand(this.getPosition())){
			Light++;
		}
		
		
		if(Light > 50 && !this.hasTag("light_orb_ability"))giveAbility(this,"light_orb_ability");
		else if(Light > 100 && !this.hasTag("light_heal_ability"))giveAbility(this,"light_heal_ability");
		else if(Light > 150 && !this.hasTag("light_infuse_ability"))giveAbility(this,"light_infuse_ability");
		else if(Light > 200 && !this.hasTag("light_recall_ability"))giveAbility(this,"light_recall_ability");
		else if(Light > 250 && !this.hasTag("light_wisp_ability"))giveAbility(this,"light_wisp_ability");
		else if(Light > 300 && !this.hasTag("light_invis_ability"))giveAbility(this,"light_invis_ability");
		else if(Light > 300 && !this.hasTag("light_fish_ability") && this.getName() == "goldenbeing")giveAbility(this,"light_fish_ability");
		else if(Light > 350 && !this.hasTag("light_redemption_ability"))giveAbility(this,"light_redemption_ability");
		
		if(this.getName() != "humanoid"){
			this.Untag("light_invis_ability");
			if(this.getPlayer() !is null){
				this.getPlayer().Untag("light_invis_ability");
			}
		}
		
		if(this.hasTag("light_invisibility")){
			if(Light >= 5.0f/getPowerMod(this,"light")){
				Light -= 5.0f/getPowerMod(this,"light");
			} else {
				this.Untag("light_invisibility");
				if(isServer()){
					this.Sync("light_invisibility",true);
				}
			}
		}
		
		this.set_s16("light_amount", Light);
	}
	
	if(this.get_u8("light_eyes") > 0)this.Tag("light_sight");
	else this.Untag("light_sight");
	
	if(getNet().isClient())
	if(getLocalPlayer() is this.getPlayer()){
		if(this.hasTag("light_sight"))getLocalPlayer().Tag("light_sight");
		else getLocalPlayer().Untag("light_sight");
	}

}
