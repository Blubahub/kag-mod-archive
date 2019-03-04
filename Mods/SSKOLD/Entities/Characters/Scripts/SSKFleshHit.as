#include "SSKStatusCommon.as"

// Flesh hit

f32 getGibHealth(CBlob@ this)
{
	if (this.exists("gib health"))
	{
		return this.get_f32("gib health");
	}

	return 0.0f;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	SSKStatusVars@ statusVars;
	if (!this.get("statusVars", @statusVars))
	{
		return damage;
	}

	this.Damage(damage, hitterBlob);

	return 0.0f; //done, we've used all the damage
}
