
//script for a chicken

#include "AnimalConsts.as";

const u8 DEFAULT_PERSONALITY = 0;

//sprite

void onInit(CSprite@ this)
{
	this.ReloadSprites(0, 0); //always blue

}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
	this.SetAnimation("idle");
}

//blob

void onInit(CBlob@ this)
{
	this.set_f32("bite damage", 0.25f);

	//brain
	this.set_u8(personality_property, DEFAULT_PERSONALITY);
	this.getBrain().server_SetActive(true);
	this.set_f32(target_searchrad_property, 30.0f);
	this.set_f32(terr_rad_property, 160.0f);
	this.set_u8(target_lose_random, 14);

	//for shape
	this.getShape().SetRotationsAllowed(false);

	//for flesh hit
	this.set_f32("gib health", -0.0f);

	this.getShape().SetOffset(Vec2f(0, 7));

	this.getCurrentScript().runFlags |= Script::tick_blob_in_proximity;
	this.getCurrentScript().runProximityTag = "player";
	this.getCurrentScript().runProximityRadius = 320.0f;

	// movement

	AnimalVars@ vars;
	if (!this.get("vars", @vars))
		return;
	vars.walkForce.Set(2.0f, -0.1f);
	vars.runForce.Set(2.0f, -1.0f);
	vars.slowForce.Set(1.0f, 0.0f);
	vars.jumpForce.Set(0.0f, -10.0f);
	vars.maxVelocity = 1.1f;
	
	this.SetLight(true);
	this.SetLightColor(SColor(11, 213, 255, 171));
	this.SetLightRadius(16.0f);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return true; //maybe make a knocked out state? for loading to cata?
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return !blob.hasTag("flesh");
}

void onTick(CBlob@ this)
{
	f32 x = this.getVelocity().x;
	if (Maths::Abs(x) > 0.0f)
	{
		this.SetFacingLeft(x < 0);
	}
	else
	{
		if (this.isKeyPressed(key_left))
		{
			this.SetFacingLeft(true);
		}
		if (this.isKeyPressed(key_right))
		{
			this.SetFacingLeft(false);
		}
	}

	int Height = 1;
	int OldHeight = 1;
	CMap@ map = this.getMap();
	Vec2f surfacepos;
	for(int i = 0; i < 15; i += 1){
		if(!map.rayCastSolid(this.getPosition(), this.getPosition()+Vec2f(0,16*i), surfacepos))Height += 1;
		else {
			this.set_u16("lastHeight",surfacepos.y);
			break;
		}
	}
	for(int i = 0; i < 15; i += 1){
		if(this.getPosition().y+16*i < this.get_u16("lastHeight"))OldHeight += 1;
		else {
			break;
		}
	}
	if(Height > 14)Height = OldHeight;
	this.AddForce(Vec2f(0, -(10+XORRandom(20))/Height));
	
	/*
	if (!this.isOnGround())
	{
		Vec2f vel = this.getVelocity();
		if (vel.y > 0.5f)
		{
			this.AddForce(Vec2f(0, -10));
		}
	}*/
}


