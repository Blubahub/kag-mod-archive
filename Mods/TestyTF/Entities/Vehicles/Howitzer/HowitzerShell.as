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

	this.set_u32("wait_time", getGameTime() + 5); // Awful fix, I'm quite ashamed.
	
	this.Tag("projectile");
	this.getSprite().SetFrame(0);
	this.getSprite().getConsts().accurateLighting = false;
	this.getSprite().SetFacingLeft(!this.getSprite().isFacingLeft());

	this.SetMapEdgeFlags(CBlob::map_collide_left | CBlob::map_collide_right);
	
	this.SetMinimapOutsideBehaviour(CBlob::minimap_arrow);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 1, Vec2f(16, 16));
	this.SetMinimapRenderAlways(true);
	
	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("Shell_Whistle.ogg");
	sprite.SetEmitSoundPaused(false);
	sprite.SetEmitSoundVolume(0.0f);
	sprite.SetEmitSoundSpeed(0.9f);
}

void onTick(CBlob@ this)
{
	f32 angle = 0;

	Vec2f velocity = this.getVelocity();
	angle = velocity.Angle();
	Pierce(this, velocity, angle);

	this.setAngleDegrees(-angle + 180.0f);
	
	f32 modifier = Maths::Max(0, this.getVelocity().y * 0.02f);
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

	this.SetMinimapRenderAlways(false);
		
	Explode(this, 64.0f, 4.0f);
	for (int i = 0; i < 4; i++)
	{
		// Vec2f dir = Vec2f(1 - i / 4.0f, -1 + i / 4.0f);
		// Vec2f dir = velocity + velocity * (100 - XORRandom(200) / 100.0f);
		Vec2f jitter = Vec2f((XORRandom(200) - 100) / 200.0f, (XORRandom(200) - 100) / 200.0f);
		// print("x: " + dir.x + "; y: " + dir.y);
		LinearExplosion(this, Vec2f(velocity.x * jitter.x, velocity.y * jitter.y), 32.0f + XORRandom(32), 24.0f, 4, 10.0f, Hitters::explosion);
	}

	this.Tag("dead");
	this.server_Die();
	this.getSprite().Gib();
}