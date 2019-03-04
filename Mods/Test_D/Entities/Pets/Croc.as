#include "Timers.as"
#include "Blood.as"
#include "Pets.as"

const int BITE_TIME = 10;
const float BITE_DISTANCE = 16.0f;
const float LAND_SPEED = 0.75f;

void onInit(CBlob@ this)
{
//	this.getShape().getConsts().transports = true;
//	this.getShape().getConsts().collideWhenAttached = false;
}

void onTick(CBlob@ this)
{
	if (!isBiting(this))
	{
		// swim

		Vec2f pos = this.getPosition();
		Vec2f vel = this.getVelocity();
		if (!this.isOnGround())
		{
			if (this.isFacingLeft())
			{
				if (vel.x > -1.0f)
				{
					vel.x -= 0.05f;
				}
			}
			else
			{
				if (vel.x < 1.0f)
				{
					vel.x += 0.05f;
				}
			}
		}
		else
		{
			CBlob@ owner = getBlobByNetworkID(this.get_netid("owner"));
			if (owner !is null)
			{
				Vec2f ownerPos = owner.getPosition();
				f32 keepDistance = 50.0f;
				if (ownerPos.x > pos.x + keepDistance)
				{
					vel.x += 0.4f;
					this.SetFacingLeft(false);
				}
				else if (ownerPos.x < pos.x - keepDistance)
				{
					vel.x -= 0.4f;
					this.SetFacingLeft(true);
				}
			}

			if (vel.x > LAND_SPEED)
				vel.x = LAND_SPEED;
			if (vel.x < -LAND_SPEED)
				vel.x = -LAND_SPEED;
		}

		this.setVelocity(vel);

		if (vel.getLength() > 0.4f && !this.isOnWall()){
			this.getSprite().SetAnimation("walk");
		}
		else{
			this.getSprite().SetAnimation("default");
		}
	}
}

void Bite( CBlob@ this, CBlob@ victim, bool deadly )
{
	if (!isBiting(this))
	{
		this.set_u32("croc bite time", getGameTime());
		CSprite@ sprite = this.getSprite();
		sprite.SetAnimation("bite");
		sprite.PlaySound("StartChomp");

		if (deadly && victim !is null){
			victim.server_Die();
			Particles::Blood(victim.getPosition(), 10 * 5, 10.0f);
		}
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (this.isAttached() || this.hasAttached())
	{
		return;
	}

	Vec2f pos = this.getPosition();
	if (blob is null)
	{
		if (this.isFacingLeft() && point1.x < pos.x)
		{
			this.SetFacingLeft(false);
		}
		else if (point1.x > pos.x)
		{
			this.SetFacingLeft(true);
		}
		return;
	}

	if (blob.hasTag("player"))
	{		
		Bite( this, blob, false );
	}

	const u8 petType = getPetType(blob);
	if ((blob.getName() == "toy" && (petType == TOY_HAMBURGER))
	 || (blob.getName() == "pet") && (petType == PARROT || petType == BUNNY || petType == CHICKEN || petType == CAT))
	{
		if ((!this.isFacingLeft() && point1.x > pos.x)
		     || (this.isFacingLeft() && point1.x < pos.x))
		{
			Bite( this, blob, true );
		}
	}


	if (normal.y > 0.5f)
	{
		Vec2f vel = blob.getVelocity();
		vel.y = -9.0f;
		blob.setVelocity(vel);
	}
}

bool isBiting(CBlob@ this)
{
	return getGameTime() - this.get_u32("croc bite time") < BITE_TIME;
}
