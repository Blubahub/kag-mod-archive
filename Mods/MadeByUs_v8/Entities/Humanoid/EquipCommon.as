
int getEquipedHandType(CBlob @this, string name){
	//Types:
	//0 - none/fist
	//1 - stick
	//2 - pick
	//3 - sword
	//4 - bow
	//5 - shield
	//6 - grapple
	//7 - axe
	
	if(name == "shield")return 5;
	
	if(name == "grapple")return 6;
	
	if(name == "bow")return 4;
	
	if(name == "stick")return 1;
	
	if(name == "pick")return 2;
	
	if(name == "axe")return 7;
	
	return 0;
}

bool isTwoHanded(string name){

	if(name == "shield")return true;
	
	if(name == "bow")return true;
	
	return false;
}

int getEquipedType(string name){
	//-1 - none
	//0 - head
	//1 - torso
	//2 - legs
	//3 - arms
	//4 - back

	if(name == "shield")return 3;
	
	if(name == "grapple")return 3;
	
	if(name == "bow")return 3;
	
	if(name == "stick")return 3;
	
	if(name == "pick")return 3;
	
	if(name == "axe")return 3;
	
	if(name == "sack")return 4;
	
	if(name == "barrel")return 4;
	
	return -1;
}

CBlob@ getEquippedBlob(CBlob @this, string equip){

	CBlob @ result = null;

	if(this.getInventory() !is null)
	for(int i = 0;i < this.getInventory().getItemsCount();i += 1){
		CBlob @blob = this.getInventory().getItem(i);
		if(blob !is null){
			if(blob.hasTag(equip)){
				@result = blob;
			}
		}
	}

	
	return result;
}