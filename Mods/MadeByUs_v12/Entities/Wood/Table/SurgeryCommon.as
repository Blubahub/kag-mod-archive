
string BodyTypeToBlobName(int type, string normal){

	if(type == 2)return "stick";

	return normal;
}


int BlobNameToBodyType(string name){

	if(name == "stick")return 2;

	return -1;
}