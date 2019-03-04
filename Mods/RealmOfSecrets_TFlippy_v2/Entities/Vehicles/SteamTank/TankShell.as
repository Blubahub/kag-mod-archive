#include "Hitters.as";
#include "ShieldCommon.as";
#include "Explosion.as";

const f32 BLOB_DAMAGE = 20.0f;
const f32 MAP_DAMAGE = 10.0f;

void onInit(CBlob@ this)
{
	this.server_SetTimeToDie(20);
	
	this.getShape().getConsts().mapCollisions = false;
	this.getShape().getConsts().bullet = true;
	this.getShape().getConsts().net_threshold_multiplier = 4.0f;

	this.Tag("projectile");
	this.getSprite().SetFrame(0);
	this.getSprite().getConsts().accurateLighting = false;
	this.getSprite().SetFacingLeft(!this.getSprite().isFacingLeft());

	this.SetMapEdgeFlags(CBlob::map_collide_left | CBlob::map_collide_right);
}

void onTick(CBlob@ this)
{
	f32 angle = 0;

	Vec2f velocity = this.getVelocity();
	angle = velocity.Angle();
	Pierce(this, velocity, angle);

	this.setAngleDegrees(-angle + 90.0f);
}

void Pierce(CBlob@ this, Vec2f velocity, const f32 angle)
{
	CMap@ map = this.getMap();

	const f32 speed = velocity.getLength();

	Vec2f direction = velocity;
	direction.Normalize();
	
	Vec2f position = this.getPosition();
	Vec2f tip_position = position + direction * 6.0f;
	Vec2f middle_position = position + direction * 3.0f;
	Vec2f tail_position = position + direction * -3.0f;

	Vec2f[] positions =
	{
		position,
		tip_position,
		middle_position,
		tail_position
	};

	for (uint i = 0; i < positions.length; i ++)
	{
		Vec2f temp_position = positions[i];
		TileType type = map.getTile(temp_position).type;

		if (map.isTileSolid(type))
		{
			const u32 offset = map.getTileOffset(temp_position);
			BallistaHitMap(this, offset, temp_position, velocity, MAP_DAMAGE, Hitters::ballista);
		}
	}
	
	HitInfo@[] infos;
	
	if (map.getHitInfosFromArc(tail_position, -angle, 10, (tip_position - tail_position).getLength(), this, false, @infos))
	{
		for (uint i = 0; i < infos.length; i ++)
		{
			CBlob@ blob = infos[i].blob;
			Vec2f hit_position = infos[i].hitpos;

			if (blob !is null)
			{
				if (!doesCollideWithBlob(this, blob)) return;

				this.server_Hit(blob, hit_position, velocity, BLOB_DAMAGE, Hitters::ballista, true);
				BallistaHitBlob(this, hit_position, velocity, BLOB_DAMAGE, blob, Hitters::ballista);
			}
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	// print("This: " + this.getTeamNum() + "; Other: " + blob.getTeamNum());	

	if (blob !is null)
	{
		return ((this.getTeamNum() != blob.getTeamNum()) && blob.isCollidable());
	}
	else return false;
}

bool DoExplosion(CBlob@ this, Vec2f velocity)
{
	if (this.hasTag("dead"))
		return true;

	Explode(this, 32.0f, 4.0f);
	LinearExplosion(this, velocity, 32.0f, 16.0f, 8, 8.0f, Hitters::bomb);

	this.Tag("dead");
	this.server_Die();
	this.getSprite().Gib();

	return true;
}

void BallistaHitBlob(CBlob@ this, Vec2f hit_position, Vec2f velocity, const f32 damage, CBlob@ blob, u8 customData)
{
	DoExplosion(this, velocity);
}

void BallistaHitMap(CBlob@ this, const u32 offset, Vec2f hit_position, Vec2f velocity, const f32 damage, u8 customData)
{
	DoExplosion(this, velocity);
}