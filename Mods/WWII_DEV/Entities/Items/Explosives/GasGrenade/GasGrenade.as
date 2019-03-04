#include "Explosion.as";

string[] particles = 
{
	"LargeSmoke",
	"Explosion.png"
};

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 8;
	this.server_SetTimeToDie(5);
	this.set_bool("map_damage_raycast", true);
	
	this.Tag("projectile");
	
	this.Tag("map_damage_dirt");
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.isCollidable();
}

bool canBePutInInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	return false;
}

void onDie(CBlob@ this)
{
	this.getSprite().SetEmitSoundPaused(true);
	DoExplosion(this);
}

void DoExplosion(CBlob@ this)
{
	Vec2f pos = this.getPosition();
	CMap@ map = getMap();
	
//	for (int i = 0; i < 35; i++)
//	{
//		MakeParticle(this, Vec2f( XORRandom(64) - 32, XORRandom(80) - 60), getRandomVelocity(-angle, XORRandom(220) * 0.01f, 90), particles[XORRandom(particles.length)]);
//	}
	
	this.getSprite().PlaySound("gas_leak.ogg");
	f32 quantity = 65;
		
	if (getNet().isServer())
	{
		for (int i = 0; i < (quantity / 5) + XORRandom(quantity / 5) ; i++)
		{
			CBlob@ blob = server_CreateBlob("mustard", -1, this.getPosition());
			blob.setVelocity(Vec2f(2 - XORRandom(4), 2 - XORRandom(4)));
		}
	}
	
	this.Tag("exploded");
	this.getSprite().Gib();

}

void MakeParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!getNet().isClient()) return;

	ParticleAnimated(CFileMatcher(filename).getFirst(), this.getPosition() + pos, vel, float(XORRandom(360)), 0.5f + XORRandom(100) * 0.01f, 1 + XORRandom(4), XORRandom(100) * -0.00005f, true);
}