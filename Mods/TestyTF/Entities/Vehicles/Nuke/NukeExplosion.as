#include "Hitters.as";
#include "Explosion.as";

const Vec2f arm_offset = Vec2f(-2, -4);

const u8 explosions_max = 25;

f32 sound_delay;

void onInit(CBlob@ this)
{
	this.Tag("map_damage_dirt");
	this.set_string("custom_explosion_sound", "KegExplosion");
	
	this.getShape().SetStatic(true);
	
	this.set_f32("map_damage_ratio", 0.125f);
	
	SetScreenFlash(255, 255, 255, 255);
	
	if (getNet().isClient())
	{
		Vec2f pos = getDriver().getWorldPosFromScreenPos(getDriver().getScreenCenterPos());
		f32 distance = Maths::Abs(this.getPosition().x - pos.x) / 8;
		sound_delay = (Maths::Abs(this.getPosition().x - pos.x) / 8) / (340 * 0.4f);
		
		print("delay: " + sound_delay);
	}
	
	this.SetLight(true);
	this.SetLightColor(SColor(255, 255, 255, 255));
	this.SetLightRadius(1024.5f);
}

void DoExplosion(CBlob@ this)
{
	ShakeScreen(512, 64, this.getPosition());
	// SetScreenFlash(255 * (1.00f - (f32(this.get_u8("boom_count")) / f32(explosions_max))), 255, 255, 255);
	
	f32 modifier = f32(this.get_u8("boom_count")) / f32(explosions_max);
	
	this.set_f32("map_damage_radius", 256.0f * modifier);
	
	this.set_Vec2f("explosion_offset", Vec2f(0, 0));
	Explode(this, 128.0f * modifier, 16.0f * (1 - modifier));
	
	for (int i = 0; i < 2; i++)
	{
		this.set_Vec2f("explosion_offset", Vec2f((100 - XORRandom(200)) / 50.0f, (100 - XORRandom(200)) / 400.0f) * 128 * modifier);
		Explode(this, 128.0f * modifier, 64.0f * (1 - modifier));
	}
	
	if (getNet().isServer())
	{
		for (int i = 0; i < 3; i++)
		{
			CBlob@ blob = server_CreateBlob("mat_mithril", this.getTeamNum(), this.getPosition());
			blob.server_SetQuantity(15 + XORRandom(150) * (1 - modifier));
			blob.setVelocity(Vec2f(30 - XORRandom(60), -10 - XORRandom(20)) * (0.5f + modifier));
		}
	}
}

void onTick(CBlob@ this)
{
	if (this.get_u8("boom_count") == explosions_max) 
	{
		if (getNet().isServer()) this.server_Die();
		this.Tag("dead");
		
		return;
	}
	
	if (this.hasTag("dead")) return;

	u32 ticks = this.getTickSinceCreated();
	
	if (getGameTime() % 2 == 0 && this.get_u8("boom_count") < explosions_max)
	{
		DoExplosion(this);
		this.set_u8("boom_count", this.get_u8("boom_count") + 1);
		
		f32 modifier = 1.00f - (float(this.get_u8("boom_count")) / float(explosions_max));
		
		this.SetLightRadius(1024.5f * modifier);
	}
	
	if (getNet().isServer())
	{
		if (ticks == 2)
		{
			CBlob@[] blobs;
		
			if (this.getMap().getBlobsInRadius(this.getPosition(), 2000, @blobs))
			{
				print("" + blobs.length);
			
				for (int i = 0; i < blobs.length; i++)
				{
					CBlob@ blob = blobs[i];
				
					if (!this.getMap().rayCastSolidNoBlobs(blob.getPosition(), this.getPosition()))
					{
						this.server_Hit(blob, blob.getPosition(), Vec2f(), 10.0f, Hitters::fire, true);
					}
				}
			}
		}	
	}
		
	if (getNet().isClient())
	{
		if (ticks > (sound_delay * 30) && !this.hasTag("sound_played"))
		{
			this.Tag("sound_played");
		
			f32 modifier = 1.00f - (sound_delay / 3.0f);
			print("modifier: " + modifier);
			
			if (modifier > 0.01f)
			{	
				Sound::Play("Nuke_Kaboom_Big.ogg", getDriver().getWorldPosFromScreenPos(getDriver().getScreenCenterPos()), 1.0f - (0.7f * (1 - modifier)), modifier);
			}
		}
	}
}