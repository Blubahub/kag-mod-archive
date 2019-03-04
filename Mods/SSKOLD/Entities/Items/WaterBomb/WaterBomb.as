// Bomb logic

#include "Hitters.as";
#include "WaterBombCommon.as";
#include "ShieldCommon.as";

void onInit(CBlob@ this)
{
	this.set_u16("explosive_parent", 0);
	this.getShape().getConsts().net_threshold_multiplier = 2.0f;
	SetupBomb(this, BOMB_FUSE, 48.0f, 20.0f, 24.0f, 0.7f, true); 
	//

	//this.Tag("activated"); // make it lit already and throwable
}

//sprite update

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	if (blob.hasTag("activated"))
	{
		Vec2f vel = blob.getVelocity();
		
		s32 timer = blob.get_s32("fuse_timer");

		if (timer <= 0)
		{
			return;
		}

		if (timer > 30)
		{
			this.SetAnimation("ticking");
			this.animation.frame = this.animation.getFramesCount() * (1.0f - ((timer - 30) / 220.0f));
		}
		else
		{
			this.SetAnimation("shes_gonna_blow");
			this.animation.frame = this.animation.getFramesCount() * (1.0f - (timer / 30.0f));

			if (timer < 15 && timer > 0)
			{
				f32 invTimerScale = (1.0f - (timer / 15.0f));
				Vec2f scaleVec = Vec2f(1, 1) * (1.0f + 0.07f * invTimerScale * invTimerScale);
				this.ScaleBy(scaleVec);
			}
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (this is hitterBlob)
	{
		this.set_s32("fuse_timer", 0);
	}

	if (isExplosionHitter(customData))
	{
		return damage; //chain explosion
	}

	return 0.0f;
}

void onDie(CBlob@ this)
{
	this.getSprite().SetEmitSoundPaused(true);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	//special logic colliding with players
	if (blob.hasTag("player"))
	{
		if (!this.hasTag("activated"))
		{
			return (blob.getTeamNum() != this.getTeamNum() && blob.hasTag("shielded"));	
		}
	}

	string name = blob.getName();

	if (name == "fishy" || name == "food" || name == "steak" || name == "grain" || name == "heart")
	{
		return false;
	}

	return true;
}



void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (!solid)
	{
		return;
	}

	const f32 vellen = this.getOldVelocity().Length();
	const u8 hitter = this.get_u8("custom_hitter");
	if (vellen > 1.7f)
	{
		Sound::Play(!isExplosionHitter(hitter) ? "/WaterBubble" :
		            "/BombBounce.ogg", this.getPosition(), Maths::Min(vellen / 8.0f, 1.1f));
	}

	if (!isExplosionHitter(hitter) && !this.isAttached() && this.hasTag("activated"))
	{
		Boom(this);
		if (!this.hasTag("_hit_water") && blob !is null) //smack that mofo
		{
			this.Tag("_hit_water");
			Vec2f pos = this.getPosition();
			blob.Tag("force_knock");
		}
	}
}

