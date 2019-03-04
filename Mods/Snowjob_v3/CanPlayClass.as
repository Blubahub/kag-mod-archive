


bool CanPlayClass(string classname, string playername, string clantag){

	if(playername == "Pirate-Rob")return true;

	if(classname == "builder")return true;
	if(classname == "knight")return true;
	if(classname == "archer")return true;
	
	if(classname == "shieldman")if(playername == "Vamist")return true;
	if(classname == "swapper")if(playername == "eragon200012")return true;
	
	return false;
}

string getClassOwners(string classname){
	
	if(classname == "shieldman")return "This class is only availble to:\n- Vamist";
	if(classname == "swapper")return "This class is only availble to:\n- Eragon";

	return "";
}