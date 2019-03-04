#include "Explosion.as";
const f32 dmg = 3.0f;
const f32 range = 20.0f;
void onInit(CBlob@ this)
{
	if (getNet().isServer())
	{
		this.server_Die();
	}
	this.set_bool("explosive_teamkill", false);
	Explode(this, range, dmg);
}
bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return false;
}