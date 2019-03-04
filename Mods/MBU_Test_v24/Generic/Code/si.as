
#include "Hitters.as";
#include "HumanoidCommon.as";

void onInit(CBlob@ this)
{
	this.getShape().getConsts().mapCollisions = false;
	this.getShape().SetGravityScale(0.0f);
	
	this.getSprite().setRenderStyle(RenderStyle::additive);
	this.getSprite().SetLighting(false);
	
	this.set_u16("created",getGameTime());
	
	this.set_u16("owner",0);
	this.set_string("owner_name","");
	
	this.set_u16("reap_time",getGameTime());
	
	this.set_u8("equip_slot", 3);
	this.set_u8("equip_type", 3);
	this.set_f32("damage", 6.0f);
	this.set_u8("hitter", Hitters::sword);
	this.set_u8("speed",5);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

void onTick(CBlob@ this){
	
	if(!this.isInInventory()){
		this.getSprite().SetVisible((!(getLocalPlayer() is null || !getLocalPlayer().hasTag("death_sight"))) || this.hasTag("manifested"));
		if(!this.hasTag("manifested"))this.getSprite().setRenderStyle(RenderStyle::additive);
		else this.getSprite().setRenderStyle(RenderStyle::normal);
		this.getSprite().SetZ(1000.0f);
	} else {
		this.getSprite().SetVisible(false);
	}
	
	f32 spin_speed = (Maths::Abs(this.getVelocity().x)+Maths::Abs(this.getVelocity().y))*5.0f;
	
	this.setAngleDegrees(this.getAngleDegrees()-spin_speed);
	
	CBlob @owner = getBlobByNetworkID(this.get_u16("owner"));
	if(owner !is null){
		this.set_bool("manifested",owner.hasTag("manifested"));
		
		if(!this.hasTag("reaping")){
			if(this.getDistanceTo(owner) > 32.0f){
				Vec2f aim = owner.getPosition()-this.getPosition();
				aim.Normalize();
				if(this.getDistanceTo(owner) < 128.0f)this.setVelocity(this.getVelocity()*0.9f+aim);
				else this.setVelocity(this.getVelocity()*0.99f+aim);
			} else {
				if(this.hasTag("manifested")){
					equipItem(owner, this, "main_arm");
				}
			}
		} else {
			if(this.get_u16("reap_time") < getGameTime()){
				this.Untag("reaping");
			}
		}
	}

	
	
	CPlayer @p = getPlayerByUsername(this.get_string("owner_name"));
	if(p !is null){
		@owner = p.getBlob();
		if(owner !is null){
			this.set_u16("owner",owner.getNetworkID());
		}
	}
	
	if(owner is null)this.server_Die();

}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return false;
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(blob !is null){
		
		if(getNet().isServer()){
			CBlob @owner = null;
			CPlayer @p = getPlayerByUsername(this.get_string("owner_name"));
				if(p !is null)
					@owner = p.getBlob();
			
			if(blob.getName() == "e")
			if(blob.get_u16("created") < getGameTime()-60){
				if(owner !is null){
					owner.add_s16("death_amount",1);
					blob.server_Die();
				}
			}
			
			if(blob.getName() == "ds"){
				if(blob.get_s16("death_amount") > 10 && this.hasTag("reaping")){
					if(owner !is null){
						owner.add_s16("death_amount",blob.get_s16("death_amount"));
						blob.server_Die();
					}
				}
			} else 
			if(blob.get_s16("death_amount") > 0 && blob !is owner){
				for(int i = 0;i < this.get_f32("damage");i++){
					if(blob.get_s16("death_amount") > 0){
						blob.sub_s16("death_amount",1);
						CBlob @e = server_CreateBlob("e",-1,blob.getPosition());
						if(e !is null)e.setVelocity(Vec2f(XORRandom(65)-32,XORRandom(65)-32)/20);
					} else {
						break;
					}
				}
			}
			
			if(this.hasTag("manifested"))
			if(blob !is owner){
				this.server_Hit(blob, blob.getPosition(), Vec2f(0,0), this.get_f32("damage"), this.get_u8("hitter"), false);
			}
			
			
			
		}
	}
}
