// Bomb logic

#include "Hitters.as"

const s32 BOMB_FUSE = 100;

void SetupBomb(CBlob@ this, const int fuseTicks, const f32 explRadius, const f32 explosive_damage, const f32 map_damage_radius, const f32 map_damage_ratio, const bool map_damage_raycast)
{
	this.set_s32("fuse_timer", fuseTicks);
	this.set_f32("explosive_radius", explRadius);
	this.set_f32("explosive_damage", explosive_damage);
	//use the bomb hitter
	this.set_u8("custom_hitter", Hitters::water);
	this.set_f32("map_damage_radius", map_damage_radius);
	this.set_f32("map_damage_ratio", map_damage_ratio);
	this.set_bool("map_damage_raycast", map_damage_raycast);
	this.set_string("custom_explosion_sound", "/GlassBreak");
    this.Tag("splash ray cast");
	this.Tag("exploding");
}

bool UpdateBomb(CBlob@ this)
{
	s32 timer = this.get_s32("fuse_timer");
	this.getSprite().SetEmitSoundPaused(false);
	if (timer <= 0)
	{
		if (getNet().isServer())
		{
			Boom(this);
		}
		this.getCurrentScript().runFlags |= Script::remove_after_this;
		return false;
	}
	else
	{
		SColor lightColor;
		const u8 hitter = this.get_u8("custom_hitter");

		if (hitter == Hitters::water)
		{
			this.getSprite().SetEmitSound("WaterSparkle.ogg");
			this.getSprite().SetEmitSoundPaused(false);
			lightColor = SColor(255, 44, 175, 222);
			this.SetLight(false);
		}
		else
		{
			lightColor = SColor(255, 255, Maths::Min(255, 2 * timer), 0);
			this.SetLightColor(lightColor);
		}

		if (XORRandom(2) == 0)
		{
			sparks(this.getPosition(), this.getAngleDegrees(), 3.5f + (XORRandom(10) / 5.0f), lightColor);
		}

		if (timer < BOMB_FUSE / 2)
		{
			const f32 speed = 1.0f + (1.0f - 2.0f * ((f32(timer) / f32(BOMB_FUSE))));
			this.getSprite().SetEmitSoundSpeed(speed);
			this.getSprite().SetEmitSoundVolume(speed);
		}
	}

	if (timer > 0)
	{
		timer--;
		this.set_s32("fuse_timer", timer);
	}

	return true;
}

void sparks(Vec2f at, f32 angle, f32 speed, SColor color)
{
	Vec2f vel = getRandomVelocity(angle + 90.0f, speed, 25.0f);
	at.y -= 2.5f;
	ParticlePixel(at, vel, color, true, 119);
}

void Boom(CBlob@ this)
{
	this.server_Hit(this, this.getPosition(), Vec2f(0, 0), this.hasTag("flesh") ? 7.0f : 4.0f, 0, true);
	BombFuseOff(this);
}

void BombFuseOff(CBlob@ this)
{
	this.SetLight(false);
	this.getSprite().SetEmitSoundPaused(true);
}

void BombFuseOn(CBlob@ this, f32 lightRadius)
{
	this.getSprite().SetEmitSound("/Sparkle.ogg");
	this.SetLight(true);
	this.SetLightRadius(lightRadius);
	this.getSprite().SetEmitSoundPaused(false);
}