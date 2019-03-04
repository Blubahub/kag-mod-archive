#include "Hitters.as";
#include "ModHitters.as";
#include "ep.as";
#include "Ally.as";
#include "eleven.as";

void onInit(CBlob@ this)
{
	this.SetMapEdgeFlags(CBlob::map_collide_none);
	this.getShape().getConsts().bullet = true;
	
	this.SetLight(true);
	this.SetLightRadius(32.0f);
	this.SetLightColor(SColor(255, 0, 255, 255));
	
	this.getShape().SetGravityScale(0.0f);
	//this.getShape().getConsts().mapCollisions = false;
	this.set_u16("target",0);
	
	for(int i = 0; i < 5; i++)lp(this.getPosition()+Vec2f(XORRandom(7)-3,XORRandom(7)-3), false, this.getVelocity()+Vec2f(XORRandom(3)-1,XORRandom(3)-1)*0.4);
}

void onTick(CBlob@ this)
{
	this.AddForce(Vec2f(XORRandom(7)-3,XORRandom(7)-3)*0.05);
	
	if(getNet().isServer())if(!checkEInterface(this,this.getPosition(),8,1))this.server_Die();
	
	if(getNet().isClient()){
		CSprite @sprite = this.getSprite();
		if(sprite !is null){
			sprite.SetZ(1500.0f);
		}
		
		if(XORRandom(6) == 0)lp(this.getPosition()+Vec2f(XORRandom(7)-3,XORRandom(7)-3), false, this.getVelocity()+Vec2f(XORRandom(3)-1,XORRandom(3)-1)*0.4);
	}

	CBlob @closest = getBlobByNetworkID(this.get_u16("target"));
	
	if(closest is null){
		int Distance = 320;
		
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 320.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b.hasTag("flesh") && !b.hasTag("dead") && checkAlly(this.getTeamNum(),b.getTeamNum()) != Team::Ally)
				{
					if(b.getDistanceTo(this) < Distance){
						Distance = b.getDistanceTo(this);
						@closest = b;
					}
					
				}
			}
		}
	}
	
	if(closest !is null){
		Vec2f Vel = closest.getPosition()-this.getPosition();
		Vel.Normalize();
		this.AddForce(Vel*0.05);
		if(Vel.x > 0)this.SetFacingLeft(false);
		else this.SetFacingLeft(true);
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return (blob.hasTag("flesh") && !blob.hasTag("dead") && checkAlly(this.getTeamNum(),blob.getTeamNum()) != Team::Ally);
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(blob is null)return;
	
	if(blob.hasTag("flesh") && !blob.hasTag("dead") && ((checkAlly(this.getTeamNum(),blob.getTeamNum()) != Team::Ally && getBlobByNetworkID(this.get_u16("target")) is null) || blob.getNetworkID() == this.get_u16("target")))
	{
		this.server_Hit(blob, blob.getPosition(), Vec2f(0,0), 1.0f, Hitters::life_flame, true);
		blob.add_s16("life_amount",1);
		for(int i = 0; i < 5; i++)
		lp(this.getPosition()+Vec2f(XORRandom(7)-3,XORRandom(7)-3), false, Vec2f(XORRandom(3)-1,XORRandom(3)-1)*0.4);
		this.server_Die();
	}	
}