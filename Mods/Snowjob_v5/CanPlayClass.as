


bool CanPlayClass(string classname, string playername, string clantag){

	if(playername == "Pirate-Rob")return true;

	if(classname == "builder")return true;
	if(classname == "knight")return true;
	if(classname == "archer")return true;
	
	if(classname == "shieldman")if(playername == "Vamist")return true;
	if(classname == "swapper")if(playername == "eragon200012")return true;
	if(classname == "grappleknight")if(playername == "an_obamanation" || playername == "Paralogia" || playername == "neil58" || playername == "toothgrinderx" || playername == "Anks")return true;
	if(classname == "twister")if(playername == "Potatobird")return true;
	if(classname == "ranger")if(playername == "ferdo")return true;
	if(classname == "grabber")if(playername == "jimmyzoudcba" || playername == "kenlin33" || playername == "MegaLOLdon" || clantag == "GLINT")return true;
	if(classname == "waterdeity")if(playername == "Blue_Tiger" || playername == "The-Cub")return true;
	if(classname == "shadowblade"){
		CBlob@[] Blobs;	   
		getBlobsByName("shadowblade", @Blobs);
		getBlobsByName("shadowbladegrave", @Blobs);
		getBlobsByName("shadowghost", @Blobs);
		if(Blobs.length > 0){
			return false;
		}
		if(playername == "Kasper123")return true;
	}
	if(classname == "shadow")if(playername == "rosanna2000" || playername == "Kasper123")return true;
	
	return false;
}

string getClassOwners(string classname){
	
	if(classname == "shieldman")return "This class is only availble to:\n- Vamist";
	if(classname == "swapper")return "This class is only availble to:\n- Eragon";
	if(classname == "grappleknight")return "This class is only availble to:\n- Terri\n- Paralogia\n- Neil\n- ToothGrinder\n- Anks";
	if(classname == "twister")return "This class is only availble to:\n- Potato Bird";
	if(classname == "ranger")return "This class is only availble to:\n- Ferdo";
	if(classname == "grabber")return "This class is only availble to:\n- Jimmy Zoudcba\n- kenlin33\n- MegaLOLdon\n- The GLINT clan";
	if(classname == "waterdeity")return "This class is only availble to:\n- Maltager";
	if(classname == "shadowblade"){
		CBlob@[] Blobs;	   
		getBlobsByName("shadowblade", @Blobs);
		getBlobsByName("shadowbladegrave", @Blobs);
		getBlobsByName("shadowghost", @Blobs);
		if(Blobs.length > 0){
			return "There can only be one Shadow Blade per round.";
		}
		return "This class is only availble to:\n- Kasper";
	}
	if(classname == "shadow")return "This class is only availble to:\n- Rosanna\n- Kasper";
	
	return "";
}