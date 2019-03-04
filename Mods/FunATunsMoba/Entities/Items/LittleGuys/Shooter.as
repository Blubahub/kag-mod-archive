// Keg logic
#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.Tag("medium weight");
	this.set_u32("shoottimer", 60);
}
void onTick(CBlob@ this)
{
	if(this.isAttached())
	{
		CAttachment@ a = this.getAttachments();
		CBlob@ b = a.getAttachedBlob("PICKUP");
		if(this.get_u32("shoottimer") <= 0 && b !is null)
		{
			this.set_u32("shoottimer", 60);
			ShootArrow(this, this.getPosition() + Vec2f(0.0f, -2.0f), b.getAimPos() + Vec2f(0.0f, -2.0f), 17.59f, 0, false); 
		}
		else
		{
			this.set_u32("shoottimer", this.get_u32("shoottimer") - 1);
		}
	}
}
void ShootArrow(CBlob @this, Vec2f arrowPos, Vec2f aimpos, f32 arrowspeed, const u8 arrow_type, const bool legolas = true)
{
		Vec2f arrowVel = (aimpos - arrowPos);
		arrowVel.Normalize();
		arrowVel *= arrowspeed;
		CreateArrow(this, arrowPos, arrowVel, arrow_type);
}

CBlob@ CreateArrow(CBlob@ this, Vec2f arrowPos, Vec2f arrowVel, u8 arrowType)
{
	CBlob@ arrow = server_CreateBlobNoInit("arrow");
	if (arrow !is null)
	{
		// fire arrow?
		arrow.set_u8("arrow type", arrowType);
		arrow.Init();

		arrow.IgnoreCollisionWhileOverlapped(this);
		arrow.SetDamageOwnerPlayer(this.getPlayer());
		arrow.server_setTeamNum(this.getTeamNum());
		arrow.setPosition(arrowPos);
		arrow.setVelocity(arrowVel);
	}
	return arrow;
}
