// Runner Movement

#include "SSKStatusCommon.as"
#include "SSKMovesetCommon.as"

bool damageSynced = false;

void onInit(CBlob@ this)
{
	SSKStatusVars statusVars;

	statusVars.damageStatus = 0.0f;

	statusVars.inMoveAnimation = false;
	statusVars.hitThisFrame = false;

	statusVars.hitstunTime = 0;
	statusVars.isHitstunned = false;

	statusVars.grabbedTime = 0;

	statusVars.dazeTime = 0;

	statusVars.knockbackForce = Vec2f_zero;

	statusVars.tumbleTime = 0;
	statusVars.isTumbling = false;
	statusVars.tumbleVec = Vec2f_zero;

	statusVars.fallSpecial = false;

	statusVars.fastFalling = false;

	this.set("statusVars", statusVars);

	this.addCommandID("sync damage");
	this.addCommandID("sync grab event");
	this.addCommandID("sync daze time");
	this.addCommandID("sync tumbling");
	this.addCommandID("sync hitstun");
	this.addCommandID("sync knockback");
	this.addCommandID("sync bounce");

	this.set_bool("damageSynced", false);
}

void onTick(CBlob@ this)
{
	bool damageSynced = this.get_bool("damageSynced");
	if (!damageSynced && getNet().isServer() && this.getTickSinceCreated() > 10)
	{
		SyncDamageStatus(this);
		this.set_bool("damageSynced", true);
		this.Sync("damageSynced", true);
	}
	
	DoHitstunnedUpdate(this);
	DoGrabUpdate(this);
	DoDazedUpdate(this);
	DoTumblingUpdate(this);
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("sync damage"))
	{
		HandleDamageStatus(this, params, true);
	}
	else if (cmd == this.getCommandID("sync grab event"))
	{
		SSKStatusVars@ statusVars;
		if (!this.get("statusVars", @statusVars)) { return; }

		u16 grabbedTime = params.read_u16();
		statusVars.grabbedTime = grabbedTime;

		statusVars.inMoveAnimation = false;
	}
	else if (cmd == this.getCommandID("sync daze time"))
	{
		SSKStatusVars@ statusVars;
		if (!this.get("statusVars", @statusVars)) { return; }

		u16 dazeTime = params.read_u16();
		statusVars.dazeTime = dazeTime;
	}
	else if (cmd == this.getCommandID("sync tumbling"))
	{
		HandleTumbling(this, params, true);
	}
	else if (cmd == this.getCommandID("sync hitstun"))
	{
		HandleHitstun(this, params, true);
	}
	else if (cmd == this.getCommandID("sync knockback"))
	{
		HandleKnockback(this, params, true);
	}
	else if (cmd == this.getCommandID("sync bounce"))
	{
		HandleBounce(this, params, true);
	}
}

bool canSend(CBlob@ this)
{
	//return (this.isMyPlayer() || this.getPlayer() is null || this.getPlayer().isBot());

	return getNet().isServer();
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
	// play sound for letting players and items go
	if (detached.hasTag("player"))
	{
		this.getSprite().PlaySound("throw2.ogg", 3.0f);	
	}
	else if (detached.getHealth() > 0)
	{
		this.getSprite().PlaySound("throw1.ogg", 2.0f);
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	SSKStatusVars@ statusVars;
	if (!this.get("statusVars", @statusVars)) { return; }
	statusVars.inMoveAnimation = false;

	if(attached.hasTag("player"))
	{
		this.getSprite().PlaySound("grab3.ogg", 1.0f);
	}
	else
	{
		this.getSprite().PlaySound("grab2.ogg", 2.0f);
	}
}
