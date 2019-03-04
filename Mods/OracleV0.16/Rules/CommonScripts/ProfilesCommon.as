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
    print("Loading file for " + username);
		ConfigFile profile = ConfigFile();
		profile.loadFile("../Cache/Oracle/Stats-" + username + ".cfg");

		elo = profile.read_s32("elo", 1000);
    
    SaveToFile();
	}
  
  int GrabChar(string charname)
	{
		ConfigFile profile = ConfigFile();
		profile.loadFile("../Cache/Oracle/Stats-" + username + ".cfg");
    print("Grabbing " + charname + " for " + username + ", " + charname + " has " + profile.read_s32(charname + "exp", 0) + " exp");
		return profile.read_s32(charname + "exp", 0);
	}
  
  string GetLeaderboardName(string charname, int place)
	{
		ConfigFile profile = ConfigFile();
		profile.loadFile("../Cache/Oracle/Leaderboards/" + charname + ".cfg");
		return profile.read_string("topname", "Nobody");
	}
  
  void CheckLeaderboard(string charname, int level)
	{
		ConfigFile profile = ConfigFile();
		profile.loadFile("../Cache/Oracle/Leaderboards/" + charname + ".cfg");
    int toplevel = profile.read_s32("toplevel", 0);
    if (toplevel < level)
    {
      profile.add_s32("toplevel", level);
      profile.add_string("topname", username);
    }
    profile.saveFile("Oracle/Leaderboards/" + charname + ".cfg");
	}
  
  int GetLeaderboardLevel(string charname, int place)
	{
		ConfigFile profile = ConfigFile();
		profile.loadFile("../Cache/Oracle/Leaderboards/" + charname + ".cfg");
		return profile.read_s32("toplevel", 0);
	}
  
  void SaveChar(string charname, s32 exp)
	{
		ConfigFile profile = ConfigFile();
    profile.loadFile("../Cache/Oracle/Stats-" + username + ".cfg");
    print("Saving " + charname + " for " + username);
		profile.add_s32(charname + "exp", exp);
	  profile.saveFile("Oracle/Stats-" + username + ".cfg");
	}

	void SaveToFile()
	{
		ConfigFile profile = ConfigFile();
    profile.loadFile("../Cache/Oracle/Stats-" + username + ".cfg");
    print("Saving file for " + username);
		profile.add_s32("elo", elo);
	  profile.saveFile("Oracle/Stats-" + username + ".cfg");
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
