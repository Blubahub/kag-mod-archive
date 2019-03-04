//tree making logs on death script

#include "MakeSeed.as"
#include "MakeMat.as";

void onDie(CBlob@ this)
{
	if (!getNet().isServer()) return; //SERVER ONLY

	Vec2f pos = this.getPosition();

	server_MakeSeed(pos, this.getName());
	
	MakeMat(this, pos, "mat_hemp", 10);

}
