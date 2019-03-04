#include "Hitters.as";
#include "Explosion.as";

bool DoExplosion(CBlob@ this, Vec2f velocity)
{
	if (this.hasTag("dead"))
		return true;

	f32 quantity = this.getQuantity();
		
	Explode(this, 16.0f, 2.0f);
	LinearExplosion(this, velocity, 16.0f * quantity / 2.0f, 16.0f * quantity / 4.0f, 4, 8.0f, Hitters::bomb);

	this.Tag("dead");
	this.server_Die();
	this.getSprite().Gib();

	return true;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::builder)
	{
		DoExplosion(this, velocity);
	}

	return damage;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	f32 vellen = this.getOldVelocity().Length();

	if (vellen > 8.0f)
	{
		DoExplosion(this, this.getOldVelocity());
	}
}