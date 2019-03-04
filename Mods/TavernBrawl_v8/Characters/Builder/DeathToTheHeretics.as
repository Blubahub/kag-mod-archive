
/*
#include "Explosion.as";
void onDie(CBlob@ this)
{
	this.server_setTeamNum(-1);
	Explode(this, 10.f, 1.f);
}
*/

// DEATH TO ALL HERETICS!!!
void onTick(CBlob@ this)
{
	this.server_Die();
}
