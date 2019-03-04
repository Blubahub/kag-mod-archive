#include "Ally.as";

CBlob@ getAimAttackTarget(CBlob@ this){
	Vec2f Aim = this.getAimPos();
	float Distance = Maths::Sqrt(Maths::Pow(Aim.x-this.getPosition().x,2)+Maths::Pow(Aim.y-this.getPosition().y,2));
	
	if(Distance <= 32.0f){
		CBlob@[] blobs;
		getMap().getBlobsAtPosition(Aim, @blobs);
		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ b = blobs[i];
			if(b !is this)
			if(!b.hasTag("ignore_damage") && !b.hasTag("invincible"))
			if(checkAlly(this.getTeamNum(),b.getTeamNum()) == Team::Enemy || b.getName() != "humanoid"){
				
				if(!getMap().rayCastSolidNoBlobs(this.getPosition(),Aim)
				|| !getMap().rayCastSolidNoBlobs(this.getPosition(),Aim+Vec2f(0,4))
				|| !getMap().rayCastSolidNoBlobs(this.getPosition(),Aim-Vec2f(0,4)))return b;
			}
		}
	}
	
	return null;
}