//EXP system. Made by vamist

//need to sync stuff
bool backup = false;

void addEXP(CPlayer@ player, int expGained, CBlob@ blobBeingHit, float damage)
{
	if(getNet().isServer())//Checks for the server
	{
		CRules@ rules = getRules();
		if(rules.get_u32("Last backup") > (getGameTime() /30))//save all if 
		{
			for(int i = 0; i < getPlayerCount(); i++)//gets all the players connected
			{
				print("backing up " + getPlayer(i).getUsername());
				saveStuff(getPlayer(i).getUsername(), getPlayer(i).getBlob().getName());//save there stuff
			}
			backup = false; //make it so we can backup again in 30 seconds
		}
		else if(!(backup))// if false
		{
			backup = true;// set to true
			rules.set_u32("Last backup", (getGameTime() / 30) + 30);//now back up in 30 seconds
		}

		if(blobBeingHit.getPlayer() != null)//If blob is not player, don't go on
		{
			if(blobBeingHit.getHealth() - (damage/2) <= 0)//if the 'player' dies in the next hit, add exp
			{
				CRules@ rules = getRules();

				int currentEXP = rules.get_u32(player.getUsername() + " EXP");//get EXP, if there is none it will return 0
				int currentLevel = rules.get_u8(player.getUsername() + " LEVEL");

				if(currentEXP > 9)//Level up time
				{
					rules.set_u32(player.getUsername() + " EXP "+ player.getBlob().getName(), 0);
					rules.set_u8(player.getUsername() + " LEVEL" + player.getBlob().getName(), (currentLevel + 1));
				}
			}
		}
	}
}



void saveStuff(string username, string userClass)
{
	print("saving");
	CRules@ rules = getRules();
	int expirance = rules.get_u32(username + " EXP " + userClass);
	int level = rules.get_u8(username + " LEVEL" + userClass);


	string level_configstr = "../Cache/Roleplay/"+userClass+"/PlayerLevels.cfg";
	string exp_configstr   = "../Cache/Roleplay/"+userClass+"/PlayerEXP.cfg";


	if (getRules().exists("level_ctfconfig"))
	{
		level_configstr = getRules().get_string("level_ctfconfig");
	}
	if (getRules().exists("exp_ctfconfig"))
	{
		exp_configstr = getRules().get_string("exp_ctfconfig");
	}

	ConfigFile level_cfg = ConfigFile(level_configstr);
	ConfigFile exp_cfg = ConfigFile(exp_configstr);

	level_cfg.add_u32(username,level);
	exp_cfg.add_u8(username,expirance);
}

int loadStuff(string username, string userClass, bool exp)
{
	if(exp)
	{
		string exp_configstr = "../Cache/Roleplay/"+userClass+"/PlayerEXP.cfg";

		ConfigFile exp_cfg = ConfigFile(exp_configstr);

		return exp_cfg.read_u32(username);
	}
	else
	{
		string level_configstr = "../Cache/Roleplay/"+userClass+"/PlayerLevels.cfg";

		ConfigFile level_cfg = ConfigFile(level_configstr);

		return level_cfg.read_u8(username);
	}

}

void levelUserUp()
{	

}

void onPlayerLeave( CRules@ this, CPlayer@ player )
{
	saveStuff(player.getUsername(),player.getBlob().getName());
}

/*
string configstr = "Rules/CTF/ctf_vars.cfg";
	if (getRules().exists("ctfconfig"))
	{
		configstr = getRules().get_string("ctfconfig");
	}

	ConfigFile cfg = ConfigFile(configstr);

	//how long to wait for everyone to spawn in?
	s32 warmUpTimeSeconds = cfg.read_s32("warmup_time", 30);
	this.warmUpTime = (getTicksASecond() * warmUpTimeSeconds);

	//how long for the game to play out?
	s32 gameDurationMinutes = cfg.read_s32("game_time", -1);
	if (gameDurationMinutes <= 0)
	{
		this.gameDuration = 0;
		getRules().set_bool("no timer", true);
	}
	else
	{
		this.gameDuration = (getTicksASecond() * 60 * gameDurationMinutes);
	}
	//how many players have to be in for the game to start
	this.minimum_players_in_team = cfg.read_s32("minimum_players_in_team", 2);
	//whether to scramble each game or not
	this.scramble_teams = cfg.read_bool("scramble_teams", true);

	//spawn after death time
	this.spawnTime = (getTicksASecond() * cfg.read_s32("spawn_time", 15));

*/