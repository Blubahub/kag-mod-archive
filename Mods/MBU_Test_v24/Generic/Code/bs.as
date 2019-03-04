
#include "eleven.as"

void onTick(CBlob@ this){
	if(this.hasTag("blood_ability") && this.hasTag("soul")){
		f32 blood_power = getPowerMod(this,"blood")*2.0f;
		
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 160.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b !is null && b.getName() == "b")
				if(b.get_u16("created") < getGameTime()-60 && !b.hasTag("taken")){
					Vec2f vec = this.getPosition()-b.getPosition();
					vec.Normalize();
					f32 force = 1.0f-(this.getDistanceTo(b)/160.0f);
					b.setVelocity(b.getVelocity()*0.95f);
					b.AddForce(vec*blood_power*force);
					
					b.server_SetTimeToDie(30);
					
					if(this.getDistanceTo(b) < 8){
						this.set_s16("blood_amount", this.get_s16("blood_amount")+1);
						if(this.get_u8("food_blood") < 100)this.set_u8("food_blood",this.get_u8("food_blood")+1);
						b.Tag("taken");
						if(getNet().isServer()){
							this.Sync("blood_amount",true);
							b.server_Die();
						}
					}
				}
			}
		}
	}
	
	if(this.getSprite().getSpriteLayer("blood_buff") !is null){
		if(!this.hasTag("hemoric_strength") || (getLocalPlayer() is null || !getLocalPlayer().hasTag("blood_sight"))){
			this.getSprite().RemoveSpriteLayer("blood_buff");
		}
	}
}