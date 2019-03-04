
void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
    
	if(blob.get_u8("core") != blob.get_u8("core_sprite")){
		string texname = "GolemNoCore.png";
		if(blob.get_u8("core") == 1)texname = "GolemStoneCore.png";
		if(blob.get_u8("core") == 2)texname = "GolemGoldCore.png";
		if(blob.get_u8("core") == 3)texname = "GolemGhostCore.png";
		this.ReloadSprite(texname);
		blob.set_u8("core_sprite",blob.get_u8("core"));
	}
}



void onTick(CBlob@ this)
{
	if(this.get_u8("core") != 2)this.getShape().SetMass(80);
	else this.getShape().SetMass(60);
}