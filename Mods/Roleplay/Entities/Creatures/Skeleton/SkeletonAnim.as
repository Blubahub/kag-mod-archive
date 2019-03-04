// SkeletonAnim.as
// @author Aphelion
// If you want to use this you must ask me. I can be contacted on the KAG forums.

#include "RP_Common.as";

const string chomp_tag = "chomping";

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
	const bool inair = (!blob.isOnGround() && !blob.isOnLadder());
	
	if (blob.hasTag("dead"))
	{
		this.getCurrentScript().runFlags |= Script::remove_after_this;
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
			this.PlaySound( "/SkeletonSayDuh" , 0.5f);
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
    CParticle@ Body     = makeGibParticle( "../Mods/" + rp_name + "/Entities/Natural/Creatures/Undead/UndeadGibs.png", pos, vel + getRandomVelocity( 90, hp , 80 ),       0, 0, Vec2f (8,8), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Arm1     = makeGibParticle( "../Mods/" + rp_name + "/Entities/Natural/Creatures/Undead/UndeadGibs.png", pos, vel + getRandomVelocity( 90, hp - 0.2 , 80 ), 0, 1, Vec2f (8,8), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Arm2     = makeGibParticle( "../Mods/" + rp_name + "/Entities/Natural/Creatures/Undead/UndeadGibs.png", pos, vel + getRandomVelocity( 90, hp - 0.2 , 80 ), 0, 2, Vec2f (8,8), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Shield   = makeGibParticle( "../Mods/" + rp_name + "/Entities/Natural/Creatures/Undead/UndeadGibs.png", pos, vel + getRandomVelocity( 90, hp , 80 ),       0, 3, Vec2f (8,8), 2.0f, 0, "/BodyGibFall", team );
    CParticle@ Sword    = makeGibParticle( "../Mods/" + rp_name + "/Entities/Natural/Creatures/Undead/UndeadGibs.png", pos, vel + getRandomVelocity( 90, hp + 1 , 80 ),   0, 4, Vec2f (8,8), 2.0f, 0, "/BodyGibFall", team );
}