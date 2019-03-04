#include "Hitters.as";
#include "Explosion.as";

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(true);
	this.set_string("custom_explosion_sound", "Entities/Items/Explosives/KegExplosion.ogg");
}
void onDie(CBlob@ this)
{
	if(this.hasTag("doExplode")){
		DoExplosion(this,this.getOldVelocity());
	}
}
f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if(this.getHealth()<1.0f && !this.hasTag("dead")){
		this.Tag("doExplode");
		this.server_Die();
	}
	return damage;
}
void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if(blob !is null ? !blob.isCollidable() : !solid){
		return;
	}

	f32 vellen=this.getOldVelocity().Length();
	if(vellen>=10.0f) {
		this.Tag("doExplode");
		this.server_Die();
	}
}

void DoExplosion(CBlob@ this, Vec2f velocity)
{
	Explode(this,64.0f,30.0f);
	for(int i=0;i<8;i++) {
		Vec2f dir=		Vec2f(1-i/4.0f,-1+i/4.0f);
		Vec2f jitter=	Vec2f((XORRandom(200)-100)/200.0f,(XORRandom(200)-100)/200.0f);
		
		LinearExplosion(this,Vec2f(dir.x*jitter.x,dir.y*jitter.y),40.0f+XORRandom(64),60.0f,6,20.0f,Hitters::explosion);
	}
	this.getSprite().Gib();
}