/* ProfilesCommon.as
 * author: Aphelion
 */

shared class PlayerProfile
{
    string profiles_path = "Profiles/";

	string username;
	int elo;

	PlayerProfile() { }
	
	PlayerProfile( string username ) { Setup(username); }

	void Setup( string _username )
	{
		username = _username;
		
		LoadFromFile();
	}

	void LoadFromFile()
	{
		ConfigFile profile = ConfigFile();
		profile.loadFile("../Cache/ELOFUN/Profile-" + username + ".cfg");

		elo = profile.read_s32("elo", 1000);
	}

	void SaveToFile()
	{
		ConfigFile profile = ConfigFile();

		profile.add_s32("elo", elo);
	    profile.saveFile("ELOFUN/Profile-" + username + ".cfg");
	}
}

shared PlayerProfile[]@ server_getProfiles()
{
	if (getNet().isClient())
	    return null;
	
	PlayerProfile[]@ profiles;

	getRules().get("profile array", @profiles);
	return profiles;
}

shared PlayerProfile@ server_getProfile( CPlayer@ player )
{
    return server_getProfileByName(player.getUsername());
}

shared PlayerProfile@ server_getProfileByName( string username )
{
	if (getNet().isClient())
	    return null;
	
	PlayerProfile[]@ profiles = server_getProfiles();

	for(uint i = 0; i < profiles.length; i++)
	{
		if (profiles[i].username == username)
		{
			return profiles[i];
		}
	}
	
	PlayerProfile@ profile = PlayerProfile(username);
	profiles.push_back(profile);
	
	printf("Loaded profile: " + username);
	
	return server_getProfileByName(username);
}
