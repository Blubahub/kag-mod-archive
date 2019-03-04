#include "MakeMat.as";

#define SERVER_ONLY

void dropFlesh(CBlob@ this)
{
	if (!this.hasTag("dropped flesh")) //double check
	{
		this.Tag("dropped flesh");
		MakeMat(this, this.getPosition(), "mat_fflesh", XORRandom(15)+5);
	}
}

void onDie(CBlob@ this)
{
	if (this.hasTag("switch class") || this.hasTag("dropped flesh")) { return; }
	dropFlesh(this);
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}
