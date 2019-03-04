
#include "Hitters.as";

void onInit(CSprite@ this)
{
	this.ReloadSprites(0, 0); //always blue

}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
	this.SetAnimation("idle");
}

void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightColor(SColor(11, 213, 255, 171));
	this.SetLightRadius(16.0f);
	
	this.set_s16("flight_height",16);
	
	this.set_s16("locationX",-1);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return true;
}

void onTick(CBlob@ this)
{
	int Height = this.get_s16("flight_height");
	int LocX = this.get_s16("locationX");
	
	CMap@ map = this.getMap();
	Vec2f surfacepos;
	if(map.rayCastSolid(this.getPosition(), this.getPosition()+Vec2f(0,Height), surfacepos)){
		this.AddForce(Vec2f(0, -10));
	} else {
		this.AddForce(Vec2f(0, -1));
	}
	
	if(map.rayCastSolid(this.getPosition(), this.getPosition()+Vec2f(0,-8.0f), surfacepos) || this.getPosition().y < 32){
		Height -= 4;
	}
	
	if(LocX != -1){
		if(LocX < this.getPosition().x){
			this.AddForce(Vec2f(-1, 0));
		} else {
			this.AddForce(Vec2f(1, 0));
		}
	}
	
	if(this.getVelocity().x > 0)this.SetFacingLeft(false);
	if(this.getVelocity().x < 0)this.SetFacingLeft(true);
	
	if(getNet().isServer()){
		
		if(XORRandom(10) == 0){
			Height += XORRandom(31)-15;
			
			if(this.isAttached()){
				CBlob @p = this.getAttachments().getAttachedBlob("PICKUP");
				this.server_Hit(p, this.getPosition(), Vec2f(0,0), 1.0f, Hitters::suddengib, true);
			}
		}
		
		if(Height < 16)Height = 16;
		
		if(Height != this.get_s16("flight_height")){
			this.set_s16("flight_height",Height);
			this.Sync("flight_height",true);
		}
		
		if(XORRandom(100) == 0){
			if(XORRandom(2) == 0){
				LocX = -1;
			} else {
				LocX = this.getPosition().x+XORRandom(320)-160;
			}
			
			this.set_s16("locationX",LocX);
			this.Sync("locationX",true);
		}
	}
	
	if(XORRandom(3) == 0){
		CParticle @p = ParticleAnimated("lp.png", this.getPosition()+Vec2f(XORRandom(5)-2,XORRandom(5)-3), this.getVelocity()/10+Vec2f(XORRandom(801)-400,-XORRandom(100))/10000, 90.0f, 1.0f, 6, -0.1f, true);
		if(p !is null){
			p.Z = -50.0f;
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.getShape().isStatic();
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(getNet().isServer()){
		if(blob !is null)
		if(blob.hasTag("flesh")){
			if(XORRandom(4) == 0){
				this.server_Hit(blob, this.getPosition(), Vec2f(0,0), 1.0f, Hitters::suddengib, true);
			}
		}
	}
}
