#include "GameColours.as"
#include "Sparks.as"
#include "ExplosionParticles.as"
#include "Explosion.as"

const f32 MAX_VEL = 9.0f;
const f32 RADIUS = 40.0f;
const f32 DAMAGE = 3.0f;

const int GRENADE_TIME = getTicksASecond() * 3.0f;
const int FLASHBANG_TIME = getTicksASecond() * 9.0f;

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(100.0f);
	this.Tag("explosive");
	this.SetMapEdgeFlags(u8(CBlob::map_collide_none | CBlob::map_collide_nodeath));
}

s32 getTicksToDie_EnsureSync(CBlob@ this)
{
	s32 ticks = this.getTicksToDie();
	if (ticks == -1)
	{
		ticks = FLASHBANG_TIME;
		if (this.exists("explode_time"))
		{
			s32 ticks = this.get_s32("explode_time");
			this.server_SetTimeToDie(ticks / f32(getTicksASecond()));
		}
	}
	else
	{
		//only sync once, they set their own timer after that
		if (!this.exists("explode_time"))
		{
			this.set_s32("explode_time", ticks);
			this.Sync("explode_time", true);
		}
	}
	return ticks;
}

void onTick(CBlob@ this)
{
	if (this.get_u8("grenade type") == 1) // flash nade
	{
		const f32 fullTime = FLASHBANG_TIME;
		if (getTicksToDie_EnsureSync(this) == 2.0f * fullTime / 3.0f)
		{
			this.getSprite().PlaySound("Flashbang");
			Particles::Fireworks(this.getPosition(), 3, Vec2f(0.0f, -0.0f), 0.0f, 0, 0);
		}
	}
}

void onDie(CBlob@ this)
{
	Vec2f pos = this.getPosition();

	if (this.get_u8("grenade type") == 0) // HE nade
	{
		Explode(this, RADIUS, DAMAGE);

		if (getNet().isClient())
		{
			Particles::Sparks(pos, 17, 27.0f, SColor(Colours::RED));
			Particles::Sparks(pos, 10, 27.0f, SColor(Colours::YELLOW));
			Particles::Explosion(pos, 4, this.getVelocity());

			if (!Sound::isTooFar(pos))
			{
				ShakeScreen2(20.0f, 15, pos);
				this.getSprite().PlaySound("GrenadeExplosion");
			}
			else
			{
				Sound::Play2D("DistantExplosion", 0.5f, pos.x > getCamera().getPosition().x ? 1.0f : -1.0f);
			}
		}
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (solid && blob is null && this.get_u8("grenade type") == 0)
	{
		const f32 vellen = this.getShape().vellen;
		const f32 fullTime = GRENADE_TIME;
		this.getSprite().PlayRandomSound("GrenadeDrop", vellen / MAX_VEL, 0.5f + 0.25f * (fullTime - getTicksToDie_EnsureSync(this)) / fullTime);
	}
}


bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.hasTag("collide with nades");
}


// CSprite

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob.get_u8("grenade type") == 0)
		return;

	const f32 fullTime = FLASHBANG_TIME;
	s32 timeleft = getTicksToDie_EnsureSync(blob);
	f32 time = (fullTime - timeleft) / fullTime;

	if (time >= 0.33f)
	{
		f32 timefract = timeleft / 120.0f;//if FLASHBANG_DURATION changes, you have to change this

		CCamera@ camera = getCamera();
		Vec2f p = getDriver().getScreenPosFromWorldPos(blob.getPosition());
		Vec2f spriteSize(256, 256);
		GUI::DrawIcon("Sprites/flashbang.png", 0, spriteSize, p - spriteSize * camera.targetDistance, camera.targetDistance, SColor(Maths::Min(255, timefract * 500), 255, 255, 255));

		// draw commando player on top
		CPlayer@ player = blob.getDamageOwnerPlayer();
		if (player !is null && player.isMyPlayer())
		{
			CBlob@ owner = player.getBlob();
			if (owner !is null && (owner.getPosition() - blob.getPosition()).getLength() < 256.0f)
			{
				// TODO: refactor this into common indicator code :/
				Vec2f player_pos = getDriver().getScreenPosFromWorldPos(owner.getPosition()
				                   + Vec2f(0, -23 + Maths::Sin(0.5f * getGameTime()) * 4.0f));
				GUI::DrawIcon("Sprites/HoverIcons.png", 5, Vec2f(16, 16),
				              player_pos - Vec2f(16, 16)*camera.targetDistance, camera.targetDistance,
				              getBlobColor(owner));
			}
		}
	}
}
