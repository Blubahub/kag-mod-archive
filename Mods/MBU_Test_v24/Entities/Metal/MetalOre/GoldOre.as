#include "Hitters.as"

void onInit(CSprite@ this)
{
	this.animation.frame = XORRandom(4);
	this.getBlob().server_setTeamNum(-1);
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}

void onInit(CBlob @this){

	this.set_u8("heat",0);
}

void onTick(CBlob @this){

	if(!this.hasTag("melted") && !this.hasTag("washed"))
	
	if(this.get_u8("heat") > 10){
		
		if(getNet().isServer()){
			
			{CBlob @blob = server_CreateBlob("molten_gold",-1,this.getPosition()+Vec2f(-4,0));
			blob.setVelocity(this.getVelocity()+Vec2f((XORRandom(11)-5.0f)*0.5f,(XORRandom(11)-5.0f)*0.5f));
			if(this.hasTag("light_infused"))blob.Tag("light_infused");}
			
			
			for (int i = 0; i < XORRandom(2) + (this.hasTag("washed") ? 0 : 2); i++)
			{
				// print("smok");
			
				CBlob@ smokey = server_CreateBlobNoInit("smoke");
				smokey.setPosition(this.getPosition());
				smokey.server_setTeamNum(-1);
				smokey.set_f32("toxicity", 0.90f); // Not so healthy smoke
				smokey.Init();
			}
			
			this.server_Die();
		}
		
		this.Tag("melted");
	}

	if(!this.hasTag("melted") && !this.hasTag("washed"))
	if(this.isInWater()){
	
		CBlob @blob = server_CreateBlob("gold_drop",-1,this.getPosition()+Vec2f(0,0));
		if(this.hasTag("light_infused"))blob.Tag("light_infused");
		
		this.server_Die();
		this.Tag("washed");
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