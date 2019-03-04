#include "Hitters.as";
#include "Explosion.as";
#include "FireParticle.as"
#include "FireCommon.as";

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(true);
	this.set_string("custom_explosion_sound", "KegExplosion");
}
void onDie(CBlob@ this)
{
	if(this.hasTag("doExplode")){
		DoExplosion(this,this.getOldVelocity());
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if(this.getHealth() < 1.0f && !this.hasTag("dead")){
		this.Tag("doExplode");
		this.server_Die();
	}
	return damage;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if(blob !is null ? !blob.isCollidable() : !solid) return;

	f32 vellen = this.getOldVelocity().Length();

	if (vellen > 8.0f) {
		this.Tag("doExplode");
		this.server_Die();
	}
}
void DoExplosion(CBlob@ this, Vec2f velocity)
{
	CMap@ map = getMap();
	Vec2f pos = this.getPosition();

	if (getNet().isServer())
	{
		CBlob@[] blobs;
		
		if (map.getBlobsInRadius(pos, 128.0f, @blobs))
		{
			for (int i = 0; i < blobs.length; i++)
			{		
				CBlob@ blob = blobs[i];
				if (blob !is null && (blob.hasTag("flesh") || blob.hasTag("plant"))) 
				{
					map.server_setFireWorldspace(blob.getPosition(), true);
					blob.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 0.5f, Hitters::fire);
				}
			}
		}
	
		for (int i = 0; i < 10 + XORRandom(5) ; i++)
		{
			CBlob@ blob = server_CreateBlob("flame", -1, this.getPosition());
			blob.setVelocity(Vec2f(XORRandom(20) - 10, -XORRandom(10)));
			blob.server_SetTimeToDie(10 + XORRandom(10));
		}
	}
	
	for (int i = 0; i < 64; i++)
	{
		map.server_setFireWorldspace(pos + Vec2f(8 - XORRandom(16), 8 - XORRandom(16)) * 8, true);
		ParticleAnimated("Entities/Effects/Sprites/FireFlash.png", this.getPosition() + Vec2f(0, -4), Vec2f(0, 0.5f), 0.0f, 1.0f, 2, 0.0f, true);
	}
	
	Explode(this, 64.0f, 10.0f);
	for (int i = 0; i < 4; i++)
	{
		Vec2f dir = Vec2f(1 - i / 2.0f, -1 + i / 2.0f);
		Vec2f jitter = Vec2f((XORRandom(200) - 100) / 200.0f, (XORRandom(200) - 100) / 200.0f);
		
		LinearExplosion(this, Vec2f(dir.x * jitter.x, dir.y * jitter.y), 32.0f + XORRandom(32), 15.0f, 6, 8.0f, Hitters::explosion);
	}
	this.getSprite().Gib();
}