// stun
#include "/Entities/Common/Attacks/Hitters.as";
#include "MakeDustParticle.as";

void onInit(CBlob@ this)
{
    this.set_u8("knocked", 0);
	this.getCurrentScript().removeIfTag = "dead";
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	if(this.hasTag("invincible")) //pass through if invince
		return damage;
	
    u8 time = 0;
    bool force = this.hasTag("force_knock");

    if (damage > 0.01f || force) //hasn't been cancelled somehow
    {
        if (force) {
            this.Untag("force_knock");
        }

        switch(customData)
        {
        case Hitters::builder:
            time = 0; break;

        case Hitters::sword:
            if (damage > 1.5f || force)
            {
				time = 15;
				if(force)
					time = 20;
					
			ParticleAnimated( "Hit2.png",
								(this.getPosition()+hitterBlob.getPosition())/2,
								Vec2f(0, 0),
								1.0f, 1.0f, 
								2, 
								0.0f, true );		
            }

            break;

        case Hitters::shield:
            time = 20; break;

        case Hitters::bomb:
            time = 60; break;

        case Hitters::arrow:
            if (damage > 1.0f) {
                time = 30;
            }

            break;
        }
    }

    if (time > 0)
    {
        u8 currentstun = this.get_u8("knocked");
        this.set_u8("knocked", Maths::Max(currentstun, Maths::Min( 60, time ) ) );
    }

//  print("KOCK!" + this.get_u8("knocked") + " dmg " + damage );
    return damage; //damage not affected
}
