#include "Hitters.as";
#include "Knocked.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "Help.as";
#include "Requirements.as";
#include "FireParticle.as";

#include "DestroyNature.as";
#include "ProceduralGriefing.as";

void onInit(CBlob@ this)
{
	this.Tag("player");
	
	this.getShape().getConsts().mapCollisions = false;
	
	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;

	this.set_Vec2f("inventory offset", Vec2f(0.0f, -152.0f));
	
	this.Tag("spirit_view");
	
}

void onTick(CBlob@ this)
{
	if(this.isInInventory())
		return;

	const bool ismyplayer = this.isMyPlayer();
	
	if(this.getPosition().y > getMap().tilemapheight*8-32)this.AddForce(Vec2f(0,-200));
	
	CMap@ map = getMap();
	if(!map.isTileBackground(map.getTile(this.getPosition())))if(XORRandom(30) == 0){
		this.server_Heal(0.5);
	}
	
	if(this.hasTag("summoned")){
		if(getNet().isServer()){
			this.Sync("summoned",true);
		}
	}
	
	if(this.getHealth() <= 0 && this.hasTag("summoned") && !this.hasTag("destroyed")){
		DestroyNature();
		CreatePit(this.getPosition());
		this.Tag("destroyed");
	}
	if(getNet().isServer())
	if(this.getHealth() <= 0 && this.hasTag("summoned")){
		DestroyNature();
		server_CreateBlob("naturesgrave", this.getTeamNum(), this.getPosition());
		CreatePit(this.getPosition());
	}
	
	if(this.isKeyPressed(key_action1)){
		CBlob@[] blobsInRadius;
		if (this.getMap().getBlobsInRadius(this.getAimPos(), 32.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b !is null){
					if(b !is this && b !is this && !b.hasTag("element")){
						Vec2f dir = this.getAimPos()-b.getPosition();
						dir.Normalize();
						b.setVelocity(dir*0.50+b.getVelocity());
					}
				}
			}
		}
	}
}


void onDie(CBlob@ this){
	print("test");
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return (this.hasTag("summoned") && blob.hasTag("projectile"));
}