//EXP system. Made by vamist


void addEXP(CPlayer@ player, int expGained, CBlob@ blobBeingHit, float damage)
{
	if(getNet().isServer())//Checks for the server
	{
		CRules@ rules = getRules();

		if(blobBeingHit.getPlayer() != null)//If blob is not player, don't go on
		{
			if(blobBeingHit.getHealth() - (damage/2) <= 0 && !blobBeingHit.hasTag("dead"))//if the 'player' dies in the next hit, add exp
			{
				print("killed blob");
				CRules@ rules    = getRules();
				int currentEXP   = getStuff(player.getUsername(),player.getBlob().getName(),true);//get EXP, if there is none it will return 0
				int currentLevel = getStuff(player.getUsername(),player.getBlob().getName(),false);
				int levelEXP 	 = 300;//EXP needed to level up
				levelEXP += 20 +(currentLevel * 100); // for each level, + 100
				
				if(currentEXP > levelEXP)//if player is ready to level up
				{
					currentEXP -= levelEXP; //take away exp gained
					currentLevel += 1; //plus 1 level
				}

				rules.set_u32(player.getUsername() + " EXP "   + player.getBlob().getName(), (currentEXP + expGained)); //Set the u32 exp and level
				rules.set_u16(player.getUsername() + " LEVEL " + player.getBlob().getName(), (currentLevel));

				rules.SyncToPlayer(player.getUsername()  + " EXP "   + player.getBlob().getName(), getPlayerByUsername(player.getUsername())); //sync it
				rules.SyncToPlayer(player.getUsername()  + " LEVEL " + player.getBlob().getName(), getPlayerByUsername(player.getUsername()));

			}

			if(rules.get_u32("Last backup") != 0)
			{
				print("backing up");
				if(rules.get_u32("Last backup") <= (getGameTime() / 30))//save all if 
				{
					saveAll();
					rules.set_u32("Last backup", ((getGameTime() / 30) + 30));//now back up in 30 seconds
				}
			}
			else
			{
				rules.set_u32("Last backup", ((getGameTime() / 30) + 30));
			}
		}
	}
}

//EXP functions
void saveAll()
{
	for(int i = 0; i < getPlayerCount(); i++)//gets all the players connected
	{
		saveStuff(getPlayer(i).getUsername(), getPlayer(i).getBlob().getName());//save there stuff
	}
}

void saveStuff(string username, string userClass)
{
	print("saving");
	CRules@ rules = getRules();
	int expirance = rules.get_u32(username + " EXP "   + userClass);
	int level 	  = rules.get_u16(username + " LEVEL " + userClass);

	string user_configstr   = "../Cache/Roleplay/users/"+username+".cfg";

	ConfigFile user_cfg = ConfigFile(user_configstr);
	user_cfg.add_u32(userClass+"_Exp", expirance);
	user_cfg.add_u16(userClass+"_Level",level);

	user_cfg.saveFile("Roleplay/users/"+username+".cfg");

	print("done saving");
}

int getStuff(string username, string userClass, bool exp)
{
	CRules@ rules = getRules();
	if(exp)
		return rules.get_u32(username + " EXP "   + userClass);
	else
		return rules.get_u16(username + " LEVEL " + userClass);
}

void loadAll(string username, string userClass)
{
	print("loadall");
	CRules@ rules = getRules();
	if(!rules.exists(username + " EXP " + userClass))
	{
		print("does not exist");
		string user_configstr   = "../Cache/Roleplay/users/"+username+".cfg";


		ConfigFile user_cfg;

		if(user_cfg.loadFile(user_configstr))
		{

			ConfigFile user_cfg = ConfigFile(user_configstr);
			rules.set_u32(username + " EXP "+ userClass, user_cfg.read_u32(userClass + "_Exp"));
			rules.set_u16(username + " LEVEL "+ userClass, user_cfg.read_u16(userClass + "_Level"));
			rules.SyncToPlayer(username + " EXP "+ userClass, getPlayerByUsername(username));
			rules.SyncToPlayer(username + " LEVEL "+ userClass, getPlayerByUsername(username));
		}
		else
		{
			saveStuff(username,userClass);
		}
		/*
		ConfigFile user_cfg = ConfigFile(user_configstr);

		if(user_cfg.exists(username+"_Exp"))
		{
			print("exists");
			rules.set_u32(username + " EXP "+ userClass, user_cfg.read_u32(username + "_Exp"));
			rules.set_u16(username + " LEVEL "+ userClass, user_cfg.read_u16(username + "_Level"));
			rules.SyncToPlayer(username + " EXP "+ userClass, getPlayerByUsername(username));
			rules.SyncToPlayer(username + " LEVEL "+ userClass, getPlayerByUsername(username));
		}*/
	}
}

int loadStuff(string username, string userClass, bool exp)
{
	print("loadstuff");

	string user_configstr   = "../Cache/Roleplay/users/"+username+".cfg";

	ConfigFile user_cfg = ConfigFile(user_configstr);

	if(exp)
	{
		return user_cfg.read_u32(username+"_Exp");
	}
	else
	{
		return user_cfg.read_u16(username+"_Level");
	}

}

//Level up functions

void saveLevelSpent(string username, string userClass, int sqaureNum, bool unlocked)
{
	print("saveLevelSpent");

	string user_configstr    = "../Cache/Roleplay/users/"+username+".cfg";

	ConfigFile levelup_cfg   = ConfigFile(user_configstr);

	levelup_cfg.add_bool(userClass+"_Sqaure_"+sqaureNum, unlocked);

	levelup_cfg.saveFile("Roleplay/users/"+username+".cfg");

}

/*
void saveLevelSpent(string username, string userClass, int sqaureNum, bool unlocked)
{
	print("saveLevelSpent");

	string user_configstr    = "../Cache/Roleplay/users/"+username+".cfg";

	ConfigFile levelup_cfg   = ConfigFile(user_configstr);

	levelup_cfg.add_bool(userClass+"_Sqaure_"+sqaureNum, unlocked);

	levelup_cfg.saveFile("Roleplay/users/"+username+".cfg");

}*/

bool isSquareUnlockedFromFile(string username, string userClass, int sqaureNum)
{
	string user_configstr    = "../Cache/Roleplay/users/"+username+".cfg";

	ConfigFile levelup_cfg   = ConfigFile(user_configstr);

	return levelup_cfg.read_bool(userClass+"_Sqaure_"+sqaureNum);
}

bool isSquareUnlocked(CPlayer@ player, int sqaureNum)
{
	return player.get_bool(player.getBlob().getName() + "_Square_" + sqaureNum);
}


void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	if(player.getBlob() !is null)
		saveStuff(player.getUsername(),player.getBlob().getName());
}






///

// 1 2 3 4
// 1 + 2 = 3
// 1 + 3 = 4
// 1 + 4 = 5
// 2 + 3 = 5
// 2 + 4 = 6
// 3 + 4 = 7

//each section of the tree has 4 parts
