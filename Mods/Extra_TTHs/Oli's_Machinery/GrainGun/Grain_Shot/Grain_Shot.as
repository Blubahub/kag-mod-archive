#include "/Entities/Common/Attacks/Hitters.as";
#include "ShieldCommon.as";
#include "/Entities/Common/Attacks/LimitedAttacks.as";
const f32 dmg = 1.0f;
void onInit(CBlob@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().tickFrequency = 3;
	this.set_u32("pickup timer", getGameTime() + 2);
	this.server_SetTimeToDie(30);
}
void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if(blob !is null)
	{
		if (getNet().isServer() && (Maths::Abs(this.getVelocity().x) > 1.0f || Maths::Abs(this.getVelocity().y) > 1.0f))
		{
			Vec2f initVelocity = this.getOldVelocity();
			f32 vellen = initVelocity.Length();
			const bool hitShield = (blob.hasTag("shielded") && blockAttack(blob, initVelocity, 0.0f));
			if (this.getTeamNum() == blob.getTeamNum() || !blob.hasTag("flesh")) return;
			if (!hitShield)
			{
				this.server_Hit(blob, point1, this.getVelocity(), dmg, Hitters::boulder, false);
				this.server_Die();
			}
			else
			{
				this.getSprite().PlaySound("SwordCling");
				this.server_Die();
			}
		}
	}
}
bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return false;
}
void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if(attached.getPlayer() !is null)
	{
		this.SetDamageOwnerPlayer(attached.getPlayer());
	}
}
bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return(this.getTeamNum() != blob.getTeamNum());
}