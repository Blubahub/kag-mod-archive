// Scripts by Diprog, sprite by RaptorAnton. If you want to copy/change it and upload to your server ask creators of this file. You can find them at KAG forum.

void onInit( CBlob@ this )
{
    this.SetLight( true );
    this.SetLightRadius( 84.0f );
    this.SetLightColor( SColor(255, 255, 240, 171 ) );
    this.addCommandID("light on");
    this.addCommandID("light off");
    AddIconToken( "$lantern on$", "Lantern.png", Vec2f(8,12), 1 );
    AddIconToken( "$lantern off$", "Lantern.png", Vec2f(8,12), 0 );

	this.Tag("dont deactivate");
	this.Tag("fire source");

	this.getCurrentScript().runFlags |= Script::tick_inwater;
	this.getCurrentScript().tickFrequency = 24;
}

void onTick( CBlob@ this )
{
    if (this.isLight() && this.isInWater())
    {
        Light( this, false );
    }
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

