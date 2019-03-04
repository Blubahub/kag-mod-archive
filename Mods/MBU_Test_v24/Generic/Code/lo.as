///Shineeeey

#include "eleven.as";

void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightRadius(128.0f);
	this.SetLightColor(SColor(255, 255, 240, 171));
	
	this.getShape().SetGravityScale(-0.005f);
}

void onTick(CBlob@ this){
	if(getGameTime() % 40 == 0){
		if(getNet().isServer()){
			if(!checkEInterface(this,this.getPosition(),16,10))this.server_Die();
		}
	}
}

void onInit(CSprite @this){
	this.SetZ(999.0f);
	{
		CSpriteLayer@ ring = this.addSpriteLayer("ring", "go.png" , 14, 14, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (ring !is null)
		{
			Animation@ anim = ring.addAnimation("default", 0, false);
			anim.AddFrame(1);
			ring.SetRelativeZ(1.0f);
		}
	}
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	this.SetZ(999.0f);
	
	CSpriteLayer @ring = this.getSpriteLayer("ring");
	
	if (ring !is null)
	{
		ring.RotateBy(20, Vec2f(0,0));
		ring.setRenderStyle(RenderStyle::light);
	}
}