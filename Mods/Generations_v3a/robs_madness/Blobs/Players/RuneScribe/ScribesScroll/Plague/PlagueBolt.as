#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.SetMapEdgeFlags(CBlob::map_collide_none);
	this.getShape().getConsts().bullet = true;
	
	this.SetLight(true);
	this.SetLightRadius(32.0f);
	this.SetLightColor(SColor(255, 0, 255, 0));
	
	this.getShape().SetGravityScale(0.0f);
	//this.getShape().getConsts().mapCollisions = false;
	this.server_SetTimeToDie(5.0f);
	
	this.Tag("can_dispell");
}

void onTick(CBlob@ this)
{
	
	CBlob@[] blobsInRadius;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), 128.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b.hasTag("flesh") && b.getTeamNum() != this.getTeamNum() && !b.hasTag("Plagued") && b.getName() != "migrant")
			{
				Vec2f Vel = b.getPosition()-this.getPosition();
				Vel.Normalize();
				this.AddForce(Vel*0.1);
			}
		}
	}
	
	ParticleAnimated("PlagueParticle.png", this.getPosition()+Vec2f(XORRandom(8)-4,XORRandom(8)-4), Vec2f(XORRandom(5)-2,XORRandom(5)-2)*0.25, 0, 1.0f, 6, 0.0f, true);
	
	this.AddForce(Vec2f(XORRandom(7)-3,XORRandom(7)-3)*0.1);

}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(blob is null)return;
	
	if(blob.getTeamNum() != this.getTeamNum() && blob.hasTag("flesh") && !blob.hasTag("Plagued") && blob.getName() != "migrant")
	{
		blob.AddScript("Plague.as");
		this.server_Die();
	}
	
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob ){

	if(blob.getName() == "wooden_door" || blob.getName() == "stone_door")return true;
	return false;

}