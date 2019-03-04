#include "Hitters.as";
#include "FireParticle.as"
#include "eleven.as"

void onInit(CBlob@ this)
{
	this.SetMapEdgeFlags(CBlob::map_collide_none);
	this.getShape().getConsts().bullet = true;
	
	this.SetLight(true);
	this.SetLightRadius(32.0f);
	this.SetLightColor(SColor(255, 255, 220, 151));
	
	this.getShape().SetGravityScale(0.0f);
	
	this.set_u16("radius",32);
}

void onTick(CBlob@ this)
{
	
	if(getNet().isServer())if(this.isInWater())this.server_Die();
	
	this.setAngleDegrees(this.getAngleDegrees()+20.0f);
	
	int radius = this.get_u16("radius");
	
	if(getNet().isServer())if(!checkEInterface(this,this.getPosition(),radius,10))this.server_Die();
	
	if(getNet().isServer()){
		CBlob@[] blobsInRadius;
		if (this.getMap().getBlobsInRadius(this.getPosition(), radius, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				
				if(b !is null && b !is this && !b.isInWater() && !b.hasTag("fire source")){

					this.server_Hit(b, b.getPosition(), Vec2f(0,0), f32(radius)/100.0f, Hitters::fire, true);
				}
			}
		}
	}
	
	this.SetLightRadius(radius*2);
	
	radius = f32(radius)*0.75f;
	
	for(int i = 0; i < radius/10+1; i++)
	makeFireParticleStill(this.getPosition()+Vec2f(XORRandom(radius*2)-radius,XORRandom(radius*2)-radius));
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return false;
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(solid && blob is null)
	{
		this.server_Die();
	}
}

void onTick(CSprite@ this)
{
	CBlob @blob = this.getBlob();
	if(blob !is null && !blob.hasTag("scaled")){

		this.ScaleBy(Vec2f(f32(blob.get_u16("radius"))/32.0f,f32(blob.get_u16("radius"))/32.0f));

		blob.Tag("scaled");
	}
}