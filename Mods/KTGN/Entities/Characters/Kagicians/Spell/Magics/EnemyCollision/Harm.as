#include "MagicalHitters.as";
#include "hitShield.as";
#include "MagicCommon.as";
void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
	if(blob !is null)
	{
		if(this.getTeamNum() != blob.getTeamNum() && (blob.hasTag("flesh") || blob.hasTag("player")))
		{
			const bool Shielded = didShield(this, blob);
			if(getNet().isServer())
			{
				if(!Shielded)
				{
					MagicHitBlob(this, blob, this.getPosition(), this.getVelocity(), 0.45f * (this.get_u16("charge") / 40.0f), MagicalHitters::Magic);
				}
				this.server_Die();
			}
			if(getNet().isClient())
			{
				f32 noise = this.get_u16("charge") / 40.0f;
				this.getSprite().PlaySound("ExtinguishFire.ogg", (noise), (Shielded ? 4.0f : 1 / noise));//Do some stuff
			}
		}
	}
}