/* 12a9rck.as
 * author: Aphelion
 */
 
#include "r8c40j.as";

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
    // when dead, collide only if its moving and some time has passed after death
	if (this.hasTag("dead") )
	{
		bool slow = (this.getShape().vellen < 1.5f);
        return !slow;
	}
	return !(blob.hasTag("player") && isTeamFriendly(this.getTeamNum(), blob.getTeamNum()));
}
