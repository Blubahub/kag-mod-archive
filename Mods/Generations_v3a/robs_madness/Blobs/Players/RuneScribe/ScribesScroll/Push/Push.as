#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.getShape().SetGravityScale(0.0f);
	
	this.server_SetTimeToDie(0.1f);
	
	this.set_u8("radius",5);
}

void onDie(CBlob@ this)
{

	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius(this.getPosition(), this.get_u8("radius")*2, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b !is null){
				if(b !is this && !b.getShape().isStatic() && b.getName() != "princess" && !b.hasTag("RuneNullify")){
					Vec2f dir = b.getPosition()-this.getPosition();
					dir.Normalize();
					b.setVelocity(dir*this.get_u8("radius")+b.getVelocity());
				}
			}
		}
	}
	
	Vec2f vec = Vec2f(this.get_u8("radius")*2,0);
	for(int r = 0; r < 360; r += 10){
		vec.RotateBy(r);
		Vec2f dir = (this.getPosition()+vec)-this.getPosition();
		dir.Normalize();
		ParticleAnimated("RuneParticle.png", this.getPosition()+vec, dir, 0, 1.0f, 3, 0, true);
	}

}