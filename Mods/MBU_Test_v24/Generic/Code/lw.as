///Shineeeey

#include "eleven.as";

void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightRadius(32.0f);
	this.SetLightColor(SColor(255, 255, 240, 171));
	
	this.getShape().SetGravityScale(0.0f);
	this.getShape().getConsts().mapCollisions = false;
}

void onTick(CBlob@ this){
	if(getGameTime() % 20 == 0){
		if(getNet().isServer()){
			if(!checkEInterface(this,this.getPosition(),16,10))this.server_Die();
		}
		
		CBlob@[] blobs;	   
		getBlobsByTag("tainted", @blobs);
		getBlobsByTag("blood_ability", @blobs);
		getBlobsByTag("dark_infused", @blobs);
		getBlobsByTag("blood_infused", @blobs);
		CBlob @closest = null;
		int dis = -1;
		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ b = blobs[i];
			if(b !is null){
				int new_dis = this.getDistanceTo(b);
				if(new_dis < dis || dis == -1){
					dis = new_dis;
					@closest = b;
				}
			}
		}
		
		if(closest !is null){
			Vec2f dir = closest.getPosition()-this.getPosition();
			dir.Normalize();
			this.AddForce(dir*6.0f);
		}
	}
	
	if(this.getVelocity().Length() > 0.0f){
		float angle = ((360-(this.getVelocity()).Angle())+180) % 360;
		float my_angle = this.getAngleDegrees();
		if(my_angle < angle){
			if(my_angle < angle-180)my_angle += 1;
			else my_angle -= 1;
		}
		if(my_angle > angle){
			if(my_angle > angle+180)my_angle -= 1;
			else my_angle += 1;
		}
		this.setAngleDegrees(my_angle);
	}
}

void onInit(CSprite @this){
	this.SetZ(998.0f);
}

void onTick(CSprite@ this)
{
	this.SetZ(998.0f);
}