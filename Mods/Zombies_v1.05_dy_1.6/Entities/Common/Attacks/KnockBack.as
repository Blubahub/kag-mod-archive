// Knockback on hit - put before any damaging things but after any scalers
//KnockBackBoss is for boss knockbacks and edits the orginal knockback.as
//Modded by Daimyo

#include "Hitters.as"

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
    f32 x_side = 0.0f;
    f32 y_side = 0.0f;
    //if (hitterBlob !is null)
    {
        //Vec2f dif = hitterBlob.getPosition() - this.getPosition();
        if (velocity.x > 0.7) {
            x_side = 1.0f;
        }
        else if (velocity.x < -0.7) {
            x_side = -1.0f;
        }

        if (velocity.y > 0.5) {
            y_side = 1.0f;
        }
        else {
            y_side = -1.0f;
        }
    }
    f32 scale = 1.0f;

    //scale per hitter
    switch(customData)
    {
    case Hitters::fall:
    case Hitters::drown:
    case Hitters::burn:
    case Hitters::crush:
    case Hitters::spikes:
        scale = 0.0f; break;

    case Hitters::arrow:
        scale = 0.0f; break;

    default: break;
    }
    bool bossHit = false;
    int bossKnockPower = 0;
    if (hitterBlob.getName() == "BossGreenTroll")
    {
        s32 green_troll_knockback_power = getRules().get_s32("green_troll_knockback_power");
        bossHit = true;
        bossKnockPower = green_troll_knockback_power;
    }
    else if (hitterBlob.getName() == "BossMinotaurKing")
    {
        s32 boss_minotaur_knockback_power = getRules().get_s32("boss_minotaur_knockback_power");
        bossHit = true;
        bossKnockPower = boss_minotaur_knockback_power;
    }

    Vec2f f( x_side, y_side );

    if (damage > 0.125f) {
        if (bossHit)
        {
            this.AddForce( f * hitterBlob.getMass() * bossKnockPower * damage );
        }
        else
        this.AddForce( f * 40.0f * scale * Maths::Log(2.0f*(10.0f+(damage*2.0f))) );
    }

    return damage; //damage not affected
}


void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
    if (detached.getName() == "BossRedDragon" && XORRandom(2)==0)
    {
        f32 forcePowX = 0;
        f32 forcePowY = 0;
        if (XORRandom(2)==0)
        forcePowX = -1;
        else
        forcePowX = 1;
        if (XORRandom(2)==0)
        forcePowY = -1;
        else
        forcePowY = 1;
        int red_dragon_throwing_power = getRules().get_s32("red_dragon_throwing_power");
        f32 damage = this.get_f32("bite damage");
        Vec2f forcePow = Vec2f (forcePowX, forcePowY);
        Vec2f force = forcePow * detached.getMass() * damage * red_dragon_throwing_power;
        this.AddForce( force ); 
    }
}