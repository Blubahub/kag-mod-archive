#include "Hitters.as";
#include "BuilderHittable.as";

const string laser_prop = "what is this for? idk :|";

void onInit(CSprite@ this)
{
	CSpriteLayer@ laser = this.addSpriteLayer("laser", this.getFilename(), 29, 3);

	if (laser !is null)
	{
		Animation@ anim = laser.addAnimation("default", 0, true);
		{
			int[] frames = {1};
			anim.AddFrames(frames);
		}
		laser.SetAnimation(anim);
		laser.SetRelativeZ(-2.0f);
		laser.SetVisible(false);
		laser.SetOffset(Vec2f(-11.5f, 0.0f));
		laser.setRenderStyle(RenderStyle::light);
	}
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	bool laser = blob.get_bool(laser_prop);
	if (laser)
	{
		CSpriteLayer@ laserlayer = this.getSpriteLayer("laser");
		if (laserlayer !is null)
		{
			laserlayer.setRenderStyle(RenderStyle::light);
			laserlayer.SetVisible(true);
		}
	}
	else
	{
		CSpriteLayer@ laserlayer = this.getSpriteLayer("laser");
		laserlayer.SetVisible(false);
	}
}

void onTick(CBlob@ this)
{
	const u32 gametime = getGameTime();
	bool inwater = this.isInWater();

	CSprite@ sprite = this.getSprite();

	if (this.isAttached())
	{
		this.getCurrentScript().runFlags &= ~(Script::tick_not_sleeping);
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		CBlob@ holder = point.getOccupied();
		
		this.getShape().SetRotationsAllowed(true);
		
		if (holder is null) return;

		f32 distance2 = 5.0f;
		f32 angleOffset = 20.0f * (holder.isFacingLeft() ? 1.0f : -1.0f);
		Vec2f aimpos = holder.getAimPos();
		Vec2f pos = holder.getPosition();
		Vec2f aim_vec = (pos - aimpos);
		aim_vec.Normalize();
		f32 mouseAngle = aim_vec.getAngleDegrees();
		if (!holder.isFacingLeft()) mouseAngle += 180;

		this.setAngleDegrees(-mouseAngle + angleOffset);
		AttachmentPoint@ hands = holder.getAttachments().getAttachmentPointByName("PICKUP");
		
		aim_vec *= distance2;

		if (hands !is null)
		{
			hands.offset.x = 0; // if blob config has offset other than 0,0 there is a desync on client, dont know why
			hands.offset.y = 0;
		}

		bool laser = this.get_bool(laser_prop);

		if (holder.isKeyJustPressed(key_action1))
		{
			if (!laser)
			{
				this.set_bool(laser_prop, true);
			}
			else
			{
				this.set_bool(laser_prop, false);
			}
		}
		this.Sync(laser_prop, true);
		
		if (laser)
		{
			const bool facingleft = this.isFacingLeft();
			Vec2f direction = Vec2f(1, 0).RotateBy(this.getAngleDegrees() + (facingleft ? 180.0f : 0.0f));
			const f32 attack_distance = 1.0f;
			Vec2f attackVel = direction * attack_distance;

			const f32 distance = 29.0f;
			const f32 attack_dam = 0.1f;

			bool hitsomething = false;
			bool hitblob = false;

			CMap@ map = getMap();
			if (map !is null)
			{
				HitInfo@[] hitInfos;
				if (map.getHitInfosFromArc((this.getPosition() - attackVel), -attackVel.Angle(), 3, distance, this, false, @hitInfos))
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

							if (hi.blob.getTeamNum() == holder.getTeamNum() || hit_ground && !is_ground)
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
		this.getShape().SetRotationsAllowed(true);
		if (inwater)
			this.set_bool(laser_prop, false);
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
