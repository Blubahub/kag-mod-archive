#include "MakeSeed.as"
void onDie(CBlob@ this)
{
	server_MakeSeed(this.getPosition(), "bush", 1500, 1, 4);
	server_MakeSeed(this.getPosition(), "bush", 1500, 1, 4);
}