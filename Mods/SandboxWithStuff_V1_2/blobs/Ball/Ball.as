//BallThatDoesDamage
#include "Hitters.as";
#include "ballparticle.as";
#include "MakeTestParticles.as";

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed( true );
  	this.server_setTeamNum(5);
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return true;
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ attachedPoint)
{
	if(this.getTeamNum() == 5)
	{
		this.server_setTeamNum(attached.getTeamNum());
	}
	if(attached.getTeamNum() == 0)
	{
		this.server_setTeamNum(0);
	}
	if(attached.getTeamNum()== 1)
	{
		this.server_setTeamNum(1);
	}
}

void onTick(CBlob@ this)
{
	Vec2f pos = this.getPosition();
	float rot = this.getAngleDegrees();
	Vec2f vel = this.getVelocity();
	if(vel.x > 0.5f || vel.y > 0.5f || vel.x < -0.5f || vel.y < -0.5f)
	{
		if(this.getTeamNum() == 0)
		{
			BallTrailBlue(pos, rot);
		}
		if(this.getTeamNum() == 1)
		{
			BallTrailRed(pos, rot);
		}
	}
}
