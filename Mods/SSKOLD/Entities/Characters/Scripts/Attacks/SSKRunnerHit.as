// Knockback on hit - put before any damaging things but after any scalers
#include "SSKStatusCommon.as"
#include "SSKRunnerCommon.as"
#include "ShieldCommon.as";
#include "Hitters.as"

void onInit(CBlob@ this)
{
	this.getCurrentScript().removeIfTag = "dead";
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (this.hasTag("invincible")) //pass through if invince
		return 0;

	if (customData == Hitters::fall)
		return damage;

	SSKStatusVars@ statusVars;
	if (!this.get("statusVars", @statusVars))
	{
		return damage;
	}

	// reduce grabbed time if taking damage
	u16 grabbedTime = statusVars.grabbedTime;
	if (this.isAttached())
	{
		if (grabbedTime > 0)
		{
			statusVars.grabbedTime += damage*3.0f;
		}
	}

	// handle the hard-coded case of collapsed tiles hitting runner
	if (customData == Hitters::crush)
	{
		if (getNet().isServer())
		{
			f32 crushDamage = damage*4.0f;
			statusVars.damageStatus += crushDamage;
			SyncDamageStatus(this);

			u8 hitstunTime = 8;
			Vec2f tumbleVec = Vec2f(0,1)*crushDamage;
			u16 tumbleTime = Maths::Max(crushDamage*8.0f, statusVars.tumbleTime);

			CBitStream params;
			params.write_u8( hitstunTime );
			params.write_u16( tumbleTime );	
			params.write_Vec2f( tumbleVec );	
			this.SendCommand(this.getCommandID("sync knockback"), params);
		}
	}

	statusVars.inMoveAnimation = false;
	statusVars.fallSpecial = false;

	if (statusVars.tumbleTime > 0)
	{
		this.getSprite().PlaySound("/Stun", 1.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);
	}

	return damage; //damage not affected
}