
void onInit(CSprite@ this)
{

	this.SetZ(-2.0f);

	this.RemoveSpriteLayer("top");
	CSpriteLayer@ Top = this.addSpriteLayer("top", "Geyser.png" , 32, 11, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (Top !is null)
	{
		Animation@ animcharge = Top.addAnimation("default", 0, true);
		animcharge.AddFrame(0);
		animcharge.AddFrame(1);
		animcharge.AddFrame(2);
		animcharge.AddFrame(3);
		animcharge.AddFrame(4);
		animcharge.AddFrame(5);
		Top.SetOffset(Vec2f(0.0f, -11.0f));
		Top.SetAnimation("default");
		Top.SetRelativeZ(1.0f);
		Top.SetFrameIndex(this.getFrameIndex());
	}

	// Sounds by TFlippy
	this.PlaySound("WC3_Geyser", 1.00f, 1.00f);
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
	for(float i = 0.0f; i <= (blob.get_f32("Height"))/11; i++){
		
		CSpriteLayer@ layer = this.getSpriteLayer("layer"+(i*1));
		
		if(layer !is null) {
			layer.SetOffset(Vec2f(0.0f, (-11.0f)*(i+1)));
			layer.SetFrameIndex(this.getFrameIndex());
		} else {
			@layer = this.addSpriteLayer("layer"+(i*1), "Geyser.png" , 32, 11, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

			if (layer !is null)
			{
				Animation@ animcharge = layer.addAnimation("default", 0, true);
				animcharge.AddFrame(6);
				animcharge.AddFrame(7);
				animcharge.AddFrame(8);
				animcharge.AddFrame(9);
				animcharge.AddFrame(10);
				animcharge.AddFrame(11);
				layer.SetOffset(Vec2f(0.0f, -11.0f));
				layer.SetAnimation("default");
				layer.SetFrameIndex(this.getFrameIndex());
			}
		}
	}
	
	for(int i = 0; i < this.getSpriteLayerCount(); i++){
		CSpriteLayer@ layer = this.getSpriteLayer(i);
		if(layer.name != "top")
		if(layer.getOffset().y < (-11.0f)*((blob.get_f32("Height")/11)+1))this.RemoveSpriteLayer(layer.name);
	}
	
	CSpriteLayer@ top = this.getSpriteLayer("top");
		
	if(top !is null) {
		top.SetOffset(Vec2f(0.0f, (-11.0f)-(blob.get_f32("Height"))));
		top.SetFrameIndex(this.getFrameIndex());
	}
}


void onInit(CBlob@ this)
{
	this.set_f32("Height",0);
	this.set_u8("WaitTime",0);
	
	this.set_f32("MaxHeight",90);
	this.set_u8("Push",0);
	
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(solid)
	{
		this.getShape().SetStatic(true);
	}
}

void sparks(Vec2f at, f32 angle, f32 speed, SColor color)
{
	Vec2f vel = getRandomVelocity(angle + 90.0f, speed, 25.0f);
	at.y -= 2.5f;
	ParticlePixel(at, vel, color, true, 119);
}

void onTick(CBlob@ this)
{
	if(this.get_u8("WaitTime") < 120){
		if(this.get_f32("Height") < this.get_f32("MaxHeight"))this.set_f32("Height",this.get_f32("Height")+2.0f);
		else this.set_u8("WaitTime",this.get_u8("WaitTime")+1);
	} 
	else {
		if(this.get_f32("Height") > 0)this.set_f32("Height",this.get_f32("Height")-2.0f);
		else this.server_Die();
	}
	
	CBlob@[] blobsInRadius;	
	if (this.getMap().getBlobsInRadius(this.getPosition(), 90.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b !is null && b !is this && !b.getShape().isStatic() && b.hasTag("flesh")){
				if(b.getPosition().x > this.getPosition().x-16)
				if(b.getPosition().y < this.getPosition().y)
				if(b.getPosition().x < this.getPosition().x+16)
				if(b.getPosition().y > this.getPosition().y-(this.get_f32("Height")+11))
				b.AddForce(Vec2f(0,-(this.get_u8("Push")*20)));
			}
		}
	}
	
	sparks(this.getPosition()-Vec2f(16-XORRandom(33),XORRandom(this.get_f32("Height")+11)), XORRandom(60)-30, 3.5f + (XORRandom(10) / 5.0f), SColor(255, 44, 175, 222));
}