void onTick(CBlob@ this)
{

	if (this.isAttached())
	{
		AttachmentPoint@ att = this.getAttachmentPoint(0);   //only have one
		if (att !is null)
		{
			CBlob@ b = att.getOccupied();
			if (b !is null)
			if(!b.hasTag("player")){
				if(!b.hasTag("SetLastHeight")){
					b.set_u16("lastHeight",b.getPosition().y+16*5);
					b.Tag("SetLastHeight");
				}
				
				int Height = 1;
				int OldHeight = 1;
				CMap@ map = this.getMap();
				Vec2f surfacepos;
				for(int i = 0; i < 15; i += 1){
					if(!map.rayCastSolid(b.getPosition(), b.getPosition()+Vec2f(0,16*i), surfacepos)){
						Height += 1;
					} else {
						b.set_u16("lastHeight",surfacepos.y);
						break;
					}
				}
				for(int i = 0; i < 15; i += 1){
					if(b.getPosition().y+16*i < b.get_u16("lastHeight"))OldHeight += 1;
					else {
						break;
					}
				}
				
				float HeightCapModifier = 1;
				if(b.getPosition().y < 64)HeightCapModifier = b.getPosition().y/64.0f;
				
				if(Height > 14)Height = OldHeight;
				b.AddForce(Vec2f(0, -this.getQuantity()*1/Height*(b.getMass()/75*HeightCapModifier)));
			}
		}
	}
	CBlob@ b = this.getInventoryBlob();
	if (b !is null)
	if(!b.hasTag("player")){
		if(!b.hasTag("SetLastHeight")){
			b.set_u16("lastHeight",b.getPosition().y+16*5);
			b.Tag("SetLastHeight");
		}
		int Height = 1;
		int OldHeight = 1;
		CMap@ map = this.getMap();
		Vec2f surfacepos;
		for(int i = 0; i < 15; i += 1){
			if(!map.rayCastSolid(b.getPosition(), b.getPosition()+Vec2f(0,16*i), surfacepos))Height += 1;
			else {
				b.set_u16("lastHeight",surfacepos.y);
				break;
			}
		}
		for(int i = 0; i < 15; i += 1){
			if(b.getPosition().y+16*i < b.get_u16("lastHeight"))OldHeight += 1;
			else {
				break;
			}
		}
		if(Height > 14)Height = OldHeight;
		
		float HeightCapModifier = 1;
		if(b.getPosition().y < 64)HeightCapModifier = b.getPosition().y/64.0f;
		
		b.AddForce(Vec2f(0, -this.getQuantity()*1/Height*(b.getMass()/75)*HeightCapModifier));
	}

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
	this.AddForce(Vec2f(0, -this.getQuantity()*(4/Height)));
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	if (inventoryBlob is null) return;

	CInventory@ inv = inventoryBlob.getInventory();

	if (inv is null) return;

	this.doTickScripts = true;
	
	inv.doTickScripts = true;
}