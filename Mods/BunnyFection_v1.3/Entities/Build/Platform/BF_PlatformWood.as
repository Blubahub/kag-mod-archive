// BF_PlatformWood script

#include "Hitters.as"
#include "FireCommon.as"

void onInit(CBlob@ this)
{
    this.SetFacingLeft(XORRandom(128) > 64);

    this.getSprite().getConsts().accurateLighting = true;
    this.getShape().getConsts().waterPasses = true;
    
    CShape@ shape = this.getShape();
    shape.SetOffset(Vec2f(0,-3));
    shape.AddPlatformDirection( Vec2f(0,-1), 70, false );
    shape.SetRotationsAllowed( false );
    this.Tag("place norotate");
    
    // This might need to be decreased to allow fire to properly spread
    this.set_s16( burn_duration , 300 );
    
    //transfer fire to underlying tiles
    this.Tag(spread_fire_tag);
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
    return (!blob.hasTag("LappelDuVide"));
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return false;
}