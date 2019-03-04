//simple script to check for seclev features
//mainly used in commands, external for future use ;3
//author: JaytleBee

namespace SRSecurity
{
	enum SRRank//using this you can do cool stuff like getRank("Redshadow6") > Normal
	{
		Normal,
		Moderator,
		Admin,
		Owner,
	};

	//key:command, value:minimum seclev required for using it
  	dictionary commandSeclevs = {	
  		{"killme"				, Normal},
		{"bot"					, Admin},
		{"debug"				, Admin},
		{"stones"				, Normal},
		{"arrows"				, Normal},
		{"bombs"				, Normal},
		{"spawnwater"			, Normal},
		{"crate"				, Normal},
		{"mat"					, Normal},
		{"invisible"			, Normal},
		{"curse"				, Normal},
		{"tp"					, Normal},
		{"coins"				, Normal},
		{"kill"					, Normal},
		{"plague"				, Normal},
		{"rain"					, Admin},
		{"crate"				, Normal},
		{"team"					, Normal},
		{"scroll"				, Moderator},
		{"tree"					, Normal},
		{"btree"				, Normal},
		// {""			,}
  	};

  	dictionary aliases = {
  		{"!stones"				, "!mat_stone"}
  		{"!stones"				, "!mat_stone"}
  		{"!stones"				, "!mat_stone"}
  		{"!stones"				, "!mat_stone"}
  	};

	bool hasRank(CPlayer@ player, string rank)
	{
		if (player is null)
			return false;
		return getSecurity().checkAccess_Feature(player, "SandboxReborn_"+rank);
	}

	//gets the SRSecurity::SRank for player
	//returns null if player is null
	SRRank getRank(CPlayer@ player)
	{
		if (player is null)
			return null;

		if (hasRank(player, "Owner"))
			return Owner;
		else if (hasRank(player, "Admin"))
			return Admin;
		else if (hasRank(player, "Moderator"))
			return Moderator;
		else
			return Normal;
	}

	bool mayUseCommand(CPlayer@ player, string command)
	{
		SRRank rank = getRank(player);
		SRRank requiredRank = commandSeclevs["!" + command.split(" ")[0]];

		if (rank is null || requiredRank is null)
			return false;

		return rank >= requiredRank;
	}
}