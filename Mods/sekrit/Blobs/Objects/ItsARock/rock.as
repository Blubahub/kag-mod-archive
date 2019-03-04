//BallThatDoesDamage
#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(true);
}


void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ attachedPoint)
{
	
}

void onTick(CBlob@ this)
{
	
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	//special logic colliding with players
	if (blob.hasTag("player"))
	{
		const u8 hitter = this.get_u8("custom_hitter");

		//all water bombs collide with enemies
		if (hitter == Hitters::water)
			return blob.getTeamNum() != this.getTeamNum();

		//collide with shielded enemies
		return (blob.getTeamNum() != this.getTeamNum() && blob.hasTag("shielded"));
	}

	string name = blob.getName();

	if (name == "fishy" || name == "food" || name == "steak" || name == "grain" || name == "heart")
	{
		return false;
	}

	return true;
}


void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(this is null || blob is null || blob.getTeamNum() == this.getTeamNum() || !blob.hasTag("player"))
		return;
	if(blob.getName() == "builder0" || blob.getName() == "builder1" || blob.getName() == "builder2")
	{
		this.server_Hit(blob, this.getPosition(), this.getVelocity(), 1.0f, Hitters::water_stun);
	}
	else if(blob.getName() == "knight0" || blob.getName() == "archer")
	{
		this.server_Hit(blob, this.getPosition(), this.getVelocity(), 1.0f, Hitters::sword);
	}
	this.server_Die();
}
