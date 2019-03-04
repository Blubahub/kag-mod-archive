
#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.getShape().getConsts().mapCollisions = false;
	this.getShape().SetGravityScale(0.0f);
	
	this.getSprite().setRenderStyle(RenderStyle::additive);
	this.getSprite().SetLighting(false);
	
	this.set_u16("created",getGameTime());
	
	this.set_u8("worth",1);
	
	this.server_SetTimeToDie(30);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

void onTick(CBlob@ this){
	
	this.getSprite().SetVisible((!(getLocalPlayer() is null || !getLocalPlayer().hasTag("death_sight"))) || this.hasTag("ghost_stone"));
	this.getSprite().SetZ(1000.0f);
	
	this.Untag("ghost_stone");
	
	f32 VelX = this.getVelocity().x;
	f32 VelY = this.getVelocity().y;
	
	if(Maths::Abs(VelX) < Maths::Abs(VelY)){
		if(VelY > 0)this.getSprite().SetFrameIndex(3);
		else this.getSprite().SetFrameIndex(0);
	} else
	if(Maths::Abs(VelX) > Maths::Abs(VelY)){
		if(VelX > 0)this.getSprite().SetFrameIndex(1);
		else this.getSprite().SetFrameIndex(2);
	} else {
		this.getSprite().SetFrameIndex(0);
	}
	
	if(this.exists("owner_name"))if(this.get_u16("created") < getGameTime()-60){
		CBlob @owner = getBlobByNetworkID(this.get_u16("owner"));
		if(owner !is null){
			Vec2f aim = owner.getPosition()-this.getPosition();
			aim.Normalize();
			this.setVelocity(aim);
		}
		
		CPlayer @p = getPlayerByUsername(this.get_string("owner_name"));
		if(p !is null){
			@owner = p.getBlob();
			if(owner !is null){
				this.set_u16("owner",owner.getNetworkID());
			}
		}
	}
	
	if(XORRandom(10) == 0)this.setVelocity(this.getVelocity()+(Vec2f(XORRandom(3)-1,XORRandom(3)-1)/10));
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return false;
}
