
#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.getShape().getConsts().mapCollisions = false;
	this.getShape().SetGravityScale(0.0f);
	
	this.getSprite().setRenderStyle(RenderStyle::additive);
	this.getSprite().SetLighting(false);
	
	this.set_u16("created",getGameTime());
	
	this.set_u16("host",0);
	this.set_Vec2f("host_offset",Vec2f(0,0));
	this.Untag("hosted");
	
	this.set_s16("death_amount", 0);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

void onTick(CBlob@ this){
	
	if(getNet().isServer())if(this.isInWater())this.server_Die();
	
	this.getSprite().SetVisible((!(getLocalPlayer() is null || !getLocalPlayer().hasTag("death_sight"))) || this.hasTag("ghost_stone"));
	this.getSprite().SetZ(1000.0f);
	
	this.Untag("ghost_stone");
	
	int death = this.get_s16("death_amount");
	
	if(death < 10)this.getSprite().SetFrameIndex(0);
	else if(death < 20)this.getSprite().SetFrameIndex(1);
	else if(death < 30)this.getSprite().SetFrameIndex(2);
	else this.getSprite().SetFrameIndex(3);
	
	if(!this.hasTag("hosted")){
		if(this.get_u16("created") < getGameTime()-60){
			CBlob@[] blobsInRadius;	   
			if (this.getMap().getBlobsInRadius(this.getPosition(), 320.0f, @blobsInRadius)) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ b = blobsInRadius[i];
					if(b !is null && b.get_s16("life_amount") > b.get_s16("death_amount"))
					{
						Vec2f vec = b.getPosition()-this.getPosition();
						vec.Normalize();
						f32 force = 1.0f-(b.getDistanceTo(this)/160.0f);
						this.setVelocity(this.getVelocity()*0.99f);
						this.AddForce(vec*force*2.0f);
						
						if(this.getDistanceTo(b) < 8){
							this.set_u16("host",b.getNetworkID());
							this.Tag("hosted");
							this.set_Vec2f("host_offset",this.getPosition()-b.getPosition());
						}
					}
				}
			}
		}
	} else {
		CBlob @host = getBlobByNetworkID(this.get_u16("host"));
		if(host !is null){
			this.setPosition(host.getPosition()+this.get_Vec2f("host_offset"));
			
			if(host.get_s16("life_amount") <= 0 || death >= 30){
				this.set_u16("host",0);
				this.setVelocity(Vec2f(0,-1)+host.getVelocity());
			} else {
				host.Tag("death_seed");
				if(getGameTime() % 100 == 0){
					if(host.get_s16("death_amount") > 0){
						host.sub_s16("death_amount",1);
						this.add_s16("death_amount",1);
					}
				}
			}
		} else {
			if(getNet().isServer()){
				if(death > 0){
					if(getGameTime() % 100 == 0){
						this.sub_s16("death_amount",1);
						CBlob @e = server_CreateBlob("e",-1,this.getPosition());
						if(e !is null)e.setVelocity(Vec2f(XORRandom(31)-15,XORRandom(31)-15)/20);
					}
				} else {
					this.server_Die();
				}
			}
		}
	}
	
	
	
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return false;
}
