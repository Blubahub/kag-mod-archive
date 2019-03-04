void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
    
	if(blob.get_u8("core") != blob.get_u8("core_sprite")){
		string texname = "GoldGolemNoCore.png";
		if(blob.get_u8("core") == 1)texname = "GoldGolemStoneCore.png";
		if(blob.get_u8("core") == 2)texname = "GoldGolemGoldCore.png";
		if(blob.get_u8("core") == 3)texname = "GoldGolemGhostCore.png";
		this.ReloadSprite(texname);
		blob.set_u8("core_sprite",blob.get_u8("core"));
	}
}


void onInit(CBlob@ this)
{
	this.Tag("gold");
}

void onTick(CBlob@ this)
{
	if(this.get_u8("core") != 2)this.getShape().SetMass(30);
	else this.getShape().SetMass(20);
	
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
	this.AddForce(Vec2f(0, -(20)/Height));
	
}