
#include "eleven.as"
#include "AbilityCommon.as"

void onTick(CBlob @this){
	if(this.hasTag("dark_fade")){
		this.getCurrentScript().tickFrequency = 1;
		this.Tag("flying");
		this.getShape().getConsts().mapCollisions = false;
		if(this.get_u32("dark_fade_start")+(150.0f*getPowerMod(this,"dark")) < getGameTime()){
			this.Untag("dark_fade");
			this.Untag("flying");
			this.getShape().getConsts().mapCollisions = true;
			StartCooldown(this,"fade_cd",5*30);
		}
	} else {
		this.getCurrentScript().tickFrequency = 15;
	}
}