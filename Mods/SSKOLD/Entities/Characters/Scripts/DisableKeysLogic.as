#include "SSKStatusCommon.as"

// Disable keys logic

void onTick(CBlob@ this) 
{
	if (this.hasTag("invincible"))
	{
		this.DisableKeys(0);
		this.DisableMouse(false);
		return;
	}

	SSKStatusVars@ statusVars;
	if (!this.get("statusVars", @statusVars))
	{
		return;
	}

	bool isHitstunned = statusVars.isHitstunned;
	u16 tumbleTime = statusVars.tumbleTime;
	u16 dazeTime = statusVars.dazeTime;
	bool inMoveAnimation = statusVars.inMoveAnimation;

	if (isHitstunned || tumbleTime > 0 || dazeTime > 0)
	{
		u16 takekeys = key_left | key_right | key_up | key_down | key_action1 | key_action2 | key_action3;

		this.DisableKeys(takekeys);
		this.DisableMouse(true);
	}
	else
	{
		this.DisableKeys(0);
		this.DisableMouse(false);
	}
}
