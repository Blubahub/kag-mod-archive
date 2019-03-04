
#include "HumanoidCommon.as";

void onInit(CBlob @this){

	this.set_u16("born_time",getGameTime());
	
	this.set_s8("head_type",0);
	this.set_s8("torso_type",0);
	this.set_s8("main_arm_type",0);
	this.set_s8("sub_arm_type",0);
	this.set_s8("front_leg_type",0);
	this.set_s8("back_leg_type",0);
	
}

void onTick(CBlob @this){
	
	if(this.getSprite() !is null)this.getSprite().animation.frame = this.get_s8("head_type");
	
	if(getNet().isServer())
	if(this.get_u16("born_time")+30*60*2 == getGameTime()){
		
		CBlob @humanoid = server_CreateBlob("humanoid",this.getTeamNum(),this.getPosition());
		
		setupBody(humanoid,this.get_s8("head_type"),this.get_s8("torso_type"),this.get_s8("main_arm_type"),this.get_s8("sub_arm_type"),this.get_s8("front_leg_type"),this.get_s8("back_leg_type"));
		
		this.server_Die();

	}
	
	if(getNet().isServer()){
		if(!this.isAttached()){
			this.set_u16("born_time",this.get_u16("born_time")+2);
			
			if(this.get_u16("born_time") > getGameTime()+30)this.server_Die();
		}
	}
}