#include "ep.as"

void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;
	shape.getConsts().mapCollisions = false;
	shape.SetGravityScale(0.0f);
	
	this.set_s16("dark_amount", 1000);
	
	this.Tag("no hands");
	this.Tag("dbb");
	
	for(int i = 0;i < 5;i++){
		CBlob @particle = server_CreateBlob("cbp",-1,this.getPosition());
		if(particle !is null){
			particle.set_netid("master",this.getNetworkID());
		}
	}
	
}

void onTick(CBlob@ this)
{
	if(this.get_s16("dark_amount") > 5){
		if(this.isKeyPressed(key_action1)){
			CBlob@[] blobsInRadius;
			this.getMap().getBlobsInRadius(this.getAimPos(), 32.0f, @blobsInRadius);
			this.getMap().getBlobsInRadius(this.getPosition(), 32.0f, @blobsInRadius);
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				
				if(b !is null && b.getName() == "humanoid"){
				
					Vec2f vec = this.getPosition()-b.getPosition();
					vec.Normalize();
					cpr(b.getPosition()+Vec2f(XORRandom(7)-3,XORRandom(7)-3),vec*2.0f);
					b.AddForce(vec*40.0f);
					int DarkAmount = b.get_s16("dark_amount");
					if(XORRandom(DarkAmount) < 4)DarkAmount++;
					b.set_s16("dark_amount",DarkAmount);
				}
			}
		}
	
		if(this.isKeyPressed(key_action2)){
			if(isServer() && ((getGameTime() % 5) == 0 || this.isKeyJustPressed(key_action2))){
				Vec2f vec = this.getAimPos()-this.getPosition();
				vec.Normalize();
				this.sub_s16("dark_amount",5);
				CBlob @eco = server_CreateBlob("eco",-1,this.getPosition()+Vec2f(XORRandom(49)-24,XORRandom(49)-24));
				if(eco !is null){
					eco.setVelocity(vec*5.0f);
				}
			}
		}
	} else {
		if(isServer())this.server_Die();
	}
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob ){

	return blob.hasTag("dbb");

}