#include "RuneAffectPlayer.as";

void onInit(CBlob@ this)
{
	this.Tag("curserune");
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point)
{
	if (this.isAttached())
	{
		return;
	}

	//shouldn't be in here! collided with map??
	if (blob is null)
	{
		return;
	}

	// only hit living things
	if (!blob.hasTag("flesh") || blob.hasTag("negrunetatoo"))
	{
		return;
	}

	givePlayerEffectBad(this, blob);
	
	return;
}