// Lantern script

void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightRadius(64.0f);
	this.SetLightColor(SColor(255, 255, 240, 171));
	
	this.Tag("gold");
}

void onTick(CBlob@ this)
{
	CShape@ shape = this.getShape();
	shape.SetGravityScale(0.0f);
	
	if (getNet().isServer()){
		CBlob @blob = server_CreateBlob("goldendrop", -1, this.getPosition()+Vec2f(XORRandom(64)-32,0));
		if (blob !is null)
		{
			Vec2f smiteVel = Vec2f(0,1);
			smiteVel.Normalize();
			blob.setVelocity(smiteVel*1);
		}
	}
}