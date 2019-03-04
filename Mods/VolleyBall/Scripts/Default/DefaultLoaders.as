
void LoadDefaultMapLoaders()
{
	sv_gamemode = "VolleyBall";
	printf("############ GAMEMODE " + sv_gamemode);

	RegisterFileExtensionScript("Scripts/MapLoaders/LoadPNGMap.as", "png");
	//RegisterFileExtensionScript("Scripts/MapLoaders/GenerateFromKAGGen.as", "kaggen.cfg");
}
