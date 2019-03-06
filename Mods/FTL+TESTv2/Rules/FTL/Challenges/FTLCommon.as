// common functions for Challenge maps

string g_statsFile;
const string stats_tag = "challenge_stats";
bool syncedStats = false;
// end global vars

// Hook for map loader
void LoadMap()	// this isn't run on client!
{
	ChallengeCommonLoad();
}

//

void ChallengeCommonLoad()
{
	CRules@ rules = getRules();
	if (rules is null)
	{
		error("Something went wrong - Rules is null");
	}

	SetConfig(rules);
	RegisterFileExtensionScript("Scripts/MapLoaders/LoadFTLPNG.as", "png"); // to add checkpoint marker
	LoadMap(getMapInParenthesis());
}

void SetConfig(CRules@ rules)
{
	syncedStats = false;
	rules.set_string("rulesconfig", "test");
	rules.set_string("rulesconfig", CFileMatcher("/" + getMapName() + ".cfg").getFirst());
}

void AddRulesScript(CRules@ rules)
{
	CFileMatcher@ files = CFileMatcher("Challenge_");
	//files.printMatches();
	while (files.iterating())
	{
		const string filename = files.getCurrent();
		if (rules.RemoveScript(filename))
		{
			printf("Removing rules script " + filename);
		}
	}

	printf("Adding rules script: " + getCurrentScriptName());
	rules.AddScript(getCurrentScriptName());

	rules.set_bool("no research", true);
}

// put in onInit( CRules@ this ) or onInit( CMap@ this )
void SetIntroduction(CRules@ this, const string &in shortName)
{
	this.set_string("short name", shortName);
	this.set_string(stats_tag, "");
	this.set_s32("restart_rules_after_game_time", 30 * 7.0f); // no better place?
}

void DefaultWin(CRules@ this, const string endGameMsg = "The Captives won!")
{
	this.SetTeamWon(0);
	this.SetCurrentState(GAME_OVER);
	this.SetGlobalMessage(endGameMsg);
	sv_mapautocycle = true;
}

string getMapName()
{
	return getFilenameWithoutExtension(getFilenameWithoutPath(getMapInParenthesis()));
}