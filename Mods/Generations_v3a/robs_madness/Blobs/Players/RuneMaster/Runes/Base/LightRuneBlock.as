
void onTick(CBlob @this){

	if(!this.getShape().isStatic())return;
	
	this.Untag("dead");
	
	if(getGameTime() % 3 == 0){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 32.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b.getName() == "mansshadow" && !b.hasTag("RuneNullify")){
					Vec2f dir = b.getPosition()-this.getPosition();
					dir.Normalize();
					b.AddForce(dir*400);
					for(float k = 0.0f; k < this.getDistanceTo(b); k += 2){
						Vec2f direction = b.getPosition()-this.getPosition();
						direction.Normalize();
						ParticleAnimated("HolyParticle.png", this.getPosition()+direction*k+Vec2f(XORRandom(7)-3,XORRandom(7)-3), Vec2f(XORRandom(5)-2,XORRandom(5)-2)*0.25, XORRandom(360), 0.1f+0.25f*float(XORRandom(2))+0.5f*float(XORRandom(2)), 2, 0.0f, true);
					}
				}
				if(b.getName() == "deathorb"){
					Vec2f dir = b.getPosition()-this.getPosition();
					dir.Normalize();
					b.AddForce(dir*2);
					for(float k = 0.0f; k < this.getDistanceTo(b); k += 2){
						Vec2f direction = b.getPosition()-this.getPosition();
						direction.Normalize();
						ParticleAnimated("HolyParticle.png", this.getPosition()+direction*k+Vec2f(XORRandom(7)-3,XORRandom(7)-3), Vec2f(XORRandom(5)-2,XORRandom(5)-2)*0.25, XORRandom(360), 0.1f+0.25f*float(XORRandom(2))+0.5f*float(XORRandom(2)), 2, 0.0f, true);
					}
					
				}
			}
		}
	}
	
	if(XORRandom(2) == 0){
		Vec2f vec = Vec2f(XORRandom(32),0);
		vec.RotateBy(XORRandom(360));
		Vec2f pos = this.getPosition()+vec+Vec2f(XORRandom(3)-1,XORRandom(3)-1);
		ParticleAnimated("HolyParticle.png", pos, Vec2f(XORRandom(5)-2,XORRandom(5)-2)*0.25, XORRandom(360), 0.1f+0.25f*float(XORRandom(2))+0.5f*float(XORRandom(2)), 3, 0.0f, true);
	}
}