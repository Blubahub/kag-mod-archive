#include "MagicalHitters.as";
//Bounces back to player.
void onInit(CBlob@ this)
{
	this.getShape().setDrag(0.0f);
}
void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1 )
{
	if(blob is null)
	{
		if(!getMap().isTileSolid(this.getPosition() - this.getOldVelocity()))
		{
			this.setVelocity(this.getOldVelocity() * -1.0f);
		}
	}
}