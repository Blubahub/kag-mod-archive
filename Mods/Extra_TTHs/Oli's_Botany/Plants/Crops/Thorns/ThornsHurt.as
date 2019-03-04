//Hurt ppl u hit silly boi
#include "Hitters.as";
void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (blob !is null && blob.hasTag("flesh") && (this.hasTag("has grain") || this.getName() == "taintthorns"))
	{
		this.server_Hit(blob, point1, Vec2f(0, 0), 0.25f+(0.01*this.get_u16("quality")), Hitters::stab);
	}
}