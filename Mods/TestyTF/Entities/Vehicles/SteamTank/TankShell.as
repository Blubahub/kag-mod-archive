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

	this.Tag("map_damage_dirt");
	
	this.set_f32("map_damage_radius", 64.0f);
	this.set_f32("map_damage_ratio", 0.2f);
	
	this.Tag("projectile");
	this.getSprite().SetFrame(0);
	this.getSprite().getConsts().accurateLighting = false;
	this.getSprite().SetFacingLeft(!this.getSprite().isFacingLeft());

	this.SetMapEdgeFlags(CBlob::map_collide_left | CBlob::map_collide_right);
	
	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("Shell_Whistle.ogg");
	sprite.SetEmitSoundPaused(false);
	sprite.SetEmitSoundVolume(0.0f);
}

void onTick(CBlob@ this)
{
	f32 angle = 0;

	Vec2f velocity = this.getVelocity();
	angle = velocity.Angle();
	Pierce(this, velocity, angle);

	this.setAngleDegrees(-angle + 90.0f);
	
		
	f32 modifier = Maths::Max(0, this.getVelocity().y * 0.02f);
	// this.getSprite().SetEmitSoundPaused(this.getVelocity().y < 0);
	this.getSprite().SetEmitSoundVolume(Maths::Max(0, modifier));
}

void Pierce(CBlob@ this, Vec2f velocity, const f32 angle)
{
	CMap@ map = this.getMap();

	const f32 speed = velocity.getLength();

	Vec2f direction = velocity;
	direction.Normalize();
	
	Vec2f position = this.getPosition();
	Vec2f tip_position = position + direction * 4.0f;
	Vec2f tail_position = position + direction * -4.0f;

	Vec2f[] positions =
	{
		position,
		tip_position,
		tail_position
	};

	for (uint i = 0; i < positions.length; i ++)
	{
		Vec2f temp_position = positions[i];
		TileType type = map.getTile(temp_position).type;

		if (map.isTileSolid(type))
		{
			const u32 offset = map.getTileOffset(temp_position);
			onCollision(this, null, true);
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
				onCollision(this, blob, false);
			}
		}
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null && !solid && doesCollideWithBlob(this, blob)) DoExplosion(this, this.getOldVelocity());
	else if (solid) DoExplosion(this, this.getOldVelocity());
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	// print("This: " + this.getTeamNum() + "; Other: " + blob.getTeamNum() + " called " + blob.getName());	

	if (blob !is null)
	{
		return (this.getTeamNum() != blob.getTeamNum() && blob.isCollidable());
	}
	else return false;
}

void DoExplosion(CBlob@ this, Vec2f velocity)
{
	if (this.hasTag("dead")) return;
	this.Tag("dead");

	Explode(this, 64.0f, 4.0f);
	LinearExplosion(this, velocity, 16.0f, 16.0f, 2, 1.5f, Hitters::bomb);

	this.server_Die();
	this.getSprite().Gib();
}