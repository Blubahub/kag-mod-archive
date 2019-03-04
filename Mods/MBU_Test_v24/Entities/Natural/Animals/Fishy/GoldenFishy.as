
//Tastes cold and metallic and like nothing and oh no

#include "AnimalConsts.as";
#include "HumanoidCommon.as";

//sprite

const array<array<string>> anims =
{
	{"speck_default", "speck_idle", "speck_dead"},
	{"baby_default", "baby_idle", "baby_dead"},
	{"young_default", "young_idle", "young_dead"},
	{"default", "idle", "dead"}
};

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	u8 age = Maths::Min(blob.get_u8("age"), 3);
	
	this.SetZ(1001.0f);

	if (!blob.hasTag("dead"))
	{
		if (blob.isKeyPressed(key_left) ||
		        blob.isKeyPressed(key_right) ||
		        blob.isKeyPressed(key_up) ||
		        blob.isKeyPressed(key_down))
		{
			this.SetAnimation(anims[age][0]);
		}
		else
		{
			this.SetAnimation(anims[age][1]);
		}
	}
	else
	{
		this.SetAnimation(anims[age][2]);
	}
}

//blob

void onInit(CBlob@ this)
{
	this.set_u8(personality_property, SCARED_BIT | STILL_IDLE_BIT);
	this.set_f32(target_searchrad_property, 56.0f);

	this.getBrain().server_SetActive(true);

	this.set_f32("swimspeed", 0.5f);
	this.set_f32("swimforce", 0.1f);
	this.Tag("builder always hit");

	this.getShape().SetGravityScale(0.0f);
	
	this.getCurrentScript().tickFrequency = 40;

	if (!this.exists("age"))
		this.set_u8("age", 0);
		
	this.Tag("edible");
}

void onTick(CBlob@ this)
{
	f32 x = this.getVelocity().x;
	this.SetFacingLeft(x < 0);
	/*
		if (Maths::Abs(x) > 0.0f)
		{
			this.SetFacingLeft(x < 0);
		}
		else
		{
			if (this.isKeyPressed(key_left))
				this.SetFacingLeft(true);
			if (this.isKeyPressed(key_right))
				this.SetFacingLeft(false);
		}
	*/

	if (getNet().isServer())
	{
		u8 age = this.get_u8("age");
		if (age < 3)
		{
			if (XORRandom(512) < 16)
			{
				age++;
			}

			this.set_u8("age", age);
			this.Sync("age", true);
		}
		else if (XORRandom(512) < 4)
		{
			this.server_Hit(this, this.getPosition(), Vec2f(0, 0), 1.0f, 0, true); //death from old age
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if(damage == 0)
		return damage;

	if(this.getHealth() < 10.0f){
		u8 age = this.get_u8("age");

		this.Tag("dead");
		this.AddScript("Eatable.as");
		this.getShape().getConsts().buoyancy = 0.8f;
		this.getShape().getConsts().collidable = true;
		this.server_SetTimeToDie(40);

		CSprite@ sprite = this.getSprite();

		sprite.SetAnimation(anims[age][2]);

		sprite.SetFacingLeft(!sprite.isFacingLeft());
	}

	return damage;
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(blob !is null)
	if(blob.hasTag("flesh") && !this.hasTag("dead") && blob.getName() == "humanoid")
	{
		bool die = false;
		if(isFlesh(blob.get_s8("torso_type"))){attachLimb(blob, "torso", BodyType::Gold);die = true;}
		if(isFlesh(blob.get_s8("head_type"))){attachLimb(blob, "head", BodyType::Gold);die = true;}
		if(isFlesh(blob.get_s8("main_arm_type"))){attachLimb(blob, "main_arm", BodyType::Gold);die = true;}
		if(isFlesh(blob.get_s8("sub_arm_type"))){attachLimb(blob, "sub_arm", BodyType::Gold);die = true;}
		if(isFlesh(blob.get_s8("front_leg_type"))){attachLimb(blob, "front_leg", BodyType::Gold);die = true;}
		if(isFlesh(blob.get_s8("back_leg_type"))){attachLimb(blob, "back_leg", BodyType::Gold);die = true;}
		
		if(isServer())
		if(die)this.server_Die();
	}	
}

void onDie(CBlob @this){
	CBlob @blob = getBlobByNetworkID(this.get_netid("eater"));
	if(blob !is null){
		if(isFlesh(blob.get_s8("torso_type")))attachLimb(blob, "torso", BodyType::Gold);
		if(isFlesh(blob.get_s8("head_type")))attachLimb(blob, "head", BodyType::Gold);
		if(isFlesh(blob.get_s8("main_arm_type")))attachLimb(blob, "main_arm", BodyType::Gold);
		if(isFlesh(blob.get_s8("sub_arm_type")))attachLimb(blob, "sub_arm", BodyType::Gold);
		if(isFlesh(blob.get_s8("front_leg_type")))attachLimb(blob, "front_leg", BodyType::Gold);
		if(isFlesh(blob.get_s8("back_leg_type")))attachLimb(blob, "back_leg", BodyType::Gold);
	}
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob ){
	return false;
}