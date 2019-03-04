#include "/Entities/Common/Attacks/Hitters.as";
#include "ShieldCommon.as";
#include "/Entities/Common/Attacks/LimitedAttacks.as";
const f32 dmg = 0.5f;
void onInit(CBlob@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().tickFrequency = 3;
	this.set_u32("pickup timer", getGameTime() + 2);
}
void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if(blob !is null)
	{
		if (getNet().isServer())
		{
			Vec2f initVelocity = this.getOldVelocity();
			f32 vellen = initVelocity.Length();
			const bool hitShield = (blob.hasTag("shielded") && blockAttack(blob, initVelocity, 0.0f));
			if (!hitShield)
			{
				CPlayer@ damageowner = this.getDamageOwnerPlayer();
				if (damageowner is null)
				{
					return;
				}
				CBlob@ blobowner = damageowner.getBlob();
				if (blobowner is null)
				{
					return;
				}
				this.server_Hit(blob, point1, this.getVelocity(), dmg, Hitters::boulder, false);
				if  (blobowner.getNetworkID()==blob.getNetworkID() || blob.getName() == "chakram" || !solid)
				{
					return;
				}
				this.Tag("return");
			}
			else
			{
				this.getSprite().PlaySound("SwordCling");
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
	this.Untag("return");
}
void onTick( CBlob @ this )
{
	if(this.hasTag("return"))
	{
		CPlayer@ damageowner = this.getDamageOwnerPlayer();
		if (damageowner is null)
		{
			return;
		}
		CBlob@ owner = damageowner.getBlob();
		if (owner is null)
		{
			this.Untag("return");
			return;
		}
		Vec2f direction = owner.getPosition() - this.getPosition();
		direction.Normalize();
		this.setVelocity(direction*5.5 + Vec2f(0, -4)); 
	}
}