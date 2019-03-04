void Configure()
{
    v_driver = 0;  // disable video
    s_soundon = 0; // disable audio
    sv_gamemode = "SSBG";
	sv_gravity = 9;
    AddMod("SSBG_fix3");
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
}

