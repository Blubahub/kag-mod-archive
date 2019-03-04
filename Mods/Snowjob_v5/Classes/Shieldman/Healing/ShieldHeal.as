
void onInit(CBlob @ this){

	this.set_u16("following",0);
	
	this.getShape().SetGravityScale(0.0f);
	this.getShape().getConsts().mapCollisions = false;

}

void onTick(CBlob @ this)
{

	Vec2f Force = this.getVelocity()*0.95;
	
	CBlob@ target = getBlobByNetworkID(this.get_u16("following"));
	if (target !is null)
	{
	
		Vec2f Force2 = ((target.getPosition()+Vec2f(XORRandom(16)-8,XORRandom(16)-8)) - this.getPosition());
		
		Force2.Normalize();
	
		this.setVelocity(Force2*0.4+Force);
		
		if(target.getPosition().x-6 < this.getPosition().x && target.getPosition().x+6 > this.getPosition().x)
		if(target.getPosition().y-6 < this.getPosition().y && target.getPosition().y+6 > this.getPosition().y){
			this.server_Die();
			target.server_Heal(0.25);
		}
	
	} else this.server_Die();

	
}

void onDie(CBlob @this){
	ParticlesFromSprite(this.getSprite());
}

void onInit(CSprite @this){
	this.SetLighting(false);
	this.SetRelativeZ(1000.0f);
}