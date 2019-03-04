#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.SetMapEdgeFlags(CBlob::map_collide_none);
	this.getShape().getConsts().bullet = true;
	
	this.getShape().SetGravityScale(0.0f);
	//this.getShape().getConsts().mapCollisions = false;
	this.server_SetTimeToDie(20.0f);
	
	this.Tag("can_dispell");
}

void onTick(CBlob@ this)
{
	
	CBlob@[] blobsInRadius;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), 128.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(!b.hasTag("dead"))
			if(b.hasTag("flesh") && b.getName() != "migrant" && !b.hasTag("hyperbubble") && b.hasTag("player"))
			{
				Vec2f Vel = b.getPosition()-this.getPosition();
				Vel.Normalize();
				this.AddForce(Vel*0.1);
			}
		}
	}
	
	CSprite@ sprite = this.getSprite();
	
	if(sprite !is null){
		sprite.setRenderStyle(RenderStyle::additive);
		if(sprite.getSpriteLayer("airbubble") is null){
			sprite.RemoveSpriteLayer("airbubble");
			CSpriteLayer@ airbubble = sprite.addSpriteLayer("airbubble", "AirBubbleOutter.png", 32, 32);

			if (airbubble !is null)
			{
				Animation@ anim = airbubble.addAnimation("default", 4, false);
				int[] frames = {3};
				anim.AddFrames(frames);
				airbubble.SetRelativeZ(1.0f);
				airbubble.SetOffset(Vec2f(0,0));
			}
		} else {
			sprite.getSpriteLayer("airbubble").setRenderStyle(RenderStyle::normal);
		}
	}
	
	this.AddForce(Vec2f(XORRandom(7)-3,XORRandom(6)-3)*0.05);

}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(blob is null)return;
	
	if(!blob.hasTag("dead"))
	if(blob.hasTag("flesh") && blob.getName() != "migrant" && !blob.hasTag("hyperbubble") && blob.hasTag("player"))
	{
		blob.AddScript("AirBubble.as");
		blob.Tag("hyperbubble");
		blob.set_u32("air_buff",getGameTime()+(10*30));
		if(getNet().isServer())blob.Sync("hyperbubble",true);
		if(getNet().isServer())blob.Sync("air_buff",true);
		this.server_Die();
	}
	
}