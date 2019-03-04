#include "GameColours.as"
#include "Blood.as"
#include "SoldierCommon.as"
#include "Sparks.as"
#include "ExplosionParticles.as"
#include "Explosion.as"

const f32 MAX_VELOCITY = 9.5f;
const f32 ACCELERATION = 0.09f;
const f32 STEERING = 6.00f;
const f32 BLAST_RADIUS = 34.0f;
const f32 DAMAGE = 5.5f;
const f32 CROSSHAIR_PULL = 0.2f;

void onInit(CBlob@ this)
{
	this.getShape().SetGravityScale(0.7f);
	ShapeConsts@ consts = this.getShape().getConsts();
	consts.mapCollisions = false;	 // we have our own map collision
	consts.bullet = true;
	consts.net_threshold_multiplier = 4.0f;

	this.Tag("explosive");
	this.Tag("doesn't float");
	this.SetMapEdgeFlags(u8(CBlob::map_collide_none | CBlob::map_collide_nodeath));

	CSprite@ sprite = this.getSprite();
	sprite.SetZ(-100.0f);
	sprite.SetEmitSound("/PatriotLoop.ogg");
	sprite.SetEmitSoundPaused(false);

	this.server_SetTimeToDie(4.5f);   // safety
}

void onTick(CBlob@ this)
{
	if (this.getShape().isStatic()){
		return;
	}

	const bool isServer = getNet().isServer();

	Vec2f pos = this.getPosition();
	Vec2f vel = this.getVelocity();
	const u32 time = getGameTime();

	Rotate(this, vel);

	// this gathers HitInfo objects which contain blob or tile hit information
	HitInfo@[] hitInfos;
	if (getMap().getHitInfosFromRay(pos, -vel.Angle(), vel.Length() + 2, this, @hitInfos))
	{
		//HitInfo objects are sorted, first come closest hits
		for (uint i = 0; i < hitInfos.length; i++)
		{
			HitInfo@ hi = hitInfos[i];
			CBlob@ b = hi.blob;
			if (b is this) continue;

			//anything else
			if (b !is null)
			{
				onHitBlob(this, b);
			}
			else
			{
				onHitMap(this, hi.hitpos, vel);
			}
		}
	}

	for (uint i = 0; i < this.getAttachmentPointCount(); i++)
	{
		AttachmentPoint@ at = this.getAttachmentPoint(i);
		CBlob@ b = at.getOccupied();
		if (b is null) continue;

		Soldier::Data@ data = Soldier::getData(b);
		if (data is null)
			continue;

		if (b.getTeamNum() == this.getTeamNum())
		{
			if (b.isKeyJustPressed(key_jump) && !data.dead && data.stunTime == 0)
			{
				b.server_DetachFromAll();
			}
		}
		else
		{
			data.stunTime = 30;
		}

	}

	// default vector

	Vec2f vector = vel;

	// effects
	f32 len = vel.Normalize();
	int ticks = this.getTickSinceCreated();
	if (len > 0 && ticks > 2)
	{
		//thrust
		Vec2f partVel = vel * -1.5f;
		//position particles
		Vec2f offset = vel * -1.0f;
		len = offset.Normalize();
		offset *= 8.0f;
		int k = (MAX_VELOCITY - Maths::Floor(len)) / 3;

		Vec2f partpos = pos + offset;
		//streak
		if (time % (1 + k) == 0)
		{
			Particles::TinyFires(partpos, 1, partVel, 1.0f);
		}
		//puffs
		if (time % (3 + k) == 0)
		{
			Particles::TinySmokes(partpos, 3, partVel, 2.5f);
		}
	}
}

void onDie(CBlob@ this)
{
	if (this.hasTag("explosive"))
	{
		Vec2f pos = this.getPosition();

		//attempt to move out of ground if needed (step back 1)
		CMap@ map = getMap();
		if(map.isTileSolid(map.getTile(pos)))
		{
			Vec2f vel = this.getOldVelocity();
			pos -= vel;
			this.setPosition(pos);
		}

		Explode(this, BLAST_RADIUS, DAMAGE);
		for (uint i = 0; i < this.getAttachmentPointCount(); i++)
		{
			AttachmentPoint@ at = this.getAttachmentPoint(i);
			CBlob@ b = at.getOccupied();
			if (b !is null)
			{
				this.server_Hit(
				    b, b.getPosition(),
				    Vec2f(0, -1),
				    DAMAGE,
				    0,
				    true
				);
			}
		}
		if (getNet().isClient())
		{
			Particles::Sparks(pos, 17, 21.0f, SColor(Colours::RED));
			Particles::Sparks(pos, 8, 21.0f, SColor(Colours::YELLOW));
			Particles::Explosion(pos, 4, Vec2f());

			if (!Sound::isTooFar(pos))
			{
				ShakeScreen2(35.0f, 17, pos);
				this.getSprite().PlaySound("PatriotExplosion");
			}
			else
			{
				Sound::Play2D("DistantDynamite", 0.5f, pos.x > getCamera().getPosition().x ? 1.0f : -1.0f);
			}
		}
	}
}

void onHitBlob(CBlob@ this, CBlob@ blob)
{
	if (blob.isAttached())
	{
		return;
	}

	// attach to rocket

	// except owner in first seconds
	if (this.getDamageOwnerPlayer() !is null &&
	        this.getDamageOwnerPlayer() is blob.getDamageOwnerPlayer() &&
	        this.getTickSinceCreated() < 40)
	{
		return;
	}

	//explosives colliding
	if(blob.hasTag("explosive"))
	{
		this.server_Die();
		return;
	}

	// medic shield
	if (blob.hasTag("player"))
	{
		Vec2f pos = this.getPosition();
		Soldier::Data@ data = Soldier::getData(blob);
		if (data.shield)
		{
			if ((data.facingLeft && pos.x < data.pos.x) || (!data.facingLeft && pos.x > data.pos.x))
			{
				data.vel.x = -data.vel.x * 0.9f;
				blob.setVelocity(data.vel);
			}
			return;
		}
	}

	// pick free ap
	int count = this.getAttachmentPointCount();
	for (int i = 0; i < count; i++)
	{
		AttachmentPoint @ap = this.getAttachmentPoint(i);
		if (ap.getOccupied() is null)
		{
			this.server_AttachTo(blob, ap);
			break;
		}
	}
}

void onHitMap(CBlob@ this, Vec2f worldPoint, Vec2f velocity)
{
	Particles::Sparks(worldPoint, 3, 10.0f, SColor(Colours::YELLOW));
	Particles::Sparks(worldPoint, 5, 6.0f, SColor(Colours::RED));
	// kill on client
	this.getShape().SetStatic(true);

	Die(this);

	CCamera@ camera = getCamera();
	if (camera !is null)
	{
		Vec2f listener = camera.getPosition();
		Vec2f vector = listener - worldPoint;
		velocity.Normalize();
		const f32 distance = vector.Normalize();
		CSprite@ sprite = this.getSprite();
		f32 volume = Maths::Min(distance, 100.0f) / 100.0f;
		sprite.PlayRandomSound("BulletImpact", volume);
		sprite.PlayRandomSound(vector * velocity < 0.0f ? "RicochetOut" : "RicochetIncoming", 1.0f - volume);
	}
}

void Die(CBlob@ this)
{
	this.server_Die();
}

void Rotate(CBlob@ this, Vec2f aimvector)
{
	CSprite@ sprite = this.getSprite();
	sprite.ResetTransform();
	sprite.TranslateBy(Vec2f(XORRandom(aimvector.Length() + 2), 0));
	//sprite.ScaleBy( Vec2f(0.33f + aimvector.Length()/15.0f, 1.0f) );
	sprite.RotateBy(-aimvector.getAngleDegrees() - this.getAngleDegrees(), Vec2f_zero);
}

