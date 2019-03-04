void onTick(CBlob@ this)
{	
	/*
	if (this.isAttached())
	{
		AttachmentPoint@ att = this.getAttachmentPoint(0);   //only have one
		if (att !is null)
		{
			CBlob@ b = att.getOccupied();
			int MaxAmount = this.getQuantity();
			if(b.getInventory() !is null)MaxAmount += b.getInventory().getCount("mat_gold");
			if (b !is null){
				if((getMap().tilemapheight*getMap().tilesize)-(MaxAmount*2) < b.getPosition().y)
				if(MaxAmount > 0)b.AddForce(Vec2f(0, (-(b.getMass()/2))*(this.getQuantity()/MaxAmount)));
			}
		}
	}
	CBlob@ b = this.getInventoryBlob();
	int MaxAmount = this.getQuantity();
	if(b.getInventory() !is null)MaxAmount += b.getInventory().getCount("mat_gold");
	if (b !is null){
		if((getMap().tilemapheight*getMap().tilesize)-(MaxAmount*2) < b.getPosition().y)
		if(MaxAmount > 0)b.AddForce(Vec2f(0, (-(b.getMass()/2))*(this.getQuantity()/MaxAmount)));
	}*/

	int Height = 1;
	int OldHeight = 1;
	CMap@ map = this.getMap();
	Vec2f surfacepos;
	for(int i = 0; i < 15; i += 1){
		if(!map.rayCastSolid(this.getPosition(), this.getPosition()+Vec2f(0,16*i), surfacepos))Height += 1;
		else {
			this.set_u16("lastHeight",surfacepos.y);
			break;
		}
	}
	for(int i = 0; i < 15; i += 1){
		if(this.getPosition().y+16*i < this.get_u16("lastHeight"))OldHeight += 1;
		else {
			break;
		}
	}
	if(Height > 14)Height = OldHeight;
	this.AddForce(Vec2f(0, -this.getQuantity()*(0.02/Height)));
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	if (inventoryBlob is null) return;

	CInventory@ inv = inventoryBlob.getInventory();

	if (inv is null) return;

	this.doTickScripts = true;
	
	inv.doTickScripts = true;
}