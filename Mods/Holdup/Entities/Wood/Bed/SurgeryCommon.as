
string BodyTypeToBlobName(int type, string normal){

	if(type == 0){
		if(normal == "main_arm" || normal == "sub_arm")return "flesh_arm";
		if(normal == "front_leg" || normal == "back_leg")return "flesh_leg";
	}
	if(type == 2)return "stick";
	if(type == 3)return "stub_hook";
	
	return normal;
}


int BlobNameToBodyType(string name,string limb){

	if(name == "flesh_arm")if(limb == "main_arm" || limb == "sub_arm")return 0;
	if(name == "flesh_leg")if(limb == "front_leg" || limb == "back_leg")return 0;
	if(name == "stick")return 2;
	if(name == "stub_hook"){
		if(limb == "main_arm" || limb == "sub_arm")return 3;
	}

	return -1;
}