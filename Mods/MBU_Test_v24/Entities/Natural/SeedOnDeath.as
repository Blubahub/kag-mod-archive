#include "MakeSeed.as"
void onDie(CBlob@ this)
{
	if (getNet().isServer())
	for(int i = 0; i < 2+XORRandom(2); i++){
		CBlob @seed = server_MakeSeed(this.getPosition(), this.getName());
		if(i != 0)seed.setVelocity(Vec2f(XORRandom(10)-5,-5));
	}
}