// BF_RootCommon script

#include "MakeMat.as";

void onInit(CBlob@ this)
{
    this.SetFacingLeft(XORRandom(2) == 0);
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
    if (damage > 0.05f)
    {
        if (hitterBlob !is this)
        {
            // nibble sound
            this.getSprite().PlaySound( "/WoodHit", Maths::Min( 1.25f, Maths::Max(0.5f, damage) ) );
        }
        MakeMat( hitterBlob, this.getPosition(), "mat_wood", 2);
        //makeGibParticle(string, Vec2f, Vec2f, int, int, Vec2f, float, int, string, int)
        //                  file,   pos,   vel, f.x, f.y,   f.s, float, int, string, int
        // make custom gibs?
        makeGibParticle( "/GenericGibs.png", this.getPosition(), getRandomVelocity( -1, (Maths::Min(Maths::Max(0.5f,damage),2.0f)*4.0f) , 270 ), 0, 4+XORRandom(4), Vec2f(8,8), 1.0f, 0, "", 0 );
    }
    return damage;
}

/*
void onDie(CBlob@ this)
{
    // custom gib particals plzzzzzzzz
}
*/