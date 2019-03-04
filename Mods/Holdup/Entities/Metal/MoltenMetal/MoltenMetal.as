#include "Hitters.as"

void onInit(CSprite@ this)
{
	this.getBlob().server_setTeamNum(-1);
	
	this.SetEmitSound("amb_ember_loop_01.ogg");
	this.SetEmitSoundVolume(0.0f);
	this.SetEmitSoundSpeed(0.0f);
	this.SetEmitSoundPaused(false);
}

void onTick(CSprite @this){
	CBlob@ blob = this.getBlob();
	
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
	
	// TFlippy's Edit
	{
		const f32 heat = (f32(30 * 20) - f32(getGameTime() - blob.get_u32("last_heated")));
		const f32 modifier = Maths::Min(heat / 600.00f, 1.00f);
	
		if (getNet().isClient())
		{
			this.SetEmitSoundSpeed(0.60f + (0.30f * modifier));
			this.SetEmitSoundVolume(0.08f + (0.15f * modifier));
			blob.SetLightRadius(48.0f * modifier);
		}
	
		if (XORRandom(100) < 100 * modifier)
		{
			if (getNet().isClient())
			{
				if (getGameTime() % 3 == 0) 
				{
					if (XORRandom(100) < 50) ParticlePixel(blob.getPosition(), getRandomVelocity(90, 4, 45), SColor(255, 255, 50 + XORRandom(100), 0), true, 10 + XORRandom(20));
					else  makeFireParticle(blob, "SmallFire" + (XORRandom(2) + 1));
				}
			}
			
			// if (getNet().isServer())
			// {
				// getMap().server_setFireWorldspace(blob.getPosition(), true);
			// }
		}
	}	
}

void makeFireParticle(CBlob@ this, const string filename = "SmallSmoke")
{
	Vec2f random = Vec2f(XORRandom(128) - 64, XORRandom(128) - 64) * 0.015625f * this.getRadius();
	ParticleAnimated(CFileMatcher(filename).getFirst(), this.getPosition() + random, getRandomVelocity(90, 0.50f, 45), 0, 1.0f, 2 + XORRandom(3), ((XORRandom(200) - 100) / 800.00f), true);
}

void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	// shape.SetGravityScale(0.0f);
	shape.SetRotationsAllowed(false);
	
	this.Tag("liquid_blob");
	
	this.SetLight(true);
	this.SetLightColor(SColor(255, 255, 240, 64));
	
	this.set_u32("last_heated",getGameTime());
}

void onDie(CBlob@ this)
{
	if (getNet().isClient()) this.getSprite().PlaySound("ExtinguishFire.ogg");
}

void onTick(CBlob @this){
	
	this.setVelocity(Vec2f(0.1*(XORRandom(3)-1),0)+this.getVelocity());
	
	if(getNet().isServer()){
		if(this.get_u32("last_heated") < getGameTime()-(30*20)){
		
			if(!this.hasTag("cooled")){
				
				if(getMap().isTileSolid(this.getPosition()+Vec2f(-6,0)) && getMap().isTileSolid(this.getPosition()+Vec2f(6,0))){
					if(this.getName() == "molten_metal")server_CreateBlob("metal_bar",-1,this.getPosition());
					if(this.getName() == "molten_metal_dirty")server_CreateBlob("metal_drop_dirty",-1,this.getPosition());
					if(this.getName() == "molten_gold")server_CreateBlob("gold_bar",-1,this.getPosition());
				} else {
					if(this.getName() == "molten_metal")server_CreateBlob("metal_drop",-1,this.getPosition());
					if(this.getName() == "molten_metal_dirty")server_CreateBlob("metal_drop_dirty",-1,this.getPosition());
					if(this.getName() == "molten_gold")server_CreateBlob("gold_drop",-1,this.getPosition());
				}
				this.server_Die();
				this.Tag("cooled");
			}
		}
	}
	
	if(this.getName() == "molten_metal" || this.getName() == "molten_gold")
	if(getMap().isTileGroundStuff(getMap().getTile(this.getPosition()+Vec2f(0,5)).type)){
	
		if(!this.hasTag("merged") && !this.hasTag("dirtied")){
			this.Tag("dirtied");
			if(getNet().isServer()){
				server_CreateBlob("molten_metal_dirty",-1,this.getPosition());
				this.server_Die();
			}
		}
	}
	
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if(blob !is null)this.server_Hit(blob, blob.getPosition(), Vec2f(), 0.5f, Hitters::fire, true);
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob ){
	if(blob.hasTag("liquid_blob") || blob.hasTag("hard_liquid_blob"))return true;
	return false;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}