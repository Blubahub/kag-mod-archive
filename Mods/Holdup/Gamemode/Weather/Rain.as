#include "Hitters.as";
#include "Explosion.as";
#include "MakeDustParticle.as";
#include "FireParticle.as";

// const Vec2f arm_offset = Vec2f(-2, -4);

// const u8 explosions_max = 25;

// f32 sound_delay;

f32 modifier_raw = 1;
f32 modifier = 1;

void onInit(CBlob@ this)
{
	this.getShape().SetStatic(true);
	this.getCurrentScript().tickFrequency = 1;
	
	this.getShape().SetRotationsAllowed(true);
	
	getMap().CreateSkyGradient("skygradient_rain.png");
	
	if (getNet().isServer())
	{
		this.server_SetTimeToDie(300);
	}
}

const int spritesize = 128;

void onInit(CSprite@ this)
{
	this.getConsts().accurateLighting = false;
	
	if (getNet().isClient())
	{
		int[] frames = {0, 1, 2, 3, 4, 5, 6, 7};
		// int[] frames = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15};
		// int[] frames = {15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0};

		Vec2f size = Vec2f(10, 7);
		
		for (int y = 0; y < size.y; y++)
		{
			for (int x = 0; x < size.x; x++)
			{
				CSpriteLayer@ l = this.addSpriteLayer("l_x" + x + "y" + y, "rain.png", spritesize, spritesize, this.getBlob().getTeamNum(), 0);
				l.SetOffset(Vec2f(x * spritesize, y * spritesize) - (Vec2f(size.x * spritesize, size.y * spritesize) / 2));
				l.SetLighting(false);
				l.SetRelativeZ(-600);
				l.setRenderStyle(RenderStyle::shadow);
				
				Animation@ anim = l.addAnimation("default", 1, true);
				anim.AddFrames(frames);
			}
		}
		
		this.SetEmitSound("rain_loop.ogg");
		this.SetEmitSoundPaused(false);
	}
}

void onTick(CBlob@ this)
{
	// CBlob@[] vehicles;
	// getBlobsByName("aerial", @vehicles);
	
	// Vec2f windDir = 
	
	// for (int i = 0; i < vehicles.length; i++)
	// {
		// CBlob@ b = v[i];
		// if (b !is null)
		// {
			// b.addForce()
		// }
	// }

	if (getNet().isClient())
	{
		CBlob@ blob = getLocalPlayerBlob();
		if (blob !is null)
		{
			Vec2f bpos = blob.getPosition();
			Vec2f pos = Vec2f(int(bpos.x / spritesize) * spritesize, int(bpos.y / spritesize) * spritesize); 
			
			this.setPosition(pos);
			
			if (XORRandom(500) == 0)
			{
				Sound::Play("thunder_distant" + XORRandom(4));
				SetScreenFlash(XORRandom(100), 255, 255, 255);
			}
			
			Vec2f hit;
			if (getMap().rayCastSolidNoBlobs(Vec2f(bpos.x, 0), bpos, hit))
			{
				f32 depth = Maths::Abs(bpos.y - hit.y) / 8.0f;
				modifier_raw = 1.0f - Maths::Clamp(depth / 8.0f, 0.25, 1);
				
				// print("underground: " + modifier);
			}
			else
			{
				modifier_raw = 1;
			}
			
			modifier = Lerp(modifier, modifier_raw, 0.02f);
			
			// print("" + modifier);
			
			this.getSprite().SetEmitSoundSpeed(0.5f + modifier * 0.5f);
			this.getSprite().SetEmitSoundVolume(0.30f + 0.10f * modifier);
		}
		
		f32 sine = (Maths::Sin((getGameTime() * 0.0125f)) * 8.0f);
		this.getShape().SetAngleDegrees(10 + sine);
	}
	
	if (getNet().isServer())
	{
		CMap@ map = getMap();
		u32 rand = XORRandom(1000);
	
		if (rand == 0)
		{
			f32 x = XORRandom(map.tilemapwidth);
			Vec2f pos = Vec2f(x, map.getLandYAtX(x)) * 8;
			
			CBlob@ blob = server_CreateBlob("lightningbolt", -1, pos);
		}	
		
		if (XORRandom(500) == 0)
		{
			CBlob@[] blobs;
			getBlobsByName("falloutgas", @blobs);
			
			if (blobs.length > 0)
			{
				CBlob@ b = blobs[XORRandom(blobs.length - 1)];
				if (b !is null)
				{
					b.server_Die();
				}
			}
		}
	}
}

f32 Lerp(f32 v0, f32 v1, f32 t) 
{
	return v0 + t * (v1 - v0);
}

void onDie(CBlob@ this)
{
	CBlob@ jungle = getBlobByName('info_jungle');

	if (jungle !is null)
	{
		getMap().CreateSkyGradient("skygradient_jungle.png");
	}
	else 
	{
		getMap().CreateSkyGradient("skygradient.png");
	}
}