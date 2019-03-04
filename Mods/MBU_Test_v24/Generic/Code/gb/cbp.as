void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.SetGravityScale(0.0f);
	shape.getConsts().mapCollisions = false;
	
	this.Tag("dbb");
}

void onTick(CBlob @this){

	if(getMap().isTileSolid(this.getPosition())){
		if(XORRandom(50) == 0)this.set_bool("fit",true);
	} else {
		this.set_bool("fit",false);
	}

	CBlob @master = getBlobByNetworkID(this.get_netid("master"));
	if(master !is null){
		Vec2f vec = master.getPosition()-this.getPosition();
		vec.Normalize();
		
		if(!this.get_bool("fit")){
			this.setPosition(this.getPosition() + master.getVelocity());

			if(this.getDistanceTo(master) > 20)
				this.setVelocity(this.getVelocity()*0.9f + vec*1.0f);
		}
		
		if(this.getDistanceTo(master) > 64)this.set_bool("fit",false);
		
		if(this.getDistanceTo(master) < 16)
			this.AddForce(vec*-0.1f);
		
		CSprite @sprite = this.getSprite();
		if(getMap().getTile(this.getPosition()).light <= 64 || this.isInWater()){
			sprite.setRenderStyle(RenderStyle::shadow);
		} else {
			sprite.setRenderStyle(RenderStyle::normal);
		}
			
		if (getNet().isClient())
		{		
			f32 maxDistance = 400;
			bool flip = this.isFacingLeft();
			f32 angle =	UpdateAngle(this,master.getPosition());
			Vec2f dir = Vec2f((this.isFacingLeft() ? -1 : 1), 0.0f).RotateBy(angle);
					
			f32 length = this.getDistanceTo(master);
			
			CSpriteLayer@ smite = this.getSprite().getSpriteLayer("smite");
			if (smite !is null)
			{
				smite.ResetTransform();
				smite.ScaleBy(Vec2f(length / 24.0f, 1.0f));
				smite.TranslateBy(Vec2f((length / 2), 1.0f * (flip ? 1 : -1)));
				smite.RotateBy((flip ? 180 : 0)+angle, Vec2f(0,0));
				smite.SetVisible(true);
			}
		}
			
	} else {
		if(isServer())this.server_Die();
	}
	
	
	
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob ){

	return blob.hasTag("dbb");

}

void onInit(CSprite@ this)
{
	this.RemoveSpriteLayer("smite");
	CSpriteLayer@ smite = this.addSpriteLayer("smite", "cb.png", 24, 24);
	if(smite !is null)
	{
		Animation@ anim = smite.addAnimation("default", 0, false);
		anim.AddFrame(2);
		smite.SetRelativeZ(-5.0f);
		smite.SetVisible(false);
	}
}

int UpdateAngle(CBlob@ this, Vec2f aimpos)
{
	Vec2f pos=this.getPosition();
	
	Vec2f aim_vec =(pos - aimpos);
	aim_vec.Normalize();
	
	f32 mouseAngle=aim_vec.getAngleDegrees();
	if(!this.isFacingLeft()) mouseAngle += 180;

	return -mouseAngle;
}