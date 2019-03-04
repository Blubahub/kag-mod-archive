//tree making logs on death script

#include "MakeSeed.as"
#include "MakeMat.as";

void onDie(CBlob@ this)
{
	if (!getNet().isServer()) return; //SERVER ONLY

	Vec2f pos = this.getPosition();

	server_MakeSeed(pos, this.getName());
	
	// if(this.getName() == "tree_bushy" || this.getName() == "tree_pine")MakeMat(this, pos, "mat_hemp", 10);

}
