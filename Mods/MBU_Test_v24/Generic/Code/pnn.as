
#include "Hitters.as";
#include "ModHitters.as";
#include "Ally.as";

void onInit(CBlob@ this)
{
	this.getShape().getConsts().mapCollisions = false;
	this.getShape().SetGravityScale(0.0f);
	
	this.getSprite().SetLighting(false);
	
	this.SetLight(false);
	this.SetLightColor(SColor(255, 255, 0, 0));
	this.SetLightRadius(16.0f);
	
	this.set_Vec2f("guard",this.getPosition());
	
	this.set_u16("owner",0);
	
	this.set_f32("damage",2.0f);
	
	this.server_SetTimeToDie(20.0f);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

void onTick(CBlob@ this){
	
	f32 VelX = this.getVelocity().x;
	f32 VelY = this.getVelocity().y;
	
	Vec2f Guard = this.get_Vec2f("guard")-this.getPosition();
	
	if(Guard.Length() > 4.0f){
		Guard.Normalize();
		this.setVelocity(Guard*8.0f);
	} else {
		this.setVelocity(Vec2f(0,0));
	}
	
	if(this.getVelocity().Length() > 1.0f){
		this.setAngleDegrees(-this.getVelocity().getAngle());
		makeBloodParticle(this.getPosition()+Vec2f(XORRandom(7)-3,XORRandom(7)-3), this.getVelocity()/2);
	} else {
		CBlob @owner = getBlobByNetworkID(this.get_u16("owner"));
		if(owner !is null){
			Vec2f aim = owner.getAimPos()-this.getPosition();
			
			this.setAngleDegrees(-aim.getAngle());
		}
		
		if(XORRandom(3) == 0)makeBloodParticle(this.getPosition()+Vec2f(XORRandom(7)-3,XORRandom(7)-3), this.getVelocity());
	}
	
	
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return false;
}

void onDie(CBlob@ this){

	Vec2f Pos = this.getPosition();
	
	int distance = 320.0f;
	
	float angle = this.getAngleDegrees();

	if(getNet().isServer()){

		HitInfo@[] hitScanBlobs;	   
		
		getMap().getHitInfosFromRay(Pos, angle, distance, this, @hitScanBlobs);
		
		for (uint i = 0; i < hitScanBlobs.length; i++)
		{
			CBlob@ b = hitScanBlobs[i].blob;
			if(b !is null)
			if(canSpikeBlob(this,b)){
				this.server_Hit(b, hitScanBlobs[i].hitpos, Vec2f(0,0), this.get_f32("damage"), Hitters::pierce, false);
			}
		}
	
	}
	
	if (getNet().isClient()) {
		Vec2f ray = Vec2f(distance,0);
		ray = ray.RotateBy(angle);
		Vec2f RayHitPos = Pos+ray;
		getMap().rayCastSolidNoBlobs(Pos,Pos+ray,RayHitPos);
		
		Vec2f Dir = RayHitPos-Pos;
		int Length = Dir.getLength();
		Dir.Normalize();
		
		for(int i = 0;i < Length;i += 2){
			makeBloodParticle(Pos+Dir*f32(i)+Vec2f(XORRandom(3)-1,XORRandom(3)-1), Dir);
		}
	}
}

void makeBloodParticle(Vec2f pos, Vec2f vel)
{

	ParticleAnimated("bp.png", pos, vel, vel.getAngleDegrees(), 0.5f, 4, 0.1f, false);
}

bool canSpikeBlob(CBlob @this, CBlob @target){
	
	if(this is target)return false;
	
	if(!target.hasTag("flesh"))return false;
	
	return checkAlly(this.getTeamNum(),target.getTeamNum()) != 2;

}