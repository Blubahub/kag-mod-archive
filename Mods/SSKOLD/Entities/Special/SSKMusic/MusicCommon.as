// Game Music

const u8 SONG_BUFFER = 5;

shared class Song
{
	string fileHandle;
	string description;
	u16 lengthSeconds;

	Song(string _fileHandle, string _description, u16 _lengthSeconds)
	{
		fileHandle = _fileHandle;
		description = _description;
		lengthSeconds = _lengthSeconds;
	}
};

namespace Music
{
	const ::Song@[] songs = 
	{
		Song("CBoyarde.ogg", "'shitworld' by CBoyardee. Featured in the game 'Station 37'", 56),
		Song("MarioKart.ogg", "'Mount Must Dash' level theme from Super Mario 3D World", 102),
		Song("GreenHill.ogg", "'Green Hill Zone' theme from the Sonic Utopia OST", 205),
		Song("StrangeSunset.ogg", "Guile's theme, 'Strange Sunset', from Street Fighter EX3", 197),
		Song("Targets.ogg", "'Break the Targets' theme from Super Smash Bros. Melee", 88),
		Song("Xenoblade.ogg", "'Gaur Plains' theme from Xenoblade Chronicles", 256),
		Song("RainbowRoad.ogg", "'Rainbow Road' theme from Mario Kart 7", 121),
		Song("Hyrule.ogg", "'Hyrule Circuit' theme from Mario Kart 8", 76),
		Song("Fates.ogg", "'End of All (Land)' from Fire Emblem Fates", 264),
		Song("Smash4.ogg", "Menu theme from Super Smash Bros. 4", 132),
		Song("Ridley.ogg", "'Vs. Ridley', a Super Metroid Remix. Featured in Super Smash Bros. Brawl", 108)
	};
}
