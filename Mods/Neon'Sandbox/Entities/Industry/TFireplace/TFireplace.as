// Fireplace

#include "ProductionCommon.as";
#include "Requirements.as"
#include "MakeFood.as"
#include "FireParticle.as"

void onInit(CBlob@ this)
{
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 9;
	this.getSprite().SetEmitSound("CampfireSound.ogg");

	this.SetLight(true);
	this.SetLightRadius(164.0f);
	//this.SetLightColor(SColor(255, 255, 240, 171));
	if(this !is null)
	{
		switch(this.getTeamNum())
		{
			case 0:
				this.SetLightColor(SColor(255,44, 175, 222));
				break;
			case 1:
				this.SetLightColor(SColor(255, 213, 84, 63));
				break;
			case 2:
				this.SetLightColor(SColor(255, 157, 202, 34));
				break;
			case 3:
				this.SetLightColor(SColor(255, 211, 121, 224));
				break;
			case 4:
				this.SetLightColor(SColor(255, 254, 165, 61));
				break;
			case 5:
				this.SetLightColor(SColor(255, 46, 229, 162));
				break;
			case 6:
				this.SetLightColor(SColor(255, 95, 132, 236));
				break;
			default:
				this.SetLightColor(SColor(255, 255, 240, 171));
		}
	}


	this.Tag("fire source");
	//this.server_SetTimeToDie(60*3);
	this.getSprite().SetZ(-50.0f);
}

void onTick(CBlob@ this)
{
	if (XORRandom(3) == 0)
	{
		makeSmokeParticle(this.getPosition(), -0.05f);

		this.getSprite().SetEmitSoundPaused(false);
	}
	else
		makeFireParticle(this.getPosition() + getRandomVelocity(90.0f, 3.0f, 360.0f));

	if (this.isInWater())
	{
		this.getSprite().Gib();
		this.server_Die();
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
}


void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null)
	{
		if (blob.getName() == "fishy")
		{
			blob.getSprite().PlaySound("SparkleShort.ogg");
			server_MakeFood(blob.getPosition(), "Cooked Fish", 1);
			blob.server_Die();
		}
	}
}

void onInit(CSprite@ this)
{
	this.SetZ(-50); //background

	//init flame layer
	CSpriteLayer@ fire = this.addSpriteLayer("fire_animation_large", "Entities/Effects/Sprites/TLargeFire.png", 16, 16, -1, -1);

	if (fire !is null)
	{
		fire.SetRelativeZ(100);
		{
			Animation@ anim = fire.addAnimation("bigfire", 6, true);
			anim.AddFrame(1);
			anim.AddFrame(2);
			anim.AddFrame(3);
		}
		{
			Animation@ anim = fire.addAnimation("smallfire", 6, true);
			anim.AddFrame(4);
			anim.AddFrame(5);
			anim.AddFrame(6);
		}
		fire.SetVisible(true);
	}
}
