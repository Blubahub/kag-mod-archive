// 2vuo1li.as
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
			this.PlaySound( "/ZombieDie" );
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
		if (XORRandom(512) == 0)
		{
			this.PlaySound( "/ZombieGroan" );
		}
		if (!this.isAnimation("walk"))
		{
			this.SetAnimation("walk");
		}
	}
	else
	{
		if (XORRandom(512) == 0)
		{
			this.PlaySound( "/ZombieGroan" , 0.5f);
		}
		if (!this.isAnimation("idle"))
		{
			this.SetAnimation("idle");
		}
	}
}

void onGib(CSprite@ this)
{
    if (g_kidssafe)
	{
        return;
    }
	
    CBlob@ blob = this.getBlob();
    Vec2f pos = blob.getPosition();
    Vec2f vel = blob.getVelocity();
	vel.y -= 3.0f;
    f32 hp = Maths::Min(Maths::Abs(blob.getHealth()), 2.0f) + 1.0;
	const u8 team = blob.getTeamNum();
    CParticle@ Body     = makeGibParticle( "../Mods/" + RP_NAME + "/Entities/Natural/Creatures/Undead/UndeadGibs.png", pos, vel + getRandomVelocity( 90, hp , 80 ),       1, 0, Vec2f (8,8), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Arm1     = makeGibParticle( "../Mods/" + RP_NAME + "/Entities/Natural/Creatures/Undead/UndeadGibs.png", pos, vel + getRandomVelocity( 90, hp - 0.2 , 80 ), 1, 1, Vec2f (8,8), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Arm2     = makeGibParticle( "../Mods/" + RP_NAME + "/Entities/Natural/Creatures/Undead/UndeadGibs.png", pos, vel + getRandomVelocity( 90, hp - 0.2 , 80 ), 1, 2, Vec2f (8,8), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Shield   = makeGibParticle( "../Mods/" + RP_NAME + "/Entities/Natural/Creatures/Undead/UndeadGibs.png", pos, vel + getRandomVelocity( 90, hp , 80 ),       1, 3, Vec2f (8,8), 2.0f, 0, "/BodyGibFall", team );
    CParticle@ Sword    = makeGibParticle( "../Mods/" + RP_NAME + "/Entities/Natural/Creatures/Undead/UndeadGibs.png", pos, vel + getRandomVelocity( 90, hp + 1 , 80 ),   1, 4, Vec2f (8,8), 2.0f, 0, "/BodyGibFall", team );
}
