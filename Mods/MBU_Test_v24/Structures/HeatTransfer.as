
#include "Explosion.as";

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 60;
	
	this.set_s16("heat",0);
	this.Tag("takes_heat");
}

void onTick(CBlob@ this)
{

	f32 heat_mod = 1.0f;
	int heat = this.get_s16("heat");
	
	if(this.getName() == "smelter")heat_mod = 0.5f;
	else if(this.getName() == "generator")heat_mod = 0.5f;

	if(this.get_s16("heat") >= 1){
		CBlob@[] blobsInRadius;	
		if (getMap().getBlobsInRadius(this.getPosition()+Vec2f(0,-32), 8, @blobsInRadius))
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b.hasTag("takes_heat")){
					if(b.get_s16("heat") < f32(heat)*heat_mod){
						b.set_s16("heat",f32(heat)*heat_mod);
						if(getNet().isServer())b.Sync("heat",true);
						break;
					}
				}
			}
		}
	}
	
	if(heat > 2000){
		Explode(this,128.0f,20.0f);
		if(isServer())this.server_Die();
	}
	
	if(heat >= 1){
		heat-=1;
	}
	
	this.set_s16("heat",heat);
	
	if(getNet().isServer() && (getGameTime()+this.getNetworkID()) % 87 == 2)this.Sync("heat",true);
}