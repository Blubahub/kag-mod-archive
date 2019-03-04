// Lantern script

void onInit( CBlob@ this )
{
	this.addCommandID("swapcol");
    this.SetLight( true );
    this.SetLightRadius( 64.0f );
    this.SetLightColor( SColor(255, 255, 240, 171 ) );
    this.addCommandID("light on");
    this.addCommandID("light off");
    AddIconToken( "$lantern on$", "Lantern.png", Vec2f(8,8), 0 );
    AddIconToken( "$lantern off$", "Lantern.png", Vec2f(8,8), 3 );

	this.Tag("dont deactivate");
	this.Tag("fire source");

	this.getCurrentScript().runFlags |= Script::tick_inwater;
	this.getCurrentScript().tickFrequency = 24;
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	caller.CreateGenericButton( "$change_color$", Vec2f(0.0,0.0), this, this.getCommandID("swapcol"), "Swapping the color of the lantern", params );
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
	
	if (cmd == this.getCommandID("swapcol"))
	{
		if (this.getLightColor()==SColor(255,255,216,0)) { this.SetLightColor( SColor(255,200,40,40)); this.getSprite().SetAnimation( "red");}
		else if (this.getLightColor()==SColor(255,200,40,40)) { this.SetLightColor( SColor(255,40,200,40)); this.getSprite().SetAnimation( "green");}
		else if (this.getLightColor()==SColor(255,40,200,40)) { this.SetLightColor( SColor(255,40,40,200)); this.getSprite().SetAnimation( "blue");}
		else if (this.getLightColor()==SColor(255,40,40,200)) { this.SetLightColor( SColor(255,255,240,171)); this.getSprite().SetAnimation( "white");}
		else if (this.getLightColor()==SColor(255,255,240,171)) { this.SetLightColor( SColor(255,0,255,255)); this.getSprite().SetAnimation( "cyan");}
		else if (this.getLightColor()==SColor(255,0,255,255)) { this.SetLightColor( SColor(255,178,0,255)); this.getSprite().SetAnimation( "purple");}
		else if (this.getLightColor()==SColor(255,178,0,255)) { this.SetLightColor( SColor(255,255,0,200)); this.getSprite().SetAnimation( "orange");}
		else if (this.getLightColor()==SColor(255,255,0,200)) { this.SetLightColor( SColor(255,255,216,0)); this.getSprite().SetAnimation( "yellow");}
	}
	
	/* 1-red
	   2-green
	   3-blue
	   4-white
	   5-cyan
	   6-purple
	   7-pink
	   8-orange
	   9-yellow
	
/*	else if (cmd == this.getCommandID("red"))
	{
	    this.SetLightColor( SColor(255, 200, 40, 40 ) );
	}
	else if (cmd == this.getCommandID("green"))
	{
	    this.SetLightColor( SColor(255, 40, 200, 40 ) );
	}
	else if (cmd == this.getCommandID("blue"))
	{
		this.SetLightColor( SColor(255, 40, 40, 200 ) );
	}
	else if (cmd == this.getCommandID("white"))
	{
		this.SetLightColor( SColor(255, 255, 240, 171 ) );
	}*/

}
