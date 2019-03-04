
#include "RunnerCommon.as";

void onInit(CBlob@ this)
{
	this.set_f32("gib health", -3.0f);
	this.Tag("flesh");
	this.Tag("player");
	
	this.Tag("isfacingleft");
}

void onTick(CBlob@ this)
{

	if (this.hasTag("dead"))
		return;

	
	if(XORRandom(100) == 0){
		if(XORRandom(2) == 0)this.Tag("isfacingleft");
		else this.Untag("isfacingleft");
	}
	
	RunnerMoveVars@ moveVars;
	if(this.get("moveVars", @moveVars))
	{
		if(this.get_u8("type") == 0 || this.get_u8("type") == 1){
			moveVars.walkFactor = 0.5f;
			moveVars.jumpFactor = 0.5f;
		}
		if(this.get_u8("type") == 2 || this.get_u8("type") == 3){
			moveVars.walkFactor = 0.25f;
			moveVars.jumpFactor = 0.25f;
		}
	}
	
	if(this.hasTag("isfacingleft"))this.setAimPos(this.getPosition() + Vec2f(-16,0));
	else this.setAimPos(this.getPosition() + Vec2f(16,0));
	
	CBlob@[] blobsInRadius;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), 80.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b !is null){
				if(b.getTeamNum() == 0){
					if(b.hasTag("player") && !b.hasTag("dead") && b.getName() != "villager"){
						this.setAimPos(b.getPosition());
					}
				}
			}
		}
	}
		
	if (!getNet().isServer()) return; //---------------------SERVER ONLY
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}



