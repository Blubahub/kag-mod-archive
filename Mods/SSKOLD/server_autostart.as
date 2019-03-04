void Configure()
{
    v_driver = 0;  // disable video
    s_soundon = 0; // disable audio
    sv_gamemode = "SSK";
	sv_gravity = 9;
	sv_visiblity_scale = 6.0f;
    AddMod("SSK");
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
}

