
#include "LimbsCommon.as"

string BodyTypeToBlobName(int type, string normal){

	if(type == BodyType::Flesh){
		if(normal == "main_arm" || normal == "sub_arm")return "flesh_arm";
		if(normal == "front_leg" || normal == "back_leg")return "flesh_leg";
	}
	if(type == BodyType::Peg)return "stick";
	if(type == BodyType::Hook)return "stub_hook";
	
	return normal;
}


int BlobNameToBodyType(string name,string limb){

	if(name == "flesh_arm")if(limb == "main_arm" || limb == "sub_arm")return BodyType::Flesh;
	if(name == "flesh_leg")if(limb == "front_leg" || limb == "back_leg")return BodyType::Flesh;
	if(name == "stick")return BodyType::Peg;
	if(name == "stub_hook"){
		if(limb == "main_arm" || limb == "sub_arm")return BodyType::Hook;
	}

	return -1;
}