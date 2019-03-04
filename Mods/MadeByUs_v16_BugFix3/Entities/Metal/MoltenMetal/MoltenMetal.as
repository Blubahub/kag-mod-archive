#include "Hitters.as"

void onInit(CSprite@ this)
{
	this.getBlob().server_setTeamNum(-1);
	
}

void onTick(CSprite @this){
	CBlob @blob = this.getBlob();
	
	this.SetFacingLeft(false);
	
	if(blob !is null){
		if(!blob.isOnGround()){
			this.SetAnimation("falling");
		} else {
			this.SetAnimation("default");
			bool left = getMap().isTileSolid(blob.getPosition()+Vec2f(-6,0));
			bool right = getMap().isTileSolid(blob.getPosition()+Vec2f(6,0));
			if(left && right)this.SetAnimation("both");
			else if(!left && right)this.SetAnimation("right");
			else if(left && !right)this.SetAnimation("left");
			else if(!left && !right)this.SetAnimation("default");
		}
	}
}


void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	
	this.Tag("liquid_blob");
	
	this.SetLight(true);
	this.SetLightRadius(32.0f);
	this.SetLightColor(SColor(255, 255, 240, 64));
	
	this.set_u32("last_heated",getGameTime());
}

void onTick(CBlob @this){
	
	this.setVelocity(Vec2f(0.1*(XORRandom(3)-1),0)+this.getVelocity());
	
	if(getNet().isServer()){
		if(this.get_u32("last_heated") < getGameTime()-(30*20)){
		
			if(!this.hasTag("cooled")){
				
				if(getMap().isTileSolid(this.getPosition()+Vec2f(-6,0)) && getMap().isTileSolid(this.getPosition()+Vec2f(6,0))){
					server_CreateBlob("metal_bar",-1,this.getPosition());
					if(this.getName() == "molten_metal_large")server_CreateBlob("metal_bar",-1,this.getPosition());
				} else {
					if(this.getName() == "molten_metal")server_CreateBlob("metal_drop",-1,this.getPosition());
					if(this.getName() == "molten_metal_small")server_CreateBlob("metal_drop_small",-1,this.getPosition());
					if(this.getName() == "molten_metal_dirty")server_CreateBlob("metal_drop_dirty",-1,this.getPosition());
					if(this.getName() == "molten_metal_large")server_CreateBlob("metal_drop_large",-1,this.getPosition());
				}
				this.server_Die();
				this.Tag("cooled");
			}
		}
	}
	
	if(this.getName() == "molten_metal" || this.getName() == "molten_metal_small" || this.getName() == "molten_metal_large")
	if(getMap().isTileGroundStuff(getMap().getTile(this.getPosition()+Vec2f(0,5)).type)){
	
		if(!this.hasTag("merged") && !this.hasTag("dirtied")){
			this.Tag("dirtied");
			if(getNet().isServer()){
				server_CreateBlob("molten_metal_dirty",-1,this.getPosition());
				if(this.getName() == "molten_metal"){
					server_CreateBlob("molten_metal_dirty",-1,this.getPosition());
					if(this.hasTag("extra_small"))server_CreateBlob("molten_metal_dirty",-1,this.getPosition());
				}
				if(this.getName() == "molten_metal_large"){
					server_CreateBlob("molten_metal_dirty",-1,this.getPosition());
					server_CreateBlob("molten_metal_dirty",-1,this.getPosition());
					server_CreateBlob("molten_metal_dirty",-1,this.getPosition());
				}
				this.server_Die();
			}
		}
	}
	
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if(blob !is null)
	if(!this.hasTag("merged"))
	if(this.getName() == "molten_metal" && blob.getName() == "molten_metal")
	if(blob.hasTag("liquid_blob")){
		if(blob.getPosition().y > this.getPosition().y+3){
			this.Tag("merged");
			if(getNet().isServer()){
				server_CreateBlob("molten_metal_large",-1,this.getPosition());
				this.server_Die();
				blob.server_Die();
			}
		}
	}
	
	if(blob !is null)
	if(!this.hasTag("merged") && !blob.hasTag("merged"))
	if(this.getName() == "molten_metal_small" && blob.getName() == "molten_metal_small")
	if(blob.hasTag("liquid_blob")){
		this.Tag("merged");
		blob.Tag("merged");
		if(getNet().isServer()){
			server_CreateBlob("molten_metal",-1,this.getPosition());
			this.server_Die();
			blob.server_Die();
		}
	}
	
	if(blob !is null)
	if(!this.hasTag("merged") && !blob.hasTag("merged"))
	if(this.getName() == "molten_metal_small" && blob.getName() == "molten_metal")
	if(blob.hasTag("liquid_blob")){
		if(blob.getPosition().y > this.getPosition().y+3){
			this.Tag("merged");
			if(getNet().isServer()){
				this.server_Die();
				if(!blob.hasTag("extra_small")){
					blob.Tag("extra_small");
				} else {
					blob.Tag("merged");
					blob.server_Die();
					server_CreateBlob("molten_metal_large",-1,blob.getPosition());
				}
			}
		}
	}
	
	if(blob !is null)
	if(this.getName() == "molten_metal_large" && blob.getName() != "molten_metal_large")
	if(blob.hasTag("liquid_blob")){
		if(blob.getPosition().y > this.getPosition().y+3){
			Vec2f pos = this.getPosition();
			this.setPosition(blob.getPosition());
			blob.setPosition(pos);
		}
	}
	
	if(blob !is null)this.server_Hit(blob, blob.getPosition(), Vec2f(), 0.5f, Hitters::fire, true);
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob ){
	if(blob.hasTag("liquid_blob"))return true;
	return false;
}