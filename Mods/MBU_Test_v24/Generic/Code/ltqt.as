
#include "AbilityCommon.as"

void onInit(CBlob @this){

	this.set_u8("life_flow_state", 0);

}

void onTick(CBlob @this){

	int LifeAmount = this.get_s16("life_amount");

	if(getGameTime() % 10 == 0){
		if(!this.hasTag("life_linked")){
			if(this.get_u16("life_link_partner") != 0){
				this.set_u16("life_link_partner",0);
				this.set_u8("life_flow_state", 0);
				
				if(isServer()){
					this.Sync("life_link_partner", true);
					this.Sync("life_flow_state", true);
					this.Sync("life_linked",true);
				}
			}
		} else {
			CBlob @partner = getBlobByNetworkID(this.get_u16("life_link_partner"));
			if(partner !is null){
				int dis = this.getDistanceTo(partner);
				
				if(!partner.hasTag("life_linked") || dis > 320.0f){
					this.Untag("life_linked");
				} else {
					for(float k = 0.0f; k < Maths::Max(dis/2-10,8); k += 1){
						Vec2f direction = partner.getPosition()-this.getPosition();
						direction.Normalize();
						if(XORRandom(3)==1)lp(this.getPosition()+direction*k+Vec2f(XORRandom(3)-1,XORRandom(3)-1),true,direction);
					}
					
					int state = this.get_u8("life_flow_state");
					
					if(state == 1){
						if(getGameTime() % 100 == 0){
							if(partner.get_s16("life_amount") > 0){
								partner.sub_s16("life_amount",1);
								LifeAmount++;
							} else this.set_u8("life_flow_state", 2);
						}
					}
					if(state == 3){
						if(getGameTime() % 300 == 0){
							if(this.get_s16("life_amount") > 10){
								partner.add_s16("life_amount",1);
								LifeAmount--;
							} else this.set_u8("life_flow_state", 0);
						}
					}
				}
				
				if(isServer()){
					this.Sync("life_link_partner", true);
					this.Sync("life_flow_state", true);
					this.Sync("life_linked",true);
				}
				
			} else
				this.Untag("life_linked");
		}
	}
	
	this.set_s16("life_amount", LifeAmount);
	
	if(getGameTime() % 30 == 0){
	
		if(LifeAmount > 100 && !this.hasTag("life_sight"))this.Tag("life_sight");
		else if(LifeAmount >= 150 && !this.hasTag("life_link_ability")){
			giveAbility(this,"life_link_ability","life");
			giveAbility(this,"life_flow_ability","life");
		}
		else if(LifeAmount >= 200 && !this.hasTag("life_kiss_ability"))giveAbility(this,"life_kiss_ability","life");
		else if(LifeAmount >= 250 && !this.hasTag("life_infuse_ability"))giveAbility(this,"life_infuse_ability","life");
		else if(LifeAmount >= 300 && !this.hasTag("life_burst_ability"))giveAbility(this,"life_burst_ability","life");
		else if(LifeAmount >= 350 && !this.hasTag("life_falter_ability"))giveAbility(this,"life_falter_ability","life");
		else if(LifeAmount >= 400 && !this.hasTag("life_force_orb_ability"))giveAbility(this,"life_force_orb_ability","life");
		else if(LifeAmount >= 450 && !this.hasTag("summon_wisp_ability"))giveAbility(this,"summon_wisp_ability","life");
		else if(LifeAmount >= 500 && !this.hasTag("life_parting_ability"))giveAbility(this,"life_parting_ability","life");
		else if(LifeAmount >= 550 && !this.hasTag("form_wisp_ability"))giveAbility(this,"form_wisp_ability","life");
		else if(LifeAmount >= 600 && !this.hasTag("life_globe_ability"))giveAbility(this,"life_globe_ability","life");
		else if(LifeAmount >= 650 && !this.hasTag("soul_infuse_ability"))giveAbility(this,"soul_infuse_ability","life");
		else if(LifeAmount >= 700 && !this.hasTag("life_cage_ability"))giveAbility(this,"life_cage_ability","life");
	
	
		CPlayer @local_player = getLocalPlayer();
	
		if(getNet().isClient())
		if(local_player is this.getPlayer() && local_player !is null){
			if(this.hasTag("life_sight")){
				local_player.Tag("life_sight");
				local_player.Tag("death_sight");
			}
			else local_player.Untag("life_sight");
			
			CBlob @partner = getBlobByNetworkID(this.get_u16("life_link_partner"));
			if(partner !is null){
				if(partner.hasTag("life_sight"))local_player.Tag("life_sight");
				if(partner.hasTag("death_sight"))local_player.Tag("death_sight");
				if(partner.hasTag("water_sight"))local_player.Tag("water_sight");
				if(partner.hasTag("fire_sight"))local_player.Tag("fire_sight");
				if(partner.hasTag("light_sight"))local_player.Tag("light_sight");
				if(partner.hasTag("dark_sight"))local_player.Tag("dark_sight");
				if(partner.hasTag("nature_sight"))local_player.Tag("nature_sight");
				if(partner.hasTag("blood_sight"))local_player.Tag("blood_sight");
			}
		}
	}
}
