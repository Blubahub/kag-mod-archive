// Stick Fire

#include "ProductionCommon.as";
#include "Requirements.as"
#include "MakeFood.as"
#include "FireParticle.as"
#include "Hitters.as"

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 9;
	this.getSprite().SetEmitSound("CampfireSound.ogg");
	this.set_u16("wood_amount", 180);
	this.SetLight(true);
	this.SetLightRadius(0.0f);
	this.SetLightColor(SColor(255, 255, 240, 171));

	this.Tag("fire source");
	//this.server_SetTimeToDie(60*3);
	this.getSprite().SetZ(-20.0f);
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if(this.get_u16("wood_amount")-(damage*10) > 0)this.set_u16("wood_amount", this.get_u16("wood_amount")-(damage*10));
	else this.server_Die();
	
	if (hitterBlob !is this)
	{
		this.getSprite().PlayRandomSound("/WoodHit", Maths::Min(1.25f, Maths::Max(0.5f, damage)));
		makeGibParticle("/GenericGibs", worldPoint, getRandomVelocity((this.getPosition() - worldPoint).getAngle(), 1.0f + damage, 90.0f) + Vec2f(0.0f, -2.0f),
					1, 4 + XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
	}
	
	//ignore all damage
	return 0.0f;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null)
	{
		if (blob.getName() == "stick" && this.get_u16("wood_amount") < 120*10)
		{
			blob.getSprite().PlaySound("SparkleShort.ogg");
			this.set_u16("wood_amount", this.get_u16("wood_amount")+60);
			blob.server_Die();
		} else
		if (blob.getName() == "log" && this.get_u16("wood_amount") < 120*10)
		{
			blob.getSprite().PlaySound("SparkleShort.ogg");
			this.set_u16("wood_amount", this.get_u16("wood_amount")+(60*2));
			blob.server_Die();		
		} else
		if(getNet().isServer())
		if(blob.hasTag("flesh") || blob.hasTag("wooden")){
			
			bool burn = false;
			
			if(this.get_u16("wood_amount") > 120*8)burn = true;
			
			if(this.get_u16("wood_amount") > 120*6)if(XORRandom(2) == 0)burn = true;
			
			if(this.get_u16("wood_amount") > 120*4)if(XORRandom(4) == 0)burn = true;
			
			if(this.get_u16("wood_amount") > 120*2)if(XORRandom(8) == 0)burn = true;
			
			if(burn)this.server_Hit(blob, this.getPosition(), Vec2f(0,0), 0.5, Hitters::fire, true);
		}
	}
}
void onTick(CBlob@ this)
{
// make this smoke more if it's getting low
	if (this.get_u16("wood_amount") < 120)
	{
		this.getSprite().SetEmitSoundPaused(false);	
		if (XORRandom(2) == 0)
		{
			makeSmokeParticle(this.getPosition()+Vec2f(0,1), -0.05f);
		}
	}
	else
	{
		this.getSprite().SetEmitSoundPaused(false);
		if (XORRandom(5) == 0)
		{
			makeSmokeParticle(this.getPosition(), -0.05f);
		}
		for(int i = 0; i < this.get_u16("wood_amount")/120+1; i+= 1){
			makeFireParticle(this.getPosition() + Vec2f(XORRandom(16)-8,(-XORRandom(16)*(i/10.0f))+6));
		}
	}
	
	if(this.get_u16("wood_amount") > 0){
		if (this.get_u16("wood_amount")/120 < 10)
			this.getSprite().SetFrame(this.get_u16("wood_amount")/120+1);
		else
			this.getSprite().SetFrame(10);
	} else {
		this.getSprite().SetFrame(0);
	}
			
	if (this.isInWater())
	{
		this.getSprite().Gib();
		this.server_Die();
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
}

void onInit(CSprite@ this)
{
	this.SetZ(-50); //background

	//init flame layer
	CSpriteLayer@ fire = this.addSpriteLayer("fire_animation_large", "Entities/Effects/Sprites/LargeFire.png", 16, 16, -1, -1);

	if (fire !is null)
	{
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
}
void onTick(CSprite@ this)
{
    CSpriteLayer@ fire = this.getSpriteLayer("fire_animation_large");
	if(fire !is null){
		CBlob @blob = this.getBlob();
		if (blob.get_u16("wood_amount") > 120)
			fire.SetVisible(true);
		else
			fire.SetVisible(false);
	}
}