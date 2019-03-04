
#include "Hitters.as";
#include "Explosion.as";

void onInit(CBlob@ this)
{
  if (getNet().isServer())
  {
    this.set_u8('decay step', 0);
  }

  this.maxQuantity = 250;
  

}

void onTick(CBlob@ this)
{
	if(this.hasTag("fizzing"))if(getGameTime() % 5 == 0)if(XORRandom(3) == 0){
		Explode(this,f32(this.getQuantity())/5.0f,f32(this.getQuantity())/50.0f);
		if(getNet().isServer()){
			if(this.getQuantity() <= 1)this.server_Die();
			else this.server_SetQuantity(this.getQuantity()-1);
		}
	}
	
	if(this.isInWater())this.Untag("fizzing");
}


f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::burn || customData == Hitters::fire ||  customData == Hitters::explosion || customData == Hitters::keg || customData == Hitters::bomb || customData == Hitters::bomb_arrow || customData == Hitters::mine)
	{
		this.Tag("fizzing");
	}

	return 0.0f;
}
