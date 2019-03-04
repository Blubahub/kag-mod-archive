// default startup functions for autostart scripts

#include "Default/DefaultGUI.as"
#include "Default/DefaultLoaders.as"

void RunServer()
{
    if (getNet().CreateServer())
    {
		//Rules
		print( "::::Looking for MOD Rules" );
		if (LoadMapCycle( "../Mods/" + sv_gamemode + "/Rules/gamemode.cfg" )){
			LoadRules( "../Mods/" + sv_gamemode + "/Rules/gamemode.cfg" );
			print( "::::MOD Rules/MapCycle Loaded");
		}
		else if (LoadMapCycle( "../Mods/" + sv_gamemode + "/Rules/" + sv_gamemode + "/gamemode.cfg" )){
			LoadRules( "../Mods/" + sv_gamemode + "/Rules/" + sv_gamemode + "/gamemode.cfg" );
			print( "::::MOD Rules/MapCycle Loaded");
		}
		else {
			print( "::::MOD Rules not found!" );
			print( "::::Trying with DEFAULT Rules");
			LoadRules( "Rules/" + sv_gamemode + "/gamemode.cfg" );
		}
		//Mapcycle
        if (sv_mapcycle.size() > 0) {
			print( "::::Loading OVERRIDE? MapCycle");
            LoadMapCycle( sv_mapcycle );
        }
		else if(!LoadMapCycle( "../Mods/" + sv_gamemode + "/Rules/mapcycle.cfg" ) && !LoadMapCycle( "../Mods/" + sv_gamemode + "/Rules/" + sv_gamemode + "/mapcycle.cfg" )){
			print( "::::Loading DEFAULT MapCycle");
			LoadMapCycle( "Rules/" + sv_gamemode + "/mapcycle.cfg" );
        }
        LoadNextMap();
    }
}

void ConnectLocalhost()
{
    getNet().Connect( "localhost", sv_port );
}

void RunLocalhost()
{
    RunServer();
    ConnectLocalhost();
}

void LoadDefaultMenuMusic()
{
	CMixer@ mixer = getMixer();	 
	if (mixer !is null) 
	{
		mixer.ResetMixer();
		mixer.AddTrack( "Sounds/Music/KAGWorldIntroA.ogg", 0 );
		mixer.FadeInRandom(0, 0.1f );
	}
}