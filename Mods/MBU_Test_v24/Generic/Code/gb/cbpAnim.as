
void onInit(CSprite @this){
	//this.SetZ(1000.0f);

	CBlob@ blob = this.getBlob();
	
	for(int i= 0;i < 3;i++)
	{
		CSpriteLayer@ ring = this.addSpriteLayer("blob_"+i, "cb.png" , 24, 24, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (ring !is null)
		{
			Animation@ anim = ring.addAnimation("default", 0, false);
			anim.AddFrame(3+XORRandom(2));
			ring.SetRelativeZ(-2.0f);
		}
		blob.set_s8("blob_"+i+"speed",XORRandom(16)-8);
	}
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	//this.setRenderStyle(RenderStyle::shadow);
	
	for(int i= 0;i < 3;i++)
	{
		int speed = blob.get_s8("blob_"+i+"speed");
	
		CSpriteLayer@ ring = this.getSpriteLayer("blob_"+i);
		if (ring !is null)
		{
			ring.RotateBy(speed, Vec2f(0,0));
		}
		if(XORRandom(100) == 0 || speed == 0)blob.set_s8("blob_"+i+"speed",XORRandom(16)-8);
	}

	
}