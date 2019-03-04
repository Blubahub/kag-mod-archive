
void LoadDefaultMapLoaders()
{
	printf("############ GAMEMODE " + sv_gamemode );
	if (sv_gamemode == "TTH" || sv_gamemode == "WAR") 
	{
		RegisterFileExtensionScript( "Scripts/MapLoaders/LoadWarPNG.as", "png" );
	}
    else if (sv_gamemode == "Challenge") 
    {
		RegisterFileExtensionScript( "Scripts/MapLoaders/LoadChallengePNG.as", "png" );
	}
	else if (sv_gamemode == "TDM") 
	{
		RegisterFileExtensionScript( "Scripts/MapLoaders/LoadTDMPNG.as", "png" );
	}
	else
		RegisterFileExtensionScript( "Scripts/MapLoaders/LoadPNGMap.as", "png" );
		
		
	RegisterFileExtensionScript( "Scripts/MapLoaders/GenerateFromKAGGen.as", "kaggen.cfg" );
}

