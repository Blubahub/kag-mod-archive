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
}

const int spritesize = 128;

void onInit(CSprite@ this)
{
	this.getConsts().accurateLighting = false;
	
	if (getNet().isClient())
	{
		int[] frames = {0, 1, 2, 3, 4, 5, 6, 7};
		Vec2f size = Vec2f(30, 20);
		
		for (int y = 0; y < size.y; y++)
		{
			for (int x = 0; x < size.x; x++)
			{
				CSpriteLayer@ l = this.addSpriteLayer("l_x" + x + "y" + y, "JumpEffect.png", spritesize, spritesize, this.getBlob().getTeamNum(), 0);
				l.SetOffset(Vec2f(x * spritesize, y * spritesize) - (Vec2f(size.x * spritesize, size.y * spritesize) / 2));
				l.SetLighting(false);
				l.SetRelativeZ(-600);
				//l.setRenderStyle(RenderStyle::additive);
				
				Animation@ anim = l.addAnimation("default", 1, true);
				anim.AddFrames(frames);
			}
		}
	}
}

void onTick(CBlob@ this)
{
	if (getNet().isClient())
	{
		CBlob@ blob = getLocalPlayerBlob();
		if (blob !is null)
		{
			Vec2f bpos = blob.getPosition();
			Vec2f pos = Vec2f(int(bpos.x / spritesize) * spritesize, int(bpos.y / spritesize) * spritesize); 
			if(this.get_u16("timer") >= 10*30)
				this.setPosition(pos);
			else
				this.setPosition(Vec2f(-spritesize*60,-spritesize*40));
		}
	}
}