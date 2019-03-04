#include "Tiles.as";

void onInit(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	sprite.SetZ(100.0f);

	if (!this.exists("background"))
		this.set_bool("background", false);

	if (!this.exists("frame"))
		this.set_u16("frame", CMap::tile_dirt);
	
	if (!this.exists("damage"))
		this.set_f32("damage", 0.25);

	sprite.SetFrameIndex(this.get_u16("frame"));

	this.getShape().SetRotationsAllowed(false);

	this.setVelocity(Vec2f(0.0f, 1.0f)); //(XORRandom(101.0f)-50.0f)/7
}

void onTick(CBlob@ this)
{
	CMap@ map = getMap();
	Vec2f pos = this.getPosition();
	Vec2f vel = this.getVelocity();

	const bool background = this.get_bool("background");

	bool die = false;
	if ((isBlockSolid(map, map.getTileOffset(pos + Vec2f(0, 4)))) && vel.y > -0.1f && this.getTickSinceCreated() > 2 )
	{
		die = true;
	}

	if (die)
	{
		if (getNet().isServer())
		{
			this.server_Die();
			if(!background)
				map.server_SetTile(pos, this.get_u16("frame"));
		}
		return;
	}

	{
		//vel.x = 0.0f;
		//this.setVelocity(vel);

		if (Maths::Abs(vel.y) < 0.1f && this.isOnGround()) {
			this.server_Die();
		}
	}

	if (vel.getLengthSquared() > 0 && !background)
	{
		const bool isServer = getNet().isServer();
		HitInfo@[] hitInfos;
		if (getMap().getHitInfosFromRay(pos, -vel.Angle(), vel.Length()+5, this, @hitInfos))
		{
			//HitInfo objects are sorted, first come closest hits
			for (uint i = 0; i < hitInfos.length; i++)
			{
				HitInfo@ hi = hitInfos[i];
				CBlob@ b = hi.blob;
				if (b is null || b is this) continue;
				
				if (b.hasTag("material") || b.hasTag("invincible") || b.getName() == "egg") continue;

				if (isServer)
				{
					int customData = 0;
					if (b.getTeamNum() == this.getTeamNum()) continue;
					
					f32 dmg = this.get_f32("damage");
					if(!b.hasTag("flesh"))
						dmg *= 20;

					this.server_Hit(b, hi.hitpos, vel, dmg, customData, true);
				}
			}
		}	
	}
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	this.getSprite().PlaySound("catapult_hit");
	hitBlob.setVelocity(this.getVelocity() + Vec2f(0.0f, -2.0f));
	this.server_Die();
}
/*
void CollisionParticles(Vec2f pos, f32 amountMod = 1.0f)
{
	Random _r(getGameTime());
	Particles::Sparks(pos + Vec2f(-4.0f + _r.NextRanged(8), -4.0f + _r.NextRanged(8)), 30*amountMod, 10.0f, Colours::YELLOW);
	if (amountMod >= 1.0f)
		Particles::TileGibs(pos, 5*amountMod, 15.0f, 1);
}*/

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

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	const bool background = this.get_bool("background");
	if(background && (!blob.getShape().isStatic() || blob.getName() == "spikes"))
		return false; //blob.hasTag("flesh")
	return true;
}

void onDie(CBlob@ this)
{
	this.getSprite().PlaySound("catapult_destroy");
	//CollisionParticles(this.getPosition());
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