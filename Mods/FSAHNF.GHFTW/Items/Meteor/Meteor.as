// Keg logic
#include "Hitters.as";
#include "Explosion.as";

void onInit(CBlob@ this)
{
	this.Tag("bomberman_style");
	this.set_f32("map_bomberman_width", 24.0f);
	this.set_f32("explosive_radius", 32.0f);
	this.set_f32("explosive_damage", 10.0f);
	this.set_u8("custom_hitter", Hitters::keg);
	this.set_string("custom_explosion_sound", "Entities/Items/Explosives/KegExplosion.ogg");
	this.set_f32("map_damage_radius", 36.0f);
	this.set_f32("map_damage_ratio", 0.6f);
	this.set_bool("map_damage_raycast", true);
	this.set_f32("keg_time", 30.0f);  // 180.0f
	this.Tag("medium weight");

	this.set_u16("_keg_carrier_id", 0xffff);
}

void onInit(CSprite@ this)
{
	this.animation.frame = XORRandom(4);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (!solid)
	{
		return;
	}
	
	Explode(this, this.get_f32("explosive_radius"), this.get_f32("explosive_damage"));
	this.server_Die();
}