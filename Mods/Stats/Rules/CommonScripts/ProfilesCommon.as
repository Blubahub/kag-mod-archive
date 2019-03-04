/* ProfilesCommon.as
 * author: Aphelion
 */

shared class PlayerProfile
{
    string profiles_path = "Profiles/";

	string username;
	int kills;
	int deaths;

	PlayerProfile() { Setup("null"); }
	
	PlayerProfile( string username ) { Setup(username); }

	void Setup( string _username )
	{
		username = _username;
		
		LoadFromFile();
	}

	void LoadFromFile()
	{
		ConfigFile profile = ConfigFile();
		profile.loadFile("../Cache/" + profiles_path + "Profile-" + username + ".cfg");

		kills = profile.read_s32("kills", 0);
		deaths = profile.read_s32("deaths", 0);
	}

	void SaveToFile()
	{
		ConfigFile profile = ConfigFile();

		profile.add_s32("kills", kills);
		profile.add_s32("deaths", deaths);
	    profile.saveFile(profiles_path + "Profile-" + username + ".cfg");
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
	
	return null;
}

PlayerProfile@ server_GetOrCreateProfile( string username )
{
	if (getNet().isClient())
	    return null;
	
	PlayerProfile@ profile = server_getProfileByName(username);

	if (profile is null)
	{
		@profile = PlayerProfile(username);

		PlayerProfile[]@ profiles = server_getProfiles();
		profiles.push_back(profile);
	}

	return profile;
}
