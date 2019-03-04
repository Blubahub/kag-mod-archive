
#include "Hitters.as";

void onInit(CBlob@ this)
{
  if (getNet().isServer())
  {
    this.set_u8('decay step', 10);
  }

  this.maxQuantity = 250;
  
  this.set_u8("heat",0);
}

void onTick(CBlob @this){

	if(!this.hasTag("melted"))
	if(this.get_u8("heat") > 10){
		
		if(getNet().isServer()){
			
			for (int i = 0; i < this.getQuantity()/10+1; i++){
				CBlob @blob = server_CreateBlob("molten_glass",-1,this.getPosition()+Vec2f(-4,0));
				blob.setVelocity(this.getVelocity()+Vec2f((XORRandom(11)-5.0f)*0.5f,(XORRandom(11)-5.0f)*0.5f));
			}
			
			this.server_Die();
		}
		
		this.Tag("melted");
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::fire)
	{
		this.set_u8("heat",this.get_u8("heat")+1);
		damage = 0;
	}

	if (customData == Hitters::water)
	{
		this.set_u8("heat",0);
	}

	return damage;
}