//fall damage for all characters and fall damaged items
// apply Rules "fall vel modifier" property to change the damage velocity base

#include "Hitters.as";

const f32 BASE_FALL_VEL = 15.0f;

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1 )
{
    if (!solid) {
        return;
    }

    f32 vely = this.getOldVelocity().y;

    if (vely < 0 || Maths::Abs(normal.x) > Maths::Abs(normal.y)) { return; }

    const f32 base = getRules().exists("fall vel modifier") ? getRules().get_f32("fall vel modifier") * BASE_FALL_VEL : BASE_FALL_VEL;
    const f32 ramp = 1.2f;
    bool doknockdown = false;

    if (vely > base)
    {

        if (vely > base * ramp)
        {
            f32 damage = 0.0f;
			doknockdown = true;

            if (vely < base * Maths::Pow(ramp,1))
            {
                damage = 0.5f;
            }
            else if (vely < base * Maths::Pow(ramp,2))
            {
                damage = 1.0f;
            }
            else if (vely < base * Maths::Pow(ramp,3))
            {
                damage = 2.0f;
            }
            else if (vely < base * Maths::Pow(ramp,3))
            {
                damage = 3.0f;
            }
            else //very dead
            {
                damage = 100.0f;
            }

			damage *= 0.5f;

            // check if we aren't touching a trampoline
            CBlob@[] overlapping;

            if (this.getOverlapping( @overlapping ))
            {
                for (uint i = 0; i < overlapping.length; i++)
                {
                    CBlob@ b = overlapping[i];

                    if (b.hasTag("no falldamage"))
                    {
                        return;
                    }
                }
            }

			if (damage > 0.1f) {
				this.server_Hit( this, point1, normal, damage, Hitters::fall );
			}
			else
				doknockdown = false;
        }

        // stun on fall
        const u8 knockdown_time = 12;

        if ( doknockdown && this.exists("knocked") && this.get_u8("knocked") < knockdown_time)
        {
            Sound::Play( "/BreakBone", this.getPosition() );
            this.set_u8("knocked",knockdown_time);
        }
    }
}
