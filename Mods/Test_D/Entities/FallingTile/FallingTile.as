
#include "GameColours.as"
#include "Sparks.as"
#include "ExplosionParticles.as";
#include "MapCommon.as"
#include "SoldierCommon.as"

void onInit(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	sprite.SetZ(100.0f);

	if (!this.exists("smash_fall"))
		this.set_bool("smash_fall", false);

	if (!this.exists("frame"))
		this.set_u8("frame", TWMap::tile_crate_1);

	sprite.SetFrameIndex(this.get_u8("frame"));

	this.getShape().SetRotationsAllowed(false);

	this.setVelocity(Vec2f(0, 1));
}

void onTick(CBlob@ this)
{
	CMap@ map = getMap();
	Vec2f pos = this.getPosition();
	Vec2f vel = this.getVelocity();

	const bool smash = this.get_bool("smash_fall");

	bool die = false;
	if (!smash && (TWMap::isTileTypeSolid(map.getTile(pos + Vec2f(0, map.tilesize)).type)) && vel.y > -0.1f)
	{
		die = true;
	}
	else if (smash && this.getTickSinceCreated() > 5 && (this.isOnGround() || this.isOnWall()))
	{
		die = true;
	}

	if (die)
	{
		if (getNet().isServer())
		{
			this.server_Die();
			map.server_SetTile(pos, this.get_u8("frame"));
		}
		return;
	}

	if (!smash)
	{
		vel.x = 0.0f;
		this.setVelocity(vel);

		if (Maths::Abs(vel.y) < 0.1f && this.isOnGround()) {
			this.server_Die();
		}
	}

	if (vel.getLengthSquared() > 0)
	{
		const bool isServer = getNet().isServer();
		HitInfo@[] hitInfos;
		if (getMap().getHitInfosFromRay(pos, -vel.Angle(), vel.Length(), this, @hitInfos))
		{
			//HitInfo objects are sorted, first come closest hits
			for (uint i = 0; i < hitInfos.length; i++)
			{
				HitInfo@ hi = hitInfos[i];
				CBlob@ b = hi.blob;
				if (b is null || b is this) continue;

				if (isServer)
				{
					int customData = 0;
					if (b.getTeamNum() == this.getTeamNum()) continue;

					this.server_Hit(b, hi.hitpos,
					                vel, 3.0f,
					                customData, true);
				}
			}
		}	
	}
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	this.getSprite().PlaySound("Crush");
	hitBlob.setVelocity(this.getVelocity() + Vec2f(0.0f, -2.0f));
	this.server_Die();
}

void CollisionParticles(Vec2f pos, f32 amountMod = 1.0f)
{
	Random _r(getGameTime());
	Particles::Sparks(pos + Vec2f(-4.0f + _r.NextRanged(8), -4.0f + _r.NextRanged(8)), 30*amountMod, 10.0f, Colours::YELLOW);
	if (amountMod >= 1.0f)
		Particles::TileGibs(pos, 5*amountMod, 15.0f, 1);
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (damage > 0.0f)
	{
		this.Damage(damage, hitterBlob);
	}

	if (this.getHealth() <= 0.0f)
	{
		this.server_Die();
	}
	return 0.0f; //done, we've used all the damage
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	bool smash = this.get_bool("smash_fall");

	//hit map
	if (smash && blob is null && Maths::Abs(normal.y) < 0.1f)
	{
		Vec2f vel = this.getVelocity();
		vel.x *= -0.5f;
		this.setVelocity(vel);
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return false;
}

void onDie(CBlob@ this)
{
	this.getSprite().PlaySound("CrateHit");
	CollisionParticles(this.getPosition());
}

/*
	Vec2f vel = this.getVelocity();
	Vec2f velnorm = vel;
	velnorm.Normalize();

	if (blob !is null && blob.getName() != this.getName() && velnorm * normal < -0.25f)
	{
		this.server_Hit(blob, point1,
		                vel, smash ? 1.0f : 3.0f,
		                0, false);

		Soldier::Data@ data = Soldier::getData( blob );
		if(data !is null)
		{
			data.stunTime = 30;
		}
	}
	this.getSprite().PlaySound("Crush");
	hitBlob.setVelocity(this.getVelocity());

	CollisionParticles(this.getPosition());

	this.server_Die();

	// movable crates
	if (blob !is null && blob.getPlayer() !is null && this.hasTag("resting"))
	{
		this.SetDamageOwnerPlayer( blob.getPlayer() );
	}	
*/