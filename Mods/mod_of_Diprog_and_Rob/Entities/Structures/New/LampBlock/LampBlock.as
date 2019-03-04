//trap block script for devious builders

#include "Hitters.as"
#include "MapFlags.as"

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed( false );
    this.getSprite().getConsts().accurateLighting = true;  
    this.Tag("place norotate");
    
    this.SetLight( true );
    this.SetLightRadius( 40.0f );
    this.SetLightColor( SColor(255, 255, 240, 171 ) );
	this.Tag("blocks water");
}
