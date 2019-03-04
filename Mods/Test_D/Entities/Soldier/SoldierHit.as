#include "SoldierCommon.as"
#include "Sparks.as"
#include "GameColours.as"
#include "Blood.as"
#include "Scores.as"
#include "HoverMessage.as"

namespace Soldier
{
	// DAMAGE / DEATH

	int _argCycler = 0;

	f32 DefaultHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
	{
		Data@ data = getData(this);
		if (data !is null && damage > 0.0f)
		{
			f32 oldHealth = this.getHealth();
			if (customData == 0)
			{
				Particles::Blood(worldPoint, 10 * damage, velocity.Length() * 3.5f);
				this.getSprite().PlayRandomSound("ManHit", 2.0f, data.pitch);
			}

			// dead effect
			if (data.dead)
			{
				// _argCycler++;
				// if (_argCycler % 4 == 0){
				// 	data.sprite.PlayRandomSound("ManArg");
				// }
				data.vel.y = -Maths::Abs(data.vel.y);
				data.vel.y -= 2.0f * damage;
				this.setVelocity(data.vel);
				data.stunTime = 90;
			}

			this.Damage(damage, hitterBlob);

			data.vel += velocity;
			data.vel.y = -Maths::Abs(data.vel.y);
			this.setVelocity(data.vel);

			if (oldHealth > 0.0f && this.getHealth() <= 0.0f)
			{
				this.SetPlayerOfRecentDamage(hitterBlob.getPlayer());

				Die(this, getData(this));
				AddKill(this, hitterBlob);

				data.vel.y -= 3.0f;
				this.setVelocity(data.vel);
				data.stunTime = 90;
			}

			// reset heal timer if present
			data.healTime = 0;
		}
		return 0.0f; //done, we've used all the damage
	}

	void Die(CBlob@ this, Data@ data)
	{
		this.Tag("dead");
		this.Untag("collide with nades");

		if (getCamera() !is null)
		{
			Sound::isTooFar(data.pos) ? Sound::Play2D("DistantDeathScream", 1.0f, data.pos.x > getCamera().getPosition().x ? 1.0f : -1.0f)
			: data.sprite.PlaySound("DeathScream", 1.0f, data.pitch);

			if (data.isMyPlayer && sv_max_localplayers == 1)
			{
				this.set_u32("death time", getGameTime());
				SetScreenFlash(Colours::RED, 0.33f);
			}
		}

		data.dead = true;
		data.stunTime = 60;
		data.deadTime = getGameTime();
		data.crosshair = false;
		data.camoMode = 0;

		data.shape.RemoveShape(1);

		CParticle@ p = ParticleAnimated("death_gasp.png",
		                                data.pos + Vec2f(0.0f, -12.0f),
		                                Vec2f(data.vel.x * 0.1f, -0.5f),
		                                0.0f,
		                                1.0f,
		                                3, //animtime
		                                -0.3f,
		                                true);

		if (p !is null)
		{
			p.damping = 0.85f;

			p.collides = false;
			p.Z = 1100.0f;
			p.slide = 1.0f;
			p.bounce = 1.0f;
			p.growth = 0.025f;

			p.width = p.height = 2.0f;
		}

		CBitStream params;
		this.SendCommand(Soldier::Commands::DIE, params);

		if (getRules().isMatchRunning() && getNet().isServer())
		{
			getRules().set_Vec2f("last kill pos", data.pos);
			getRules().Sync("last kill pos", true);
		}

		string name = this.getPlayer() !is null ? this.getPlayer().getCharacterName() : "CPU";
		if (sv_max_localplayers == 1)
		{
			AddMessage(this, "x_x " + name, 0, 75, Vec2f(0.0f, -this.getScreenPos().y * 0.1f));
			//client_AddToChat("x_x " + name, getTeamColor(this.getTeamNum()));
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	return Soldier::DefaultHit(this, worldPoint, velocity, damage, hitterBlob, customData);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (getNet().isClient() && cmd == Soldier::Commands::DIE)
	{
		if (!this.hasTag("dead")){
			Soldier::Die(this, Soldier::getData(this));
		}
	}
}