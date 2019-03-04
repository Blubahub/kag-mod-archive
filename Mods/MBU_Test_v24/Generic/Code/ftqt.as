
#include "eleven.as"

void onTick(CBlob @this){
	if(this.hasTag("trail_blazing")){
		if(checkEInterface(this,this.getPosition(),16,2)){
			if(getNet().isServer()){
				for(int i = 0;i <= 1;i+=1)
				for(int j = -1;j <= 0;j+=1)
				getMap().server_setFireWorldspace(this.getPosition()+Vec2f(i,j)*8, true);
			}
		}
	}
	
	if(this.hasTag("pyromaniac"))if(this.get_u16("fire_amount") < 100)this.add_s16("fire_amount", 1);

}