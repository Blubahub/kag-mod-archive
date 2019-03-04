// Lantern script
//#include "Help.as";

void onInit( CBlob@ this )
{
    this.SetLight( true );
    this.SetLightRadius( 300.0f );
    this.SetLightColor( SColor(255, 255, 240, 200 ) );
    this.addCommandID("light on");
    this.addCommandID("light off");
    AddIconToken( "$waterlantern on$", "WaterLantern.png", Vec2f(8,8), 0 );
    AddIconToken( "$waterlantern off$", "WaterLantern.png", Vec2f(8,8), 3 );

	this.Tag("dont deactivate");
	this.Tag("fire source");

	//SetHelp( this, "help activate", "", "$waterlantern$ On/Off \n\n         $KEY_SPACE$", "" ); 
	//SetHelp( this, "help pickup", "", "$waterlantern$ Pick up \n\n         $KEY_C$" ); 

	this.getCurrentScript().runFlags |= Script::tick_inwater;
	this.getCurrentScript().tickFrequency = 24;
}

void onTick( CBlob@ this )
{
    // if (this.isLight() && this.isInWater())
    // {
        // Light( this, false );
    // }
}

void Light( CBlob@ this, bool on )
{
    if (!on)
    {
        this.SetLight( false );
        this.getSprite().SetAnimation( "nofire");
    }
    else
    {
        this.SetLight( true );
        this.getSprite().SetAnimation( "fire");
    }
	this.getSprite().PlaySound( "SparkleShort.ogg" );
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("activate"))
	{
		Light( this, !this.isLight() );		
	}

}

