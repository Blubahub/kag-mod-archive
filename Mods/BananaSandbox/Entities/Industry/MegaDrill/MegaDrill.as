// Drill.as

#include "Hitters.as";
#include "BuilderHittable.as";

const f32 speed_thresh = 2.4f;
const f32 speed_hard_thresh = 2.6f;

const string buzz_prop = "megadrill timer";
const string required_class = "builder";

void onInit(CSprite@ this)
{
	this.SetEmitSound("/MegaDrill.ogg");
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
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1 | key_action2 | key_action3);
	}

	this.set_u32("hittime", 0);
	this.Tag("place45");
	this.set_s8("place45 distance", 1);
	this.Tag("place45 perp");
	
	this.SetLightColor(SColor(255, 0, 255, 255));
}

void onTick(CBlob@ this)
{
	const u32 gametime = getGameTime();
	bool inwater = this.isInWater();

	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSoundPaused(true);
	this.SetLight(false);
	if (this.isAttached())
	{
		this.getCurrentScript().runFlags &= ~(Script::tick_not_sleeping);
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		CBlob@ holder = point.getOccupied();

		if (holder is null) return;

		this.getShape().SetRotationsAllowed(false);

		if (holder.getName() == required_class || sv_gamemode == "TDM")
		{
			if (!point.isKeyPressed(key_action1) || holder.get_u8("knocked") > 0)
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
			this.SetLight(true);
			this.set_bool(buzz_prop, true);

			const u8 delay_amount = 4;
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
				const f32 attack_dam = 1.0f;

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
							else // map
							{
								if (map.getSectorAtPosition(hi.hitpos, "no build") !is null)
									continue;

								TileType tile = hi.tile;
								this.server_HitMap(hi.hitpos, attackVel, 4.0f, Hitters::drill);
								//only counts as hitting something if its not mats, so you can drill out veins quickly
								if (!map.isTileStone(tile) || !map.isTileGold(tile))
								{
									hitsomething = true;
									if (map.isTileCastle(tile) || map.isTileWood(tile))
									{
										hit_constructed = true;
									}
									else
									{
										hit_ground = true;
									}
								}

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
				if (point.isKeyJustPressed(key_action1))
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
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	return damage;
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
