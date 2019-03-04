// default startup functions for autostart scripts
#include "ModName.as"

void RunServer()
{
    if (getNet().CreateServer())
    {
        LoadRules(  "../Mods/" + modname + "/Rules/CTF/gamemode.cfg" );
        LoadMapCycle( "../Mods/" + modname + "/Rules/CTF/mapcycle.cfg" );
        
        LoadNextMap();
    }
}

void ConnectLocalhost()
{
    getNet().Connect("localhost", sv_port);
}

void RunLocalhost()
{
    RunServer();
    ConnectLocalhost();
}

void LoadDefaultMenuMusic()
{
    if (s_menumusic)
    {
        CMixer@ mixer = getMixer();
        if (mixer !is null)
        {
            mixer.ResetMixer();
            mixer.AddTrack("Sounds/Music/world_intro.ogg", 0);
            mixer.PlayRandom(0);
        }
    }
}
