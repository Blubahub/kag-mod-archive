#include "MakeSeed.as"
void onDie(CBlob@ this)
{
	if (getNet().isServer())
	for(int i = 0; i < 1; i++){
		CBlob @seed = server_MakeSeed(this.getPosition(), this.getName());
		//seed.setVelocity(Vec2f(XORRandom(10)-5,-5));
	}
}