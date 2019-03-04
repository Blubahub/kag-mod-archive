/*
Do you really have to read this file?

That's kinda boring :/






















































*/

string primaryNames(int i){

	switch(i){
		case 0: return "Nothing";
		
		case 1: return "Fireball";
		case 2: return "Geyser";
		case 3: return "Boulder Toss";
		case 4: return "Push";
		
		case 5: return "Bite";
		case 6: return "Root";
		case 7: return "Blink";
		case 8: return "Slow";
		
		case 9: return "Death-Guard";
		case 10: return "Revive";
		case 11: return "Mass Heal";
		
		case 12: return "Darkness Shroud";
		case 13: return "Death Bolt";
		case 14: return "Plague";
	}

	return "";
}

string secondaryNames(int i){

	switch(i){
		case 0: return "Nothing";
		
		case 1: return "Living Flame";
		case 2: return "Water Bubble";
		case 3: return "Earthen Shield";
		case 4: return "Air Jump";
		
		case 5: return "Heal";
		case 6: return "Regenerate";
		case 7: return "Return";
		case 8: return "Haste";
		
		case 9: return "Light Orb";
		case 10: return "Barrier";
		case 11: return "Cleanse";
		
		case 12: return "Invisibility";
		case 13: return "Self-Sacrifice";
		case 14: return "Self-Plague";
	}

	return "";
}

int secondaryCosts(int i){

	switch(i){
		case 3: return 1;
		case 4: return 1;
		
		case 5: return 1;
		case 6: return 1;
		case 8: return 1;
		
		case 10: return 1;
		case 11: return 2;
		
		case 12: return 1;
		case 13: return -2;
	}

	return 0;
}

string getRuneFriendlyName(int id)
{
	switch(id){
	case 0: return "Touch";
	case 1: return "Sight";
	case 2: return "Witness";
	case 3: return "Curse";
	case 4: return "Fire";
	case 5: return "Water";
	case 6: return "Earth";
	case 7: return "Air";
	case 8: return "Devour";
	case 9: return "Growth";
	case 10: return "Space";
	case 11: return "Time";
	case 12: return "Light";
	case 13: return "Life";
	case 14: return "Restore";
	case 15: return "Order";
	case 16: return "Dark";
	case 17: return "Death";
	case 18: return "Decay";
	case 19: return "Chaos";
	}
	return "";
}

string getRuneLetter(int id)
{
	switch(id){
	case 0: return "a";
	case 1: return "b";
	case 2: return "c";
	case 3: return "d";
	case 4: return "e";
	case 5: return "f";
	case 6: return "g";
	case 7: return "h";
	case 8: return "i";
	case 9: return "j";
	case 10: return "k";
	case 11: return "l";
	case 12: return "m";
	case 13: return "n";
	case 14: return "o";
	case 15: return "p";
	case 16: return "q";
	case 17: return "r";
	case 18: return "s";
	case 19: return "t";
	}

	return "";
}

int getRuneFromLetter(string letter)
{
	if(letter == "a")return 0;
	if(letter == "b") return 1;
	if(letter == "c") return 2;
	if(letter == "d") return 3;
	if(letter == "e") return 4;
	if(letter == "f") return 5;
	if(letter == "g") return 6;
	if(letter == "h") return 7;
	if(letter == "i") return 8;
	if(letter == "j") return 9;
	if(letter == "k") return 10;
	if(letter == "l") return 11;
	if(letter == "m") return 12;
	if(letter == "n") return 13;
	if(letter == "o") return 14;
	if(letter == "p") return 15;
	if(letter == "q") return 16;
	if(letter == "r") return 17;
	if(letter == "s") return 18;
	if(letter == "t") return 19;
	return -1;
}

void getRuneIcons()
{
AddIconToken("$touchrune$", "runeIcons.png", Vec2f(8, 8), 0);
AddIconToken("$sightrune$", "runeIcons.png", Vec2f(8, 8), 1);
AddIconToken("$witnessrune$", "runeIcons.png", Vec2f(8, 8), 2);
AddIconToken("$curserune$", "runeIcons.png", Vec2f(8, 8), 3);

AddIconToken("$firerune$", "runeIcons.png", Vec2f(8, 8), 4);
AddIconToken("$waterrune$", "runeIcons.png", Vec2f(8, 8), 5);
AddIconToken("$earthrune$", "runeIcons.png", Vec2f(8, 8), 6);
AddIconToken("$airrune$", "runeIcons.png", Vec2f(8, 8), 7);

AddIconToken("$consumerune$", "runeIcons.png", Vec2f(8, 8), 8);
AddIconToken("$growrune$", "runeIcons.png", Vec2f(8, 8), 9);
AddIconToken("$spacerune$", "runeIcons.png", Vec2f(8, 8), 10);
AddIconToken("$timerune$", "runeIcons.png", Vec2f(8, 8), 11);

AddIconToken("$lightrune$", "runeIcons.png", Vec2f(8, 8), 12);
AddIconToken("$liferune$", "runeIcons.png", Vec2f(8, 8), 13);
AddIconToken("$restorerune$", "runeIcons.png", Vec2f(8, 8), 14);
AddIconToken("$orderrune$", "runeIcons.png", Vec2f(8, 8), 15);

AddIconToken("$darkrune$", "runeIcons.png", Vec2f(8, 8), 16);
AddIconToken("$deathrune$", "runeIcons.png", Vec2f(8, 8), 17);
AddIconToken("$decayrune$", "runeIcons.png", Vec2f(8, 8), 18);
AddIconToken("$chaosrune$", "runeIcons.png", Vec2f(8, 8), 19);
}

string getRuneCodeName(int id)
{
	switch(id){
	case 0: return "touch";
	case 1: return "sight";
	case 2: return "witness";
	case 3: return "curse";
	case 4: return "fire";
	case 5: return "water";
	case 6: return "earth";
	case 7: return "air";
	case 8: return "consume";
	case 9: return "grow";
	case 10: return "space";
	case 11: return "time";
	case 12: return "light";
	case 13: return "life";
	case 14: return "restore";
	case 15: return "order";
	case 16: return "dark";
	case 17: return "death";
	case 18: return "decay";
	case 19: return "chaos";
	}
	return "";
}














int getRuneHeat(string letter)
{
	if(letter == "e") return 1;
	if(letter == "f") return -1;
	if(letter == "g") return 0;
	if(letter == "h") return 0;
	
	if(letter == "i") return 2;
	if(letter == "j") return -2;
	if(letter == "k") return 0;
	if(letter == "l") return 2;
	
	if(letter == "m") return 2;
	if(letter == "n") return -1;
	if(letter == "o") return 3;
	
	if(letter == "q") return -1;
	if(letter == "r") return -2;
	if(letter == "s") return 3;
	if(letter == "t") return XORRandom(3)-1;
	return 0;
}

int getRuneFlow(string letter)
{
	if(letter == "e") return 0;
	if(letter == "f") return 2;
	if(letter == "g") return -2;
	if(letter == "h") return 1;
	
	if(letter == "i") return -1;
	if(letter == "j") return 0;
	if(letter == "k") return 2;
	if(letter == "l") return 0;
	
	if(letter == "m") return 1;
	if(letter == "n") return 3;
	if(letter == "o") return -1;
	
	if(letter == "q") return -1;
	if(letter == "r") return 3;
	if(letter == "s") return -2;
	if(letter == "t") return XORRandom(3)-1;
	return 0;
}

int getRuneComplexity(string letter)
{
	if(letter == "e") return 0;
	if(letter == "f") return 0;
	if(letter == "g") return 0;
	if(letter == "h") return 0;
	
	if(letter == "i") return 0;
	if(letter == "j") return 0;
	if(letter == "k") return 1;
	if(letter == "l") return 1;
	
	if(letter == "m") return 2;
	if(letter == "n") return 2;
	if(letter == "o") return 2;
	if(letter == "p") return -1; //Order is like a period or space, it makes things easier to read.
	
	if(letter == "q") return 0;
	if(letter == "r") return 1;
	if(letter == "s") return 1;
	if(letter == "t") return -1; //lol chaos
	return 0;
}

int getRuneHoly(string letter)
{
	if(letter == "e") return 0;
	if(letter == "f") return 0;
	if(letter == "g") return 0;
	if(letter == "h") return 0;
	
	if(letter == "i") return 0;
	if(letter == "j") return 0;
	if(letter == "k") return 0;
	if(letter == "l") return 0;
	
	if(letter == "m") return 1;
	if(letter == "n") return 1;
	if(letter == "o") return 1;
	
	if(letter == "q") return -1;
	if(letter == "r") return -1;
	if(letter == "s") return -1;
	if(letter == "t") return XORRandom(3)-1;
	return 0;
}


int getRunesHoliness(string runes){
	int holy = 0;
	for (int step = 2; step < runes.length(); step += 1)
	{
		holy += getRuneHoly(runes.substr(step,1));
	}
	return holy;
}

int getRunesHeat(string runes){
	int heat = 0;
	for (int step = 2; step < runes.length(); step += 1)
	{
		heat += getRuneHeat(runes.substr(step,1));
	}
	return heat;
}

int getRunesFlow(string runes){
	int flow = 0;
	for (int step = 2; step < runes.length(); step += 1)
	{
		flow += getRuneFlow(runes.substr(step,1));
	}
	return flow;
}

int getRunesComplexity(string runes){
	int complexity = 0;
	for (int step = 2; step < runes.length(); step += 1)
	{
		complexity += getRuneComplexity(runes.substr(step,1));
	}
	return complexity;
}

int RunePrimaryAbilityID(string letter)
{
	if(letter == "e") return 1;
	if(letter == "f") return 2;
	if(letter == "g") return 3;
	if(letter == "h") return 4;
	
	if(letter == "i") return 5;
	if(letter == "j") return 6;
	if(letter == "k") return 7;
	if(letter == "l") return 8;
	
	if(letter == "m") return 9;
	if(letter == "n") return 10;
	if(letter == "o") return 11;
	if(letter == "p") return 0;
	
	if(letter == "q") return 12;
	if(letter == "r") return 13;
	if(letter == "s") return 14;
	if(letter == "t") return XORRandom(15);
	return 0;
}

int RuneSecondaryAbilityID(string letter)
{
	if(letter == "e") return 1;
	if(letter == "f") return 2;
	if(letter == "g") return 3;
	if(letter == "h") return 4;
	
	if(letter == "i") return 5;
	if(letter == "j") return 6;
	if(letter == "k") return 7;
	if(letter == "l") return 8;
	
	if(letter == "m") return 9;
	if(letter == "n") return 10;
	if(letter == "o") return 11;
	if(letter == "p") return 0;
	
	if(letter == "q") return 12;
	if(letter == "r") return 13;
	if(letter == "s") return 14;
	if(letter == "t") return XORRandom(15);
	return 0;
}



int getPrimaryAbilityID(string runes){
	int ID = RunePrimaryAbilityID(runes.substr(0,1));
	return ID;
}


int getSecondaryAbilityID(string runes){
	int ID = RuneSecondaryAbilityID(runes.substr(1,1));
	return ID;
}

int AbilityHeatRequirement(int ID){
	return 0;
}
int AbilityFlowRequirement(int ID){
	return 0;
}
int AbilityHolyRequirement(int ID){
	
	if(ID == 9)return 10;
	if(ID == 10)return 6;
	if(ID == 11)return 6;
	
	if(ID == 12)return 5;
	if(ID == 13)return 5;
	if(ID == 14)return 1;
	
	return 0;
}

bool AbilityHeatRequirementLarger(int ID){
	return true;
}
bool AbilityFlowRequirementLarger(int ID){
	return true;
}
bool AbilityHolyRequirementLarger(int ID){
	
	if(ID == 12)return false;
	if(ID == 13)return false;
	if(ID == 14)return false;
	
	return true;
}