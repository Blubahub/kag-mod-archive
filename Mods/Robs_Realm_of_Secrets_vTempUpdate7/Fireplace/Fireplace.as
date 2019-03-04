// Fireplace

#include "ProductionCommon.as";
#include "Requirements.as"
#include "MakeFood.as"
#include "FireParticle.as"
#include "Cooking.as";

void onInit(CBlob@ this)
{
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 9;
	this.getSprite().SetEmitSound("CampfireSound.ogg");

	this.SetLight(true);
	this.SetLightRadius(164.0f);
	this.SetLightColor(SColor(255, 255, 240, 171));

	this.Tag("fire source");
	//this.server_SetTimeToDie(60*3);
	this.getSprite().SetZ(-500.0f);
	
	this.Tag("builder always hit");
	
	this.addCommandID("forge");
}

void onTick(CBlob@ this)
{
	if (XORRandom(3) == 0)
	{
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
		if (canBeCooked(blob))
		{
			blob.getSprite().PlaySound("SparkleShort.ogg");
			if(getNet().isServer()){
				CBlob @food = CookedResult(blob);
				if(food !is null){
					food.setVelocity(blob.getVelocity()*0.5);
					blob.server_Die();
				}
			}
		}
	}
}

void onInit(CSprite@ this)
{
	this.SetZ(-50); //background

	//init flame layer
	CSpriteLayer@ fire = this.addSpriteLayer("fire_animation_large", "Entities/Effects/Sprites/LargeFire.png", 16, 16, -1, -1);

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


void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(this.isOverlapping(caller) && caller.getBlobCount("mat_stone") >= 100){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		CButton@ button = caller.CreateGenericButton(12, Vec2f(0,0), this, this.getCommandID("forge"), "Construct a forge. Costs 100 stone.", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("forge"))
	{
		u16 callerID = params.read_u16();
		CBlob@ caller = getBlobByNetworkID(callerID);

		if (caller !is null)
		{
			caller.TakeBlob("mat_stone", 100);
			
			if(getNet().isServer()){
				server_CreateBlob("forge",this.getTeamNum(), this.getPosition()+Vec2f(0,-8));
				this.server_Die();
			}
			this.getSprite().PlaySound("/Construct.ogg");
			this.getSprite().getVars().gibbed = true;
		}
	}
}