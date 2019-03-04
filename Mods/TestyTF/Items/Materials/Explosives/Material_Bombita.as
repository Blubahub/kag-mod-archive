#include "Hitters.as";
#include "Explosion.as";

const u8 boom_max = 8;

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(true);
	this.set_u8("boom_count", 0);
	this.set_bool("booming", false);
		
	this.Tag("invincible");
	// this.Tag("bomberman_style");
	
	this.set_f32("map_damage_ratio", 0.5f);
	// this.set_f32("map_damage_radius", 128.0f);
	// this.set_string("custom_explosion_sound", "Bomb.ogg");
	// this.set_bool("map_damage_raycast", false);
	
	this.getCurrentScript().tickFrequency = 4;
}

void DoExplosion(CBlob@ this, Vec2f velocity)
{
	ShakeScreen(256, 64, this.getPosition());
	f32 modifier = this.get_u8("boom_count") / 3.0f;
	
	this.set_f32("map_damage_radius", 20.0f * this.get_u8("boom_count"));
	
	for (int i = 0; i < 4; i++)
	{
		Explode(this, 128.0f * modifier, 8.0f);
	}
}

void onTick(CBlob@ this)
{
	if (this.get_bool("booming") && this.get_u8("boom_count") < boom_max)
	{
		DoExplosion(this, Vec2f(0, 0));
		this.set_u8("boom_count", this.get_u8("boom_count") + 1);
		
		if (this.get_u8("boom_count") == boom_max) this.server_Die();
		
		// print("" + this.get_u8("boom_count"));
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (this.getHealth() < 1.0f && !this.get_bool("booming")) this.set_bool("booming", true);
	return damage;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null ? !blob.isCollidable() : !solid) return;

	f32 vellen = this.getOldVelocity().Length();

	if (vellen > 5.0f)
	{
		this.set_bool("booming", true);
		// DoExplosion(this, this.getOldVelocity());
	}
}