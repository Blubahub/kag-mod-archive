/* ProfilesCommon.as
 * author: Aphelion
 */
 
 shared void checkTop(CPlayer@ this) 
 {
  PlayerProfile@ profile = server_getProfile(this);

	if (profile !is null)
	{
    ConfigFile top = ConfigFile();
    top.loadFile("../Cache/Profiles/Top.cfg");
    int score = top.read_s32("rank", 0);
    print("score " + score);
    
    if(profile.rank > score) 
    {
      top.add_s32("rank", profile.rank);
      top.add_string("username", this.getUsername());
      top.saveFile("Profiles/Top.cfg");
      getRules().set_s32("best rank",profile.rank);
      getRules().set_string("best name",this.getUsername());
      getRules().Sync("best rank",true);
      getRules().Sync("best name",true);
    }
    else if ( top.read_string("username", "") == this.getUsername())
    {
      top.add_s32("rank", profile.rank);
      getRules().set_s32("best rank",profile.rank);
      top.saveFile("Profiles/Top.cfg");
    }
    else 
    {
      getRules().set_s32("best rank",score);
      getRules().set_string("best name",top.read_string("username", "bop"));
      getRules().Sync("best rank",true);
      getRules().Sync("best name",true);
    }
  }
 
 }

shared class PlayerProfile
{
    string profiles_path = "Profiles/";

	string username;
	int kills;
	int deaths;
  int rank;

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
		profile.loadFile("../Cache/" + profiles_path + "Profile-" + username + ".cfg");

		kills = profile.read_s32("kills", 0);
		deaths = profile.read_s32("deaths", 0);
    rank = profile.read_s32("rank", 0);
	}

	void SaveToFile()
	{
		ConfigFile profile = ConfigFile();

		profile.add_s32("kills", kills);
		profile.add_s32("deaths", deaths);
    profile.add_s32("rank", rank);
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
	
	PlayerProfile@ profile = PlayerProfile(username);
	profiles.push_back(profile);
	
	printf("Loaded profile: " + username);
	
	return server_getProfileByName(username);
}
