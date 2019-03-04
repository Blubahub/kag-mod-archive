void Configure()
{
	s_soundon = 1; // sound on
	v_driver = 5;  // default video driver
	v_postprocess = true;
	sv_max_localplayers = 4;

	//first time setup
	if (sv_gamemode == "" || sv_gamemode == "CTF")
		sv_gamemode = "Main";
	if (sv_gamemode == "Run")
		sv_gamemode = "Campaign";
}

void InitializeGame()
{
	ConsoleColour::ERROR = SColor(0xffff501e);
	ConsoleColour::WARNING = SColor(0xffffbb22);
	ConsoleColour::GENERIC = SColor(0xffa8a8a8);
	ConsoleColour::INFO = SColor(0xffa8a8a8);
	ConsoleColour::CRAZY = SColor(0xffbb37ff);
	ConsoleColour::SCRIPT = SColor(0xffa8a8a8);
	ConsoleColour::GAME = SColor(0xffa8a8a8);
	ConsoleColour::CHATSPEC = SColor(0xffa8a8a8);
	ConsoleColour::RCON = SColor(0xff9f482f);

	RegisterFileExtensionScript("Scripts/MapLoaders/PNGLoader.as", "png");
	RegisterFileExtensionScript("Scripts/MapLoaders/TWMapGenerator.as", "twgen.cfg");
	// shaders
	Driver@ driver = getDriver();

	driver.AddShader("palette", 1001.0f);
	driver.SetShader("palette", true);
	driver.SetShaderFloat("palette", "res_x", getScreenWidth());
	driver.SetShaderFloat("palette", "res_y", getScreenHeight());
	driver.SetShaderFloat("palette", "scroll_x", 0);
	driver.SetShaderFloat("palette", "tick", 0);
	driver.SetShaderExtraTexture("palette", "Sprites/Palettes/default_palette.png");

	driver.AddShader("drunk", 1100.1f);
	driver.SetShader("drunk", true);
	driver.SetShaderFloat("drunk", "res_x", getScreenWidth());
	driver.SetShaderFloat("drunk", "res_y", getScreenHeight());
	driver.SetShaderFloat("drunk", "scroll_x", 0);
	driver.SetShaderFloat("drunk", "time", 0);
	driver.SetShaderFloat("drunk", "amount", 0);
	driver.SetShaderTextureFilter("drunk", true);
}

void ShowMenu()
{
	printf("Running MAIN");
	sv_max_localplayers = 1;
	CNet@ net = getNet();
    setGameState(GameState::game);
	net.SafeConnect("localhost:" + sv_port, "Rules/" + sv_gamemode + "/gamemode.cfg");
}
