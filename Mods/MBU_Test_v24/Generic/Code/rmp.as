///What is the death of death? New Life or Void?

#include "eleven.as";
#include "ep.as";

void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightRadius(32.0f);
	this.SetLightColor(SColor(255, 255, 240, 171));
	
	this.getShape().SetGravityScale(0.0f);
	this.getShape().getConsts().mapCollisions = false;
}

void onTick(CBlob@ this){
	if(getGameTime() % 10 == 0){
		if(getNet().isServer()){
			if(!checkEInterface(this,this.getPosition(),16,10))this.server_Die();
		}
		
		CBlob@[] blobs;	   
		getBlobsByName("humanoid", @blobs);
		CBlob @closest = null;
		int dis = -1;
		if(!this.hasTag("used"))
		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ b = blobs[i];
			if(b !is null)
			if(b.get_s16("death_amount") > 0 && b.hasTag("ghost")){
				int new_dis = this.getDistanceTo(b);
				if(new_dis < dis || dis == -1){
					dis = new_dis;
					@closest = b;
				}
				if(new_dis < 8){
					if(isServer()){
						this.server_Die();
						if(b.getPlayer() !is null){
							if(getRules().get_u8(b.getPlayer().getUsername()+"_lives") <= 0)getRules().set_u8(b.getPlayer().getUsername()+"_lives",1);
						}
						b.server_Die();
						this.Tag("used");
						break;
					}
				}
			}
		}
		
		if(closest !is null){
			Vec2f dir = closest.getPosition()-this.getPosition();
			dir.Normalize();
			this.AddForce(dir*6.0f);
		}
	}
	
	ltp(this.getPosition()+Vec2f(XORRandom(17)-8,XORRandom(17)-8),Vec2f(XORRandom(3)-1,XORRandom(3)-1));
	
	this.setAngleDegrees(this.getAngleDegrees()+29);
}

void onInit(CSprite @this){
	this.SetZ(998.0f);
}

void onTick(CSprite@ this)
{
	this.SetZ(998.0f);
}