// 10182ih.as
// @author Aphelion
// If you want to use this you must ask me. I can be contacted on the KAG forums.

#include "1stk1df.as";

const string chomp_tag = "chomping";

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
	const bool inair = (!blob.isOnGround() && !blob.isOnLadder());
	
	if (blob.hasTag("dead"))
	{
	    if (!this.isAnimation("dead"))
		{
			this.SetAnimation("dead");
			this.PlaySound( "/ZombieKnightDie" );
		}
		return;
	}
	
	if(inair)
	{
		if (!this.isAnimation("jump"))
		{
			this.SetAnimation("jump");
		}
	}
	else if(blob.hasTag(chomp_tag))
	{
		if (!this.isAnimation("bite"))
		{
			this.SetAnimation("bite");
		}
	}
	else if (Maths::Abs(blob.getVelocity().x) > 0.1f)
	{
		if (XORRandom(256) == 0)
		{
			this.PlaySound( "/ZombieKnightGrowl" );
		}
		if (!this.isAnimation("walk"))
		{
			this.SetAnimation("walk");
		}
	}
	else
	{
		if (!this.isAnimation("idle"))
		{
			this.SetAnimation("idle");
		}
	}
}
