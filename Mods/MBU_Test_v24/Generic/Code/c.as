
void onInit(CBlob@ this)
{
	this.set_u16("owner",0);
	
	this.getSprite().SetVisible(false);
	
	if(getNet().isServer())this.server_SetTimeToDie(10);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

void onTick(CBlob@ this){
	
	/*CPlayer @p = getPlayerByUsername("Pirate-Rob");
	if(p !is null){
		CBlob @owner = p.getBlob();
		if(owner !is null){
			this.set_u16("owner",owner.getNetworkID());
		}
	}*/
	
	CBlob @owner = getBlobByNetworkID(this.get_u16("owner"));
	
	if(owner !is null){
		if(owner.getVelocity().y < 0 && this.getVelocity().y <= 0)this.setVelocity(Vec2f(-owner.getVelocity().x*0.5f,owner.getVelocity().y));
		else this.setVelocity(Vec2f(-owner.getVelocity().x*0.5f,this.getVelocity().y));
	}
}

void onRender(CSprite@ this)
{

	CBlob@ blob = this.getBlob();
	
	if(blob is null)return;
	
	RenderStyle::Style style = RenderStyle::normal;
	
	CBlob @owner = getBlobByNetworkID(blob.get_u16("owner"));
	
	if(owner !is null){
		owner.RenderForHUD(blob.getPosition()-owner.getPosition(), 0, SColor(255,255,255,255), style);
	}

}