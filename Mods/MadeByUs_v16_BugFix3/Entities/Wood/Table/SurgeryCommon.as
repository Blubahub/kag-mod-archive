
string BodyTypeToBlobName(int type, string normal){

	if(type == 0){
		if(normal == "main_arm" || normal == "sub_arm")return "flesh_arm";
		if(normal == "front_leg" || normal == "back_leg")return "flesh_leg";
	}
	if(type == 2)return "stick";

	return normal;
}


int BlobNameToBodyType(string name){

	if(name == "flesh_arm")return 0;
	if(name == "flesh_leg")return 0;
	if(name == "stick")return 2;

	return -1;
}