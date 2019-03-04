void onInit(CSprite@ this)
{
	for(int i = 0; i < 4; i += 1)
	{
		this.RemoveSpriteLayer("ward"+i);
		CSpriteLayer@ genericstatuseffect = this.addSpriteLayer("ward"+i, "Wards.png" , 8, 17, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (genericstatuseffect !is null)
		{
			Animation@ anim = genericstatuseffect.addAnimation("default", 0, false);
			for(int j = 0; j < 21; j += 1)anim.AddFrame(j);
			genericstatuseffect.SetFrame(20);
			genericstatuseffect.SetOffset(Vec2f(8-i*4,-3));
			genericstatuseffect.SetAnimation("default");
			genericstatuseffect.SetVisible(true);
			genericstatuseffect.SetRelativeZ(-1.0f*i);
		}
	}
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	for(int i = 0; i < 4; i += 1)this.getSpriteLayer("ward"+i).SetVisible(false);
	
	int currentSlot = 1;
	
	
	CInventory@ inv = blob.getInventory();
	if(inv !is null){
		for (int i = 0; i < inv.getItemsCount(); i++)
		{
			CBlob@ item = inv.getItem(i);
			if(item !is null){
				if(item.getName() == "ward"){
					this.getSpriteLayer("ward"+currentSlot).SetVisible(true);
					if(!item.hasTag("SetType"))this.getSpriteLayer("ward"+currentSlot).SetFrame(20);
					else this.getSpriteLayer("ward"+currentSlot).SetFrame(item.get_s16("type")*5+item.get_s16("subtype"));
					if(currentSlot == 1)currentSlot = 2;
					else if(currentSlot == 2)currentSlot = 0;
					else if(currentSlot == 0)currentSlot = 3;
				}
			}
		}
	}
}