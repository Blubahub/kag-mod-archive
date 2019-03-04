
void onInit(CBlob @ this){

	this.set_u16("following",0);
	
	this.getShape().SetGravityScale(0.0f);
	this.getShape().getConsts().mapCollisions = false;

}

void onTick(CBlob @ this)
{

	Vec2f Force = this.getVelocity()*0.97;
	
	CBlob@ master = getBlobByNetworkID(this.get_u16("following"));
	if (master !is null)
	{
	
		Vec2f Force2 = ((master.getPosition()+Vec2f(XORRandom(32)-16,XORRandom(32)-24)) - this.getPosition());
		
		Force2.Normalize();
	
		this.setVelocity(Force2*0.8+Force);
	
	} else this.server_Die();

}

void onDie(CBlob @this){
	ParticlesFromSprite(this.getSprite());
}