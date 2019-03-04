
void onInit(CSprite@ this)
{
	this.SetZ(-100.0f);
}

void onTick(CBlob@ this)
{
	this.getSprite().SetFrame(this.get_u16("frame"));
	
	int tile = getMap().getTile(this.getPosition()).type;
	if(tile < 400 || tile > 415){
		if(getNet().isServer())this.server_Die();
	}
}

void onInit(CBlob@ this)
{
	this.getShape().SetStatic(true);
	
	this.set_u16("frame", 8);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return true;
}