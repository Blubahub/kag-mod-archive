//Lob the player upwards.
#include "MagicalHitters.as";
void onHitBlob( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData )
{
	if(customData == MagicalHitters::Magic)
	{
		hitBlob.setVelocity(hitBlob.getVelocity() + this.getVelocity());
	}
}