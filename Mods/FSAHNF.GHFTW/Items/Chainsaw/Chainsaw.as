// Drill.as

#include "Hitters.as";
#include "BuilderHittable.as";

const f32 speed_thresh = 2.4f;
const f32 speed_hard_thresh = 2.6f;

const string buzz_prop = "drill timer";

const string required_class = "builder";

void onInit(CSprite@ this)
{
	this.SetEmitSound("/Drill.ogg");
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	bool buzz = blob.get_bool(buzz_prop);
	if (buzz)
	{
		this.SetAnimation("buzz");
	}
	else if (this.isAnimationEnded())
	{
		this.SetAnimation("default");
	}
}

void onInit(CBlob@ this)
{
	this.set_u32("hittime", 0);
	this.Tag("place45");
	this.set_s8("place45 distance", 1);
	this.Tag("place45 perp");
}

void onTick(CBlob@ this)
{
	const u32 gametime = getGameTime();

	CSprite@ sprite = this.getSprite();

	bool inwater = this.isInWater();
	
	sprite.SetEmitSoundPaused(true);
	if (this.isAttached())
	{
		this.getCurrentScript().runFlags &= ~(Script::tick_not_sleeping);
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		CBlob@ holder = point.getOccupied();

		if (holder is null) return;

		this.getShape().SetRotationsAllowed(false);

		if (holder.getName() == required_class || sv_gamemode == "TDM")
		{
			if (!holder.isKeyPressed(key_action1) || holder.get_u8("knocked") > 0)
			{
				this.set_bool(buzz_prop, false);
				return;
			}

			//set funny sound under water
			if (inwater)
			{
				sprite.SetEmitSoundSpeed(0.8f + (getGameTime() % 13) * 0.01f);
			}
			else
			{
				sprite.SetEmitSoundSpeed(1.0f);
			}

			sprite.SetEmitSoundPaused(false);
			this.set_bool(buzz_prop, true);

			const u8 delay_amount = inwater ? 20 : 8;
			bool skip = ((gametime + this.getNetworkID()) % delay_amount) != 0;

			if (skip) return;

			// delay drill
			{
				const bool facingleft = this.isFacingLeft();
				Vec2f direction = Vec2f(1, 0).RotateBy(this.getAngleDegrees() + (facingleft ? 180.0f : 0.0f));
				const f32 sign = (facingleft ? -1.0f : 1.0f);

				const f32 attack_distance = 6.0f;
				Vec2f attackVel = direction * attack_distance;

				const f32 distance = 20.0f;
				const f32 attack_dam = 2.0f;

				bool hitsomething = false;
				bool hitblob = false;

				CMap@ map = getMap();
				if (map !is null)
				{
					HitInfo@[] hitInfos;
					if (map.getHitInfosFromArc((this.getPosition() - attackVel), -attackVel.Angle(), 30, distance, this, false, @hitInfos))
					{
						bool hit_ground = false;
						for (uint i = 0; i < hitInfos.length; i++)
						{
							HitInfo@ hi = hitInfos[i];
							bool hit_constructed = false;
							if (hi.blob !is null) // blob
							{
								//detect
								const bool is_ground = hi.blob.hasTag("blocks sword") && !hi.blob.isAttached() && hi.blob.isCollidable();
								if (is_ground)
								{
									hit_ground = true;
								}

								if (hi.blob.getTeamNum() == holder.getTeamNum() ||
								        hit_ground && !is_ground)
								{
									continue;
								}

								holder.server_Hit(hi.blob, hi.hitpos, attackVel, attack_dam, Hitters::drill);
								hitsomething = true;
								hitblob = true;
							}
							if (hitsomething)
							{
								hitsomething = false;
								hitblob = false;
							}
						}
					}
				}
			}
		}
		else
		{
			if (getNet().isClient() &&
			        holder.isMyPlayer())
			{
				if (holder.isKeyJustPressed(key_action1))
				{
					Sound::Play("Entities/Characters/Sounds/NoAmmo.ogg");
				}
			}
		}
	}
	else
	{
		this.getShape().SetRotationsAllowed(true);
		this.set_bool(buzz_prop, false);
		this.getCurrentScript().runFlags |= Script::tick_not_sleeping;
	}
}

void onHitMap(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, u8 customData)
{
	getMap().server_DestroyTile(worldPoint, damage, this);
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	this.getCurrentScript().runFlags &= ~Script::tick_not_sleeping;
}

void onThisAddToInventory(CBlob@ this, CBlob@ blob)
{
	this.getSprite().SetEmitSoundPaused(true);
}
