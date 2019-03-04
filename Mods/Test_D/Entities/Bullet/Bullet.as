#include "GameColours.as"
#include "Blood.as"

void onInit(CBlob@ this)
{
	this.getShape().SetGravityScale(0.0f);
	ShapeConsts@ consts = this.getShape().getConsts();
	consts.mapCollisions = false;	 // weh ave our own map collision
	consts.bullet = true;
	this.SetMapEdgeFlags(u8(CBlob::map_collide_none | CBlob::map_collide_nodeath));
	this.getSprite().SetZ(-100.0f);
}

void onTick(CBlob@ this)
{
	bool killed = false;

	Vec2f pos = this.getPosition();
	Vec2f vel = this.getVelocity();

	Rotate(this, vel);

	const bool isServer = getNet().isServer();

	// this gathers HitInfo objects which contain blob or tile hit information
	HitInfo@[] hitInfos;
	if (getMap().getHitInfosFromRay(pos, -vel.Angle(), vel.Length(), this, @hitInfos))
	{
		//HitInfo objects are sorted, first come closest hits
		for (uint i = 0; i < hitInfos.length; i++)
		{
			HitInfo@ hi = hitInfos[i];
			CBlob@ b = hi.blob;
			if (b is this) continue;

			if (b is null)
			{
				onHitMap(this, hi.hitpos, vel);
			}
			else if (isServer)
			{
				int customData = 0;

				//  cant shoot own team 					or bullets					or explosives
				if (b.getTeamNum() == this.getTeamNum() || b.getName() == "bullet" /*|| b.hasTag("explosive")*/) continue;

				// deflect
				if (b.hasTag("collide with nades") && !b.hasTag("explosive"))
				{
					Vec2f vel = this.getVelocity();
					if ((b.isFacingLeft() && vel.x >= 0.0f) || (!b.isFacingLeft() && vel.x <= 0.0f))
					{
						f32 len = vel.getLength();
						vel.x *= -0.9f;
						vel.y = vel.y - len / 4 + XORRandom(len / 2);
						this.setVelocity(vel);
						this.server_setTeamNum(b.getTeamNum());
						this.SetDamageOwnerPlayer(b.getPlayer());
						customData = 1;
						//continue;
					}
				}

				if (b.hasTag("crouching"))
				{
					if (hi.hitpos.y < b.getPosition().y - b.getRadius() * 0.5f)
						continue;
				}

				Vec2f force = vel;
				force.Normalize();
				force *= 3.0f;

				this.server_Hit(b, hi.hitpos,
				                force, this.get_f32("damage"),
				                customData, true);

				//  break; //one at a time
			}
		}
	}

	// drop

	if (this.getTickSinceCreated() > 11)
	{
		this.getShape().SetGravityScale(this.getShape().getGravityScale() + 0.25f);
	}
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if (customData == 0)
	{
		Die(this);
	}
}

void onHitMap(CBlob@ this, Vec2f worldPoint, Vec2f velocity)
{
	Particles::Sparks(worldPoint, 3, 10.0f, SColor(Colours::YELLOW));
	Particles::Sparks(worldPoint, 5, 6.0f, SColor(Colours::RED));
	Die(this);

	CCamera@ camera = getCamera();
	if (camera !is null)
	{
		Vec2f listener = camera.getPosition();
		Vec2f vector = listener - worldPoint;
		velocity.Normalize();
		const f32 distance = vector.Normalize();
		//printf("distance " + distance);
		CSprite@ sprite = this.getSprite();
		f32 volume = Maths::Min(distance, 100.0f) / 100.0f;
		sprite.PlayRandomSound("BulletImpact", volume);
		sprite.PlayRandomSound(vector * velocity < 0.0f ? "RicochetOut" : "RicochetIncoming", 1.0f - volume);
	}
}

void Die(CBlob@ this)
{
	this.server_Die();
	this.getCurrentScript().tickFrequency = 0; // switch off client-side
}

void Rotate(CBlob@ this, Vec2f aimvector)
{
	CSprite@ sprite = this.getSprite();
	sprite.ResetTransform();
	sprite.TranslateBy(Vec2f(XORRandom(aimvector.Length()), 0));
	sprite.ScaleBy(Vec2f(aimvector.Length() / 20.0f, 1.0f));
	sprite.RotateBy(-aimvector.getAngleDegrees() - this.getAngleDegrees(), Vec2f_zero);
}
