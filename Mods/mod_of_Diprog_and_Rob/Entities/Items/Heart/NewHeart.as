void onInit( CBlob@ this )
{
	this.SetLight( true );
    this.SetLightRadius( 16.0f );
    this.SetLightColor( SColor(255,200,40,40 ) );
	
	this.set_string( "eat sound", "/Heart.ogg" );
	this.getCurrentScript().runFlags |= Script::remove_after_this;                                      
	this.server_SetTimeToDie( 60 );
}

