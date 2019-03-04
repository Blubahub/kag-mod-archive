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

	if(!this.hasTag("melted"))
	if(this.get_u8("heat") > 10){
		
		if(getNet().isServer()){
			CBlob @blob = server_CreateBlob("molten_metal",-1,this.getPosition());
			
			CBlob @blob1 = server_CreateBlob("molten_metal_small",-1,this.getPosition()+Vec2f(-4,0));
			blob1.setVelocity(this.getVelocity()+Vec2f((XORRandom(11)-5.0f)*0.5f,(XORRandom(11)-5.0f)*0.5f));
			CBlob @blob2 = server_CreateBlob("molten_metal_small",-1,this.getPosition()+Vec2f(4,0));
			blob2.setVelocity(this.getVelocity()+Vec2f((XORRandom(11)-5.0f)*0.5f,(XORRandom(11)-5.0f)*0.5f));
			
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