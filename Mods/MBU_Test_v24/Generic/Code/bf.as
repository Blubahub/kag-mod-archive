
#include "Hitters.as";
#include "ModHitters.as";
#include "RelationshipsCommon.as";

void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightColor(SColor(11, 213, 255, 171));
	this.SetLightRadius(16.0f);
	
	this.set_s16("flight_height",16);
	this.set_s16("flight_target_height",this.getPosition().y);
	
	this.set_s16("locationX",-1);
	
	this.set_s16("life_amount", 50);
	
	this.Tag("no hands");
	this.Tag("alive");
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return true;
}

void onTick(CBlob@ this)
{
	int Height = this.get_s16("flight_height");
	int LocX = this.get_s16("locationX");
	
	CMap@ map = this.getMap();
	Vec2f surfacepos;
	if(this.getPlayer() is null){
		if(map.rayCastSolid(this.getPosition(), this.getPosition()+Vec2f(0,Height), surfacepos) || (this.getPosition()+Vec2f(0,Height)).y > getMap().tilemapheight*8){
			this.AddForce(Vec2f(0, -10));
		} else {
			this.AddForce(Vec2f(0, -1));
		}
		
		this.set_s16("flight_target_height",this.getPosition().y);
	} else {
		if(this.get_s16("flight_target_height") < this.getPosition().y){
			this.AddForce(Vec2f(0, -10));
		} else {
			this.AddForce(Vec2f(0, -2));
		}
	}
	
	if(map.rayCastSolid(this.getPosition(), this.getPosition()+Vec2f(0,-8.0f), surfacepos) || this.getPosition().y < 32){
		Height -= 4;
	}
	
	if(LocX != -1){
		if(LocX < this.getPosition().x -2){
			this.AddForce(Vec2f(-1, 0));
		} 
		if(LocX > this.getPosition().x +2){
			this.AddForce(Vec2f(1, 0));
		}
	}
	
	
	
	if(this.getPlayer() !is null){
	
		if(this.isKeyPressed(key_left)){
			
			LocX = this.getPosition().x-4;
		}
		
		if(this.isKeyPressed(key_right)){
			
			LocX = this.getPosition().x+4;
		}
		
		if(this.isKeyPressed(key_up)){
			
			if(this.get_s16("flight_target_height") > 4)this.set_s16("flight_target_height",this.getPosition().y-1);
		}
		
		if(this.isKeyPressed(key_down)){
			
			this.set_s16("flight_target_height",this.getPosition().y+6);
		}
	
		this.SetFacingLeft(this.getAimPos().x < this.getPosition().x);
	
	} else {
		this.SetFacingLeft(this.getVelocity().x < 0);
	}
	
	if(getNet().isServer()){
		if(this.getPlayer() is null){
			if(XORRandom(10) == 0){
				Height += XORRandom(31)-15;
				
				if(this.isAttached()){
					CBlob @p = this.getAttachments().getAttachedBlob("PICKUP");
					if(p !is null){
						if(checkRelationshipTotal(this,p) < 75)
						this.server_Hit(p, this.getPosition(), Vec2f(0,0), 1.0f, Hitters::life_flame, true);
					}
				}
			}

			if(XORRandom(100) == 0){
				if(XORRandom(2) == 0){
					LocX = -1;
				} else {
					LocX = this.getPosition().x+XORRandom(320)-160;
				}
				
				
			}
		}
		
		if(this.isInWater())Height += 5;
			
		if(Height < 16)Height = 16;
		
		if(Height != this.get_s16("flight_height")){
			this.set_s16("flight_height",Height);
			this.Sync("flight_height",true);
		}
		
		if(LocX != this.get_s16("locationX")){
			this.set_s16("locationX",LocX);
			this.Sync("locationX",true);
		}
		
		if(this.get_s16("life_amount") <= 0)this.server_Die();
	}
	
	if(XORRandom(3) == 0){
		CParticle @p = ParticleAnimated("lp.png", this.getPosition()+Vec2f(XORRandom(5)-2,XORRandom(5)-3), this.getVelocity()/10+Vec2f(XORRandom(801)-400,-XORRandom(100))/10000, 90.0f, 1.0f, 6, -0.1f, true);
		if(p !is null){
			p.Z = -50.0f;
		}
	}
	
	if((getGameTime()+this.getNetworkID()) % 30 == 0){
		if(this.get_s16("life_amount") > 50){
			CBlob@[] blobsInRadius;	   
			if (this.getMap().getBlobsInRadius(this.getPosition(), 160.0f, @blobsInRadius)) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ b = blobsInRadius[i];
					if(b !is null && b.hasTag("flesh")){
						if(checkRelationshipTotal(this,b) <= -25){
							CBlob @w = server_CreateBlob("wmo",this.getTeamNum(),this.getPosition());
							w.set_u16("target",b.getNetworkID());
							this.sub_s16("life_amount",1);
						}
					}
				}
			}
		}
	}
	
	
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.getShape().isStatic();
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(blob !is null){
		if(getNet().isServer()){
			if(blob.hasTag("flesh")){
				if(XORRandom(150)-100 > checkRelationshipTotal(this,blob)){
					this.server_Hit(blob, this.getPosition(), Vec2f(0,0), 1.0f, Hitters::life_flame, true);
				}
			}
		}
		
		if(blob.getName() == "humanoid"){
			blob.Tag("life_knowledge");
		}
	}
}
