// OVERRIDE MOD
// changes: added orb blocking

// Shield hit - make sure to set up the shield vars elsewhere

#include "ShieldCommon.as";

#include "ParticleSparks.as";

// #include "Hitters.as";
#include "Hitters2.as";


bool canBlockThisType(u8 type) // this function needs to use a tag on the hitterBlob, like ("bypass shield")
{
    return type == Hitters2::stomp ||
           type == Hitters2::builder ||
           type == Hitters2::sword ||
           type == Hitters2::shield ||
           type == Hitters2::arrow ||
           type == Hitters2::bite ||
           type == Hitters2::stab ||
           isExplosionHitter(type);
}

bool isExplosionHitter(u8 type)
{
	return type == Hitters2::bomb ||
		type == Hitters2::orb ||
		type == Hitters2::explosion;
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
    if (this.hasTag("dead") || !this.hasTag("shielded") || !canBlockThisType(customData) || this is hitterBlob )
    {
        //print("dead " + this.hasTag("dead") + "shielded " + this.hasTag("shielded") + "cant " + canBlockThisType(customData));
        return damage;
    }

    if (blockAttack(this, velocity, 0.0f))
    {
        if (isExplosionHitter(customData)) //bomb jump
        {
			Vec2f vel = this.getVelocity();
			this.setVelocity(Vec2f(0.0f,Maths::Min(0.0f, vel.y)));
 
            Vec2f bombforce = Vec2f(0.0f, ((velocity.y > 0) ? 0.7f : -1.3f) );
 
            bombforce.Normalize();
            bombforce *= 2.0f * Maths::Sqrt(damage) * this.getMass();
            bombforce.y -= 2;
 
            if (!this.isOnGround() && !this.isOnLadder())
            {
                if (this.isFacingLeft() && vel.x > 0) {
					bombforce.x += 50;
					bombforce.y -= 80;
				}
				else if (!this.isFacingLeft() && vel.x < 0) {
					bombforce.x -= 50;
					bombforce.y -= 80;
				}
            }
            else if (this.isFacingLeft() && vel.x > 0) {
                bombforce.x += 5;
            }
            else if (!this.isFacingLeft() && vel.x < 0) {
                bombforce.x -= 5;
            }
 
            this.AddForce(bombforce);
            this.Tag("dont stop til ground");
            
        }
        else if (exceedsShieldBreakForce(this,damage) && customData != Hitters2::arrow)
        {
            knockShieldDown(this);
            this.Tag("force_knock");
        }
		
		XORRandom(3) == 1 ? Sound::Play( "Ting1.ogg", worldPoint ) :
		XORRandom(3) == 1 ? Sound::Play( "Ting2.ogg", worldPoint ) :
		Sound::Play( "Ting3.ogg", worldPoint ); 
			
		const f32 vellen = velocity.Length();
        sparks (worldPoint, -velocity.Angle(), Maths::Max(vellen*0.05f, damage));
        return 0.0f;
    }

    return damage; //no block, damage goes through
}
