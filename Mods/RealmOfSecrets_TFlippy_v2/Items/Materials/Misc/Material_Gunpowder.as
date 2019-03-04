#include "Hitters.as";
#include "Explosion.as";

void onInit(CBlob@ this)
{
	this.set_string("custom_explosion_sound", "KegExplosion");
}

bool DoExplosion(CBlob@ this, Vec2f velocity)
{
	if (this.hasTag("dead"))
		return true;

	f32 quantity = this.getQuantity();
		
	for (int i = 0; i < 2 + XORRandom(3); i++)
	{
		Vec2f dir = Vec2f((100 - XORRandom(200)) / 100.0f, (100 - XORRandom(200)) / 100.0f);
		// print("x: " + dir.x + "; y: " + dir.y);
		LinearExplosion(this, dir, 1.1f * quantity, 0.2f * quantity, 4, 8.0f, Hitters::explosion);
	}
	
	this.Tag("dead");
	this.server_Die();
	this.getSprite().Gib();

	return true;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::fire || customData == Hitters::burn || customData == Hitters::bomb || customData == Hitters::explosion || customData == Hitters::keg)
	{
		print("boom");
		DoExplosion(this, velocity);
	}

	return damage;
}