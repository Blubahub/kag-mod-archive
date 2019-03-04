void onInit(CSprite@ this)
{
	CBlob @blob = this.getBlob();
	if(blob is null)return;
	
	blob.set_u8("fake_colour",blob.getTeamNum());
	blob.set_u8("sprite_colour",blob.getTeamNum());
}

void onTick(CSprite@ this)
{
	CBlob @blob = this.getBlob();
	if(blob is null)return;
	
	if(blob.get_u8("fake_colour") != blob.get_u8("sprite_colour")){
		this.ReloadSprites(blob.get_u8("fake_colour"), 0);
		blob.set_u8("sprite_colour",blob.get_u8("fake_colour"));
	}
}