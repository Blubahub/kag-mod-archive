void Configure()
{
    s_soundon = 1; // sound on
    v_driver = 5;  // default video driver
    sv_gamemode = "SSBG";
	sv_gravity = 9;
    AddMod("SSBG_fix6");
	AddMod("SSBG_Music");
}

void InitializeGame()
{
    RegisterFileExtensionScript( "LoadPNGMap.as", "png" );

	if (getNet().CreateServer())
	{
	    LoadRules(  "Rules/SSBG/gamemode.cfg" );
	    LoadMapCycle( "Rules/SSBG/mapcycle.cfg" );
	    LoadNextMap();
	}

 	getNet().Connect( "localhost", sv_port );
}


