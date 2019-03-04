#include "ShieldCommon.as";
bool didShield( CBlob@ this, CBlob@ blob )
{
	return blob.hasTag("shielded") && blockAttack(blob, this.getOldVelocity(), 0.0f);
}