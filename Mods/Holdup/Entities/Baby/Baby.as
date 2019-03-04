
#include "HumanoidCommon.as";

void onInit(CBlob @this){

	this.set_u16("born_time",getGameTime());
	
}

void onTick(CBlob @this){
	
	if(this.getSprite() !is null)this.getSprite().animation.frame = this.get_s8("head_type");
	
	if(getNet().isServer())
	if(this.get_u16("born_time")+30*60*2 == getGameTime()){
		
		CPlayer @target = null;
		
		for(int i = 0; i < getPlayersCount();i++){
			CPlayer @player = getPlayer(i);
			if(player.getBlob() is null){
				@target = player;
				break;
			} else {
				if(player.getBlob().hasTag("ghost")){
					@target = player;
					break;
				}
			}
		}
		
		if(target !is null){
		
			if(target.getBlob() !is null){
				target.getBlob().server_Die();
			}
		
			CBlob @humanoid = server_CreateBlob("humanoid",this.getTeamNum(),this.getPosition());
			
			setupBody(humanoid,this.get_s8("head_type"),this.get_s8("torso_type"),this.get_s8("main_arm_type"),this.get_s8("sub_arm_type"),this.get_s8("front_leg_type"),this.get_s8("back_leg_type"));
			
			humanoid.server_SetPlayer(target);
			
			this.server_Die();
		
		} else {
			this.set_u16("born_time",getGameTime()-(30*60*2)+30);
		}
	}
	
	if(getNet().isServer()){
		if(!this.isAttached()){
			this.set_u16("born_time",this.get_u16("born_time")+2);
			
			if(this.get_u16("born_time") > getGameTime()+30)this.server_Die();
		}
	}
}