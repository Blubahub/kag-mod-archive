#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.SetMapEdgeFlags(CBlob::map_collide_none);
	this.getShape().getConsts().bullet = true;
	
	this.SetLight(true);
	this.SetLightRadius(32.0f);
	this.SetLightColor(SColor(255, 255, 220, 151));
	
	this.getShape().SetGravityScale(0.0f);
	this.getShape().getConsts().mapCollisions = false;
	
	this.set_f32("damage",0.0f);
	
	this.set_f32("scale",1.0f);
	this.set_u32("timer",getGameTime()+30*20);
	
	this.Tag("can_dispell");
	
	for(int i = 0; i < 5; i++)
	ParticleAnimated("DeathOrbPuff.png", this.getPosition()+Vec2f(XORRandom(11)-5,XORRandom(11)-5), this.getVelocity()+Vec2f(XORRandom(3)-1,XORRandom(3)-1)*0.4, XORRandom(360), 1.0f, 5, -0.01, true);
	
	// Sounds by TFlippy
	this.getSprite().PlaySound("WC3_DeathOrb_Create", 1.00f, 1.00f);
}

void onTick(CBlob@ this)
{
	this.AddForce(Vec2f(XORRandom(7)-3,XORRandom(7)-3)*0.1);
	
	
	CSprite @sprite = this.getSprite();
	if(sprite !is null){
		sprite.SetZ(1000);
	}
	
	if(XORRandom(6) == 0)ParticleAnimated("DeathOrbPuff.png", this.getPosition()+Vec2f(XORRandom(11)-5,XORRandom(11)-5), this.getVelocity()+Vec2f(XORRandom(3)-1,XORRandom(3)-1)*0.4, XORRandom(360), 0.5f, 3, -0.01, true);
	
	if(this.get_u32("timer") < getGameTime()){
		if(getNet().isClient()){
			this.getSprite().ScaleBy(Vec2f(0.9,0.9));
		}
	}
	
	if(this.get_u32("timer")+15 < getGameTime()){
		ParticleAnimated("DeathOrbPuff.png", this.getPosition()+Vec2f(XORRandom(11)-5,XORRandom(11)-5), this.getVelocity()+Vec2f(XORRandom(3)-1,XORRandom(3)-1)*0.4, XORRandom(360), 0.5f, 3, -0.01, true);
		if(getNet().isServer())this.server_Die();
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return (blob.hasTag("flesh") && !blob.hasTag("dead") && !blob.hasTag("undead")) && !blob.hasTag("RuneNullify");
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(blob is null)return;
	
	if(blob.hasTag("flesh") && !blob.hasTag("dead") && !blob.hasTag("undead") && !blob.hasTag("RuneNullify"))
	{
		this.server_Hit(blob, blob.getPosition(), this.getVelocity()*-0.5f, this.get_f32("damage"), Hitters::suddengib, true);
		for(int i = 0; i < 5; i++)
		ParticleAnimated("DeathOrbPuff.png", this.getPosition()+Vec2f(XORRandom(11)-5,XORRandom(11)-5), this.getVelocity()+Vec2f(XORRandom(3)-1,XORRandom(3)-1)*0.4, XORRandom(360), 1.0f, 5, -0.01, true);
		this.server_Die();
	}	
}

// Sounds by TFlippy
void onDie(CBlob@ this)
{
	this.getSprite().PlaySound("WC3_DeathOrb_Die", 1.00f, 1.00f);
}