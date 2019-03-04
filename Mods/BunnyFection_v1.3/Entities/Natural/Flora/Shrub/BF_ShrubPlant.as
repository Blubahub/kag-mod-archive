// BF_Shrub script
#include "MakeMat"
const u16 GROWTH_SPEED =  14 * 30;
const u8 GROWTH_MAX = 4;

void onInit(CBlob@ this)
{
    if (this.hasTag("instant_grow"))
    {
        this.set_u8("growth_level", GROWTH_MAX);
        this.getSprite().SetFrameIndex(GROWTH_MAX);
        this.server_SetHealth(this.getHealth() + 1);
        this.getCurrentScript().tickFrequency = 0;
    }
    else
    {
        this.set_u8("growth_level", 0 );
        this.getCurrentScript().tickFrequency = GROWTH_SPEED;
    }
    this.getSprite().SetZ(8.0f);
    this.SetFacingLeft(XORRandom(2) == 0);
	this.Tag( "flora" );
}

void onTick(CBlob@ this)
{
    u8 nextLVL = this.get_u8("growth_level") + 1;
    if (nextLVL <= GROWTH_MAX)
    {
        this.set_u8("growth_level", (nextLVL));
        this.getSprite().SetFrameIndex(nextLVL);
        this.server_SetHealth(this.getHealth() + 0.25);
    }else
        this.getCurrentScript().tickFrequency = 0;
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
    if (damage > 0.05f)
    {
        if (hitterBlob !is this)
            this.getSprite().PlaySound( "/WoodHit", Maths::Min( 1.25f, Maths::Max(0.5f, damage) ) );

		makeGibParticle( "/GenericGibs.png", this.getPosition(), getRandomVelocity( -1, (Maths::Min(Maths::Max(0.5f,damage),2.0f)*4.0f) , 270 ), 0, 4+XORRandom(4), Vec2f(8,8), 1.0f, 0, "", 0 );

		if ( getNet().isServer() )
			MakeMat( hitterBlob, this.getPosition(), "mat_wood", this.get_u8("growth_level") + 3);
    }
    return damage;
}