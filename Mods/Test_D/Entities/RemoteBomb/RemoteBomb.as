#include "GameColours.as"
#include "Sparks.as"
#include "ExplosionParticles.as"
#include "Explosion.as"
#include "MapCommon.as"

const f32 BLAST_RADIUS = 48.0f;
const f32 DAMAGE = 3.0f;
const s32 ACTIVATE_DELAY = 30;
int _frame = 0;

void onInit(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	sprite.SetZ(100.0f);
	this.Tag("explosive");
	this.SetMapEdgeFlags(u8(CBlob::map_collide_none | CBlob::map_collide_nodeath));
	this.addCommandID("detonate");
	{
		Animation@ anim = sprite.addAnimation("blink", 5, true);
		int[] frames = {176, 177};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = sprite.addAnimation("disguise", 0, true);
		int[] frames = {TWMap::tile_crate_1 + (_frame++) % 4};
		anim.AddFrames(frames);
	}
	sprite.SetAnimation("blink");

	this.getShape().SetRotationsAllowed(false);
	this.Tag("crush");
	this.Tag("collide with nades");
}

void onTick(CBlob@ this)
{
	CMap@ map = getMap();
	Vec2f pos = this.getPosition();
	Vec2f vel = this.getVelocity();

	if(this.getTickSinceCreated() == ACTIVATE_DELAY)
	{
		CSprite@ sprite = this.getSprite();
		sprite.SetAnimation("disguise");
		this.getSprite().PlaySound("DetonateBomb");
		this.Tag("activated");
	}

	if (vel.getLengthSquared() > 0.5f)
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

void onDie(CBlob@ this)
{
	if (this.hasTag("explosive"))
	{
		Vec2f pos = this.getPosition();
		Explode(this, BLAST_RADIUS, DAMAGE);
		if (getNet().isClient())
		{
			Particles::Sparks(pos, 19, 29.0f, SColor(Colours::RED));
			Particles::Sparks(pos, 14, 29.0f, SColor(Colours::YELLOW));
			Particles::Explosion(pos, 6, Vec2f());

			if (!Sound::isTooFar(pos))
			{
				ShakeScreen(110.0f, 50.0f, pos);
				this.getSprite().PlaySound("Dynamite");
			}
			else
			{
				Sound::Play2D("DistantDynamite", 0.5f, pos.x > getCamera().getPosition().x ? 1.0f : -1.0f);
			}
		}
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (!getNet().isServer())
		return;

	if (solid && blob is null)
	{
		Vec2f pos = this.getPosition();

		pos.x = int(pos.x / 8) * 8.0f + 4.0f;
		pos.y = int(pos.y / 8) * 8.0f + 4.0f;

		CMap@ map = getMap();
		bool me = map.isTileSolid(map.getTile(pos));
		bool up = map.isTileSolid(map.getTile(pos + Vec2f(0, -8)));
		bool down = map.isTileSolid(map.getTile(pos + Vec2f(0, 8)));
		bool left = map.isTileSolid(map.getTile(pos + Vec2f(-8, 0)));
		bool right = map.isTileSolid(map.getTile(pos + Vec2f(8, 0)));

		if (me)
		{
			Vec2f oldvel = this.getOldVelocity();

			if (!left && oldvel.x > 0)
			{
				this.setPosition(this.getPosition() + Vec2f(-8, 0));
			}
			else if (!right && oldvel.x < 0)
			{
				this.setPosition(this.getPosition() + Vec2f(8, 0));
			}

			return;
		}

		if (up || down || left || right)
		{
			this.setPosition(pos);
			this.getShape().SetStatic(true);
		}
	}
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	if (isStatic)
	{
		Sound::Play("CrateHit", this.getPosition());
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	// defuse
	if (hitterBlob.hasTag("player")){
		hitterBlob.getSprite().PlaySound("RemoteBombDisarm");
		this.Untag("explosive");
		this.server_Die();
	}

	// blow up

	if (damage > 1.5f){
		this.server_Die();
	}
	Particles::Sparks(worldPoint, 3, 10.0f, SColor(Colours::YELLOW));
	Particles::Sparks(worldPoint, 5, 6.0f, SColor(Colours::RED));
	return damage;
}
