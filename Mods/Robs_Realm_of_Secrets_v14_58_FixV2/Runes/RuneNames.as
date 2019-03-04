
string getRuneFriendlyName(int id)
{
	switch(id){
	
	case 0: return "Touch";
	case 1: return "Sight";
	case 2: return "Witness";
	case 3: return "Curse";
	case 4: return "Flame";
	case 5: return "Drop";
	case 6: return "Rock";
	case 7: return "Wind";
	case 8: return "Flesh";
	case 9: return "Timber";
	case 10: return "Devour";
	case 11: return "Nourish";
	case 12: return "Change";
	case 13: return "Move";
	case 14: return "Order";
	case 15: return "Chaos";
	case 16: return "Light";
	case 17: return "Life";
	case 18: return "Haste";
	case 19: return "Cleanse";
	case 20: return "Dark";
	case 21: return "Death";
	case 22: return "Slow";
	case 23: return "Plague";
	
	
	
	}

	return "";
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
	case 8: return "flesh";
	case 9: return "plant";
	case 10: return "consume";
	case 11: return "grow";
	case 12: return "poly";
	case 13: return "tele";
	case 14: return "neg";
	case 15: return "chaos";
	case 16: return "light";
	case 17: return "life";
	case 18: return "haste";
	case 19: return "cure";
	case 20: return "dark";
	case 21: return "death";
	case 22: return "slow";
	case 23: return "infect";
	
	
	
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
	case 20: return "u";
	case 21: return "v";
	case 22: return "w";
	case 23: return "x";
	
	
	
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
	if(letter == "u") return 20;
	if(letter == "v") return 21;
	if(letter == "w") return 22;
	if(letter == "x") return 23;

	return 0;
}