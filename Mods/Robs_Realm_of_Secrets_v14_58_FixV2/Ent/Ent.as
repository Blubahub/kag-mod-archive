#include "MakeMat.as";
#include "Hitters.as";

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	if (!blob.hasTag("dead"))
	{
		f32 x = Maths::Abs(blob.getVelocity().x);
		if (x > 0.02f)
		{
			this.SetAnimation("walk");
		}
		else
		{
			this.SetAnimation("idle");
		}
	}
	else
	{
		this.SetAnimation("dead");
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
}

//blob

void onInit(CBlob@ this)
{
	
	this.getBrain().server_SetActive(true);
	
	//for shape
	this.getShape().SetRotationsAllowed(false);
	
	this.set_f32("gib health", -0.0f);
	this.Tag("plant");
	
	this.getShape().SetOffset(Vec2f(0, 6));

	this.getCurrentScript().runFlags |= Script::tick_blob_in_proximity;
	this.getCurrentScript().runProximityTag = "player";
	this.getCurrentScript().runProximityRadius = 320.0f;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if(blob.hasTag("onewithnature"))return false;
	return (this.getTeamNum() != blob.getTeamNum() || blob.getShape().isStatic());
}

void onTick(CBlob@ this)
{
	f32 x = this.getVelocity().x;
	
	if (Maths::Abs(x) > 1.0f)
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
	
	if(this.isOnGround()){
		if(XORRandom(20) == 0){
			this.AddForce(Vec2f((XORRandom(2)*2-1)*10,-40));
		}
	}
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(blob !is null && blob.hasTag("flesh") && !blob.hasTag("onewithnature"))
	{
		if(getNet().isServer()){
			blob.server_Hit(blob, this.getPosition(), this.getVelocity()*-0.5f, 0.25f, Hitters::suddengib, false);
			blob.set_s16("poison",8);
		}
	}
}

void onDie(CBlob @this){
	if (getNet().isServer()){
		for(int i = 0; i < 5+XORRandom(5); i += 1){
			server_CreateBlob("log", this.getTeamNum(), this.getPosition() + Vec2f(XORRandom(32)-16, XORRandom(32)-16));
		}
		for(int i = 0; i < 1+XORRandom(3); i += 1){
			server_CreateBlob("derangedwisp", this.getTeamNum(), this.getPosition() + Vec2f(XORRandom(32)-16, XORRandom(32)-16));
		}
	}
	ParticlesFromSprite(this.getSprite());
}