//Stun
#include "Knocked.as";
#include "MagicalHitters.as";
#include "MagicCommon.as";
void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
	if(blob !is null)
	{
		if(this.getTeamNum() != blob.getTeamNum() && (blob.hasTag("flesh") || blob.hasTag("player")))
		{
			if(getNet().isServer())
			{
				MagicHitBlob(this, blob, this.getPosition(), this.getVelocity(), 0.2f * (this.get_u16("charge") / 40.0f), MagicalHitters::Magic);
				SetKnocked(blob, this.get_u16("charge") / 1.5f);
				this.server_Die();
			}
			else
			{
				//Do some stuff
			}
		}
	}
}