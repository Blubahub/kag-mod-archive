// initialize script

#include "Default/DefaultStart.as"
#include "Default/DefaultLoaders.as"

//we can use this to set autoconfig stuff here
void Configure()
{
	s_soundon = 1; // sound on
	v_driver = 5;  // default video driver
	sv_gamemode = "NewCTF";
}

void InitializeGame()
{
	print("Initializing Game Script");
	LoadDefaultMapLoaders();
	LoadDefaultMenuMusic();

	//ExitToMenu(); //dont exit to menu here, we want to log in!
}
