
#include "ModHitters.as";

void restore(CBlob @this, CBlob @target, int amount = 1.0f){
	if(this is null || target is null)return;
	if(getNet().isServer()){
		if(target.getName() == "humanoid"){
			this.server_Hit(target, target.getPosition(), Vec2f(0,0), amount, Hitters::heal_light, true);
		} else {
			target.server_Heal(amount);
		}
	}
}