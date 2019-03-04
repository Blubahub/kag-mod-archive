
#include "Hitters.as";

void onInit(CBlob @this){

	this.set_u16("stuckto",0);

}

void onTick(CBlob @this){
	
	CBlob @stuck = getBlobByNetworkID(this.get_u16("stuckto"));
	
	if(stuck !is null){
		this.setPosition(stuck.getPosition());
		this.setVelocity(Vec2f(0,0));
	}

	if(this.hasTag("stuck"))this.setVelocity(Vec2f(0,-0.44));
	
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid ){

	if(this.hasTag("activated") || this.getName() == "stickybomb"){
		if(blob !is null){
			if(solid || (blob.hasTag("player") && blob.getTeamNum() != this.getTeamNum())){
				this.set_u16("stuckto",blob.getNetworkID());
			}
		}
		if(solid){
			this.Tag("stuck");
		
			this.getShape().SetGravityScale(-0.1);
			this.setVelocity(Vec2f(0,0));
		}
	}
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob ){

	if(getBlobByNetworkID(this.get_u16("stuckto")) !is null)return false;
	return !this.hasTag("stuck");

}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob ){

	if(getBlobByNetworkID(this.get_u16("stuckto")) !is null)return false;
	
	if(blob.hasTag("flesh") && blob.getTeamNum() != this.getTeamNum())return true;
	if(blob.getShape().isStatic())return true;
	if(blob.getTeamNum() != this.getTeamNum())return true;

	return false;
}

void onDie(CBlob@ this){
	if(this.getName() == "stickykeg"){
		CBlob @stuck = getBlobByNetworkID(this.get_u16("stuckto"));
		
		if(stuck !is null){
			this.server_Hit(stuck, this.getPosition(), Vec2f(0,0), 10.0f, Hitters::keg, true);
		}
	}
	if(this.getName() == "stickybomb"){
		CBlob @stuck = getBlobByNetworkID(this.get_u16("stuckto"));
		
		if(stuck !is null){
			this.server_Hit(stuck, this.getPosition(), Vec2f(0,0), 3.0f, Hitters::bomb, true);
		}
	}
}