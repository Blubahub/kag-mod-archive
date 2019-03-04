#include "MagicalHitters.as";
#include "MagicCommon.as";
void onInit(CBlob@ this)
{
	this.getSprite().SetAnimation("Pierce");
}
void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
	if(blob !is null)
	{
		if(this.getTeamNum() != blob.getTeamNum() && (blob.hasTag("flesh") || blob.hasTag("player")))
		{
			if(getNet().isServer())
			{
				MagicHitBlob(this, blob, this.getPosition(), this.getVelocity(), Maths::Min(0.5f * (this.get_u16("charge") / 40.0f), 1.5f), MagicalHitters::Magic);
			}
			else
			{
				//Do some stuff
			}
		}
	}
}