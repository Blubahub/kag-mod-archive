
#include "ep.as"

void onInit(CBlob @this){

	this.getCurrentScript().tickFrequency = 30;
	
	this.Tag("tainted");

}

void onTick(CBlob @this){
	
	this.getCurrentScript().tickFrequency = 30;
	
	CBlob@[] blobsInRadius;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), 48.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b.exists("dark_amount")){
				this.getCurrentScript().tickFrequency = 1;
				if(this.getDistanceTo(b) < XORRandom(48)){
					Vec2f vec = b.getPosition()-this.getPosition();
					vec.Normalize();
					cpr(this.getPosition()+Vec2f(XORRandom(7)-3,XORRandom(7)-3),vec*2.0f);
					if(getGameTime() % 5 == 0){
						this.getSprite().PlaySound("sk.ogg");
						int darkness = b.get_s16("dark_amount");
						if(XORRandom(darkness) == 0){
							b.add_s16("dark_amount",1);
							b.Tag("tainted");
							if(isServer()){
								b.Sync("dark_amount",true);
								b.Sync("tainted",true);
							}
						}
					}
				}
			}
		}
	}

}
