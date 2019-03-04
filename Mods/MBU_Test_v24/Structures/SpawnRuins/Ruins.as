// TDM Ruins logic

#include "FireParticle.as"

void onInit(CBlob@ this)
{
	this.CreateRespawnPoint("ruins", Vec2f(0.0f, 16.0f));
	this.getShape().SetStatic(true);
	this.getShape().getConsts().mapCollisions = false;

	this.getSprite().SetZ(-50.0f);   // push to background
	this.set_Vec2f("nobuild extend", Vec2f(0.0f, 0.0f));
	
	this.SetLight(true);
	this.SetLightRadius(164.0f);
	this.SetLightColor(SColor(255, 255, 240, 171));
	
	this.getCurrentScript().tickFrequency = 9;
	this.getSprite().SetEmitSound("CampfireSound.ogg");
}


void onTick(CBlob@ this)
{
	if (XORRandom(3) == 0) {
		makeSmokeParticle(this.getPosition()+Vec2f(-16,-22), -0.05f);
		makeSmokeParticle(this.getPosition()+Vec2f(16,-22), -0.05f);

		this.getSprite().SetEmitSoundPaused(false);
	} else {
		makeFireParticle(this.getPosition()+Vec2f(-16,-22) + getRandomVelocity(90.0f, 3.0f, 360.0f));
		makeFireParticle(this.getPosition()+Vec2f(16,-22) + getRandomVelocity(90.0f, 3.0f, 360.0f));
	}
}

void onInit(CSprite@ this)
{
	this.SetZ(-50); //background

	//init flame layer
	{
		CSpriteLayer@ fire = this.addSpriteLayer("fire_animation_large1", "Entities/Effects/Sprites/LargeFire.png", 16, 16, -1, -1);
		if (fire !is null)
		{
			fire.SetRelativeZ(100);
			{
				Animation@ anim = fire.addAnimation("bigfire", 4, true);
				anim.AddFrame(4);
				anim.AddFrame(5);
				anim.AddFrame(6);
			}
			fire.SetVisible(true);
			fire.SetOffset(Vec2f(-17,-25));
		}
	}
	
	{
		CSpriteLayer@ fire = this.addSpriteLayer("fire_animation_large2", "Entities/Effects/Sprites/LargeFire.png", 16, 16, -1, -1);
		if (fire !is null)
		{
			fire.SetRelativeZ(100);
			{
				Animation@ anim = fire.addAnimation("bigfire", 4, true);
				anim.AddFrame(5);
				anim.AddFrame(6);
				anim.AddFrame(4);
			}
			fire.SetVisible(true);
			fire.SetOffset(Vec2f(17,-25));
		}
	}
}