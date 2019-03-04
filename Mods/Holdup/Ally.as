
enum Team{
	Enemy,
	Neutral,
	Ally
}

int checkAlly(int Team1, int Team2){

	if(Team1 == Team2)return 2; //Allies

	int status = -1; //start unknown
	
	CRules @rules = getRules();
	
	if(rules.exists("alliance:"+Team1+":"+Team2)){
		int check = rules.get_u8("alliance:"+Team1+":"+Team2);
		if(check < status || status == -1)status = check;
	} else {
		status = 0;
	}

	if(rules.exists("alliance:"+Team2+":"+Team1)){
		int check = rules.get_u8("alliance:"+Team2+":"+Team1);
		if(check < status || status == -1)status = check;
	} else {
		status = 0;
	}
	
	if(status == -1)status = 0; //Enemies if unknown
	
	return status;
}

int checkAllyOneWay(int Team1, int Team2){

	if(Team1 == Team2)return 2;

	int status = 0;
	
	CRules @rules = getRules();
	
	if(rules.exists("alliance:"+Team1+":"+Team2)){
		status = rules.get_u8("alliance:"+Team1+":"+Team2);
	}
	
	return status;
}

void setAlly(int myTeam, int AllyTeam, int Status){
	CRules @rules = getRules();
	rules.set_u8("alliance:"+myTeam+":"+AllyTeam, Status);
	if(getNet().isServer())rules.Sync("alliance:"+myTeam+":"+AllyTeam, true);
}