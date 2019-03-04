#include "Hitters.as";
#include "Explosion.as";
#include "MakeDustParticle.as";
#include "FireParticle.as";
#include "canGrow.as";
#include "MakeSeed.as";
#include "Decay_Common.as";

// const Vec2f arm_offset = Vec2f(-2, -4);

// const u8 explosions_max = 25;

// f32 sound_delay;

void onInit(CBlob@ this)
{
	this.getShape().SetStatic(true);
	this.getCurrentScript().tickFrequency = 1;
	
	this.getShape().SetRotationsAllowed(true);
	
	getMap().CreateSkyGradient("skygradient_rain.png");
	
	if (getNet().isServer())
	{
		this.server_SetTimeToDie(300);
		
		CMap@ map = getMap();
		
		int x = XORRandom(map.tilemapwidth);
		
		if(XORRandom(map.tilemapheight)*2 > map.getLandYAtX(x)-2 && map.getLandYAtX(x) >= map.tilemapheight/2)
		map.server_setFloodWaterWorldspace(Vec2f(x*8,map.getLandYAtX(x)*8-16), true);
	}
	
	getRules().set_bool("raining", true);
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

		Vec2f size = Vec2f(12, 8);
		
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
		
		this.SetVisible(false);
	}
}

// f32 Lerp(f32 a, f32 b, f32 time)
// {
	// return a + (b-a) * Maths::Min(1.0,Maths::Max(0.0,time));
// }

f32 windTarget = 0;	
f32 wind = 0;	
u32 nextWindShift = 0;

f32 fog = 0;
f32 fogTarget = 0;

f32 modifier = 1;
f32 modifierTarget = 1;

void onTick(CBlob@ this)
{
	CMap@ map = getMap();
	if (getGameTime() >= nextWindShift)
	{
		windTarget = XORRandom(1000) - 500;
		nextWindShift = getGameTime() + 30 + XORRandom(300);
		
		fogTarget = 50 + XORRandom(150);
	}
	
	wind = Lerp(wind, windTarget, 0.02f);
	fog = Lerp(fog, fogTarget, 0.01f);
	// print("current wind: " + wind);
		
	f32 sine = (Maths::Sin((getGameTime() * 0.0125f)) * 8.0f);
	Vec2f sineDir = Vec2f(0, 1).RotateBy(sine * 20);
	
	CBlob@[] blobs;
	getBlobsByTag("aerial", @blobs);
	for(u32 i = 0; i < blobs.length; i++)
	{
		CBlob@ blob = blobs[i];
		if (blob !is null)
		{
			Vec2f pos = blob.getPosition();
			if (map.rayCastSolidNoBlobs(Vec2f(pos.x, 0), pos)) continue;
		
			blob.AddForce(sineDir * blob.getRadius() * wind * 0.01f);
		}
	}
	
	if (getNet().isClient())
	{	
		CBlob@ blob = getLocalPlayerBlob();
		f32 fogHeightModifier = 0.00f;
		
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
				modifierTarget = 1.0f - Maths::Clamp(depth / 8.0f, 0.00f, 1);
			}
			else
			{
				modifierTarget = 1;
			}
			
			modifier = Lerp(modifier, modifierTarget, 0.10f);
			fogHeightModifier = 1.00f - (bpos.y / (map.tilemapheight * map.tilesize));
			
			if (getGameTime() % 5 == 0) ShakeScreen(Maths::Abs(wind) * 0.03f * modifier, 90, bpos);
			
			this.getSprite().SetEmitSoundSpeed(0.5f + modifier * 0.5f);
			this.getSprite().SetEmitSoundVolume(0.30f + 0.10f * modifier);
		}
		
		
		
		f32 fogDarkness = Maths::Clamp(50 + (fog * 0.10f), 0, 255);
		//if (modifier > 0.01f) SetScreenFlash(Maths::Clamp(Maths::Max(fog, 255 * fogHeightModifier * 1.20f) * modifier, 0, 190), fogDarkness, fogDarkness, fogDarkness);
		
		// print("" + modifier);
		
		// print("" + (fog * modifier));
		
		this.getShape().SetAngleDegrees(10 + sine);

	}
	
	if (getNet().isServer())
	{
		CMap@ map = getMap();
		u32 rand = 1;//XORRandom(1000);
		
		if (rand == 0)
		{
			f32 x = XORRandom(map.tilemapwidth);
			Vec2f pos = Vec2f(x, map.getLandYAtX(x)) * 8;
			
			CBlob@ blob = server_CreateBlob("lightningbolt", -1, pos);
		}	
		
		//if (getGameTime() % 15 == 0) 
		DecayStuff(2);
	}
}


f32 Lerp(f32 v0, f32 v1, f32 t) 
{
	return v0 + t * (v1 - v0);
}

void onDie(CBlob@ this)
{
	getRules().set_bool("raining", false);
	getMap().CreateSkyGradient("skygradient.png");
}