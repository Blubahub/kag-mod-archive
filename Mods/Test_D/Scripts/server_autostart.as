void Configure()
{
    v_driver = 0;  // disable video
    s_soundon = 0; // disable audio 
	if (sv_gamemode == "Run")
		sv_gamemode = "Campaign";  
}

void InitializeGame()
{
    RegisterFileExtensionScript("Scripts/MapLoaders/PNGLoader.as", "png");
    RegisterFileExtensionScript("Scripts/MapLoaders/TWMapGenerator.as", "twgen.cfg");

    if (getNet().CreateServer())
    {
        LoadRules(  "Rules/"+sv_gamemode+"/gamemode.cfg" );
        setGameState( GameState::game );
    }
}
