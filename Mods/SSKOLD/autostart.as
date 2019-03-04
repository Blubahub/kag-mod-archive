void Configure()
{
    s_soundon = 1; // sound on
    v_driver = 5;  // default video driver
    sv_gamemode = "SSK";
	sv_gravity = 9;
	sv_visiblity_scale = 6.0f;
}

void InitializeGame()
{
    RegisterFileExtensionScript( "LoadPNGMap.as", "png" );

	if (getNet().CreateServer())
	{
	    LoadRules(  "Rules/SSK/gamemode.cfg" );
	    LoadMapCycle( "Rules/SSK/mapcycle.cfg" );
	    LoadNextMap();
	}

 	getNet().Connect( "localhost", sv_port );
}


