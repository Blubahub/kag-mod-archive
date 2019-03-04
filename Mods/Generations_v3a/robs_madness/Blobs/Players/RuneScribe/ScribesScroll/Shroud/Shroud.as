
void onInit(CSprite@ this)
{
	this.SetZ(1000.0f);
}

void onTick(CSprite@ this)
{
	CBlob @blob = this.getBlob();
	this.ResetTransform();
	this.ResetWorldTransform();
	if(blob !is null && !blob.hasTag("scaled") && blob.get_f32("scale") != 1.0f){
		this.ScaleBy(Vec2f(blob.get_f32("scale"),blob.get_f32("scale")));
		blob.Tag("scaled");
	}
	this.RotateBy(this.getBlob().getNetworkID()*135, Vec2f(0,0));
}


void onInit(CBlob@ this)
{
	this.set_f32("scale",1.0f);
	this.getShape().SetStatic(true);
	
	this.set_u32("timer",getGameTime()+30*60);
	
	this.Tag("can_dispell");
}


void onTick(CBlob@ this)
{
	if(this.get_u32("timer") < getGameTime()){
		if(getNet().isClient())this.getSprite().ScaleBy(Vec2f(0.9,0.9));
	}
	
	if(this.get_u32("timer")+30 < getGameTime()){
		this.server_Die();
	}
	
	if(getLocalPlayerBlob() !is null){
		CBlob @player = getLocalPlayerBlob();
	
		if(player.getDistanceTo(this) < 64.0f*this.get_f32("scale")){
			this.getSprite().setRenderStyle(RenderStyle::shadow);
		} else {
			this.getSprite().setRenderStyle(RenderStyle::normal);
		}
		
	}
}